-- Edit Notion pages as markdown, straight from Neovim.
--
--   :NotionEdit https://www.notion.so/My-Page-0123abcd...   pull the page into a `notion://<id>` buffer
--   :w                                                       push the buffer back (whole-page replace)
--   :e                                                       re-pull the page from Notion
--   :NotionBrowse                                            open the current page in the browser
--   :NotionLogin / :NotionLogout                             (re)authorize / forget the hosted-MCP login
--
-- Two backends, picked automatically:
--
--   1. Notion's hosted MCP server (default, no integration needed). Same server the
--      Claude Code Notion plugin uses. First use opens the browser for an OAuth login
--      (dynamic client registration + PKCE); tokens are cached in stdpath('state').
--      Tools used: `notion-fetch` (page -> Notion-flavored markdown) and
--      `notion-update-page` with `replace_content`.
--
--   2. The REST Markdown Content API (Notion-Version 2026-03-11), used when an
--      integration token is available in $NOTION_TOKEN or ~/.config/notion/token.
--
-- Notion-flavored markdown uses tabs for nesting, so the buffer is set to noexpandtab.

local MCP_URL = 'https://mcp.notion.com/mcp'
local MCP_AUTH_METADATA = 'https://mcp.notion.com/.well-known/oauth-authorization-server'
local MCP_PROTOCOL = '2025-06-18'
local REST_API = 'https://api.notion.com/v1'
local REST_VERSION = '2026-03-11'
local TIMEOUT_MS = 60000
local LOGIN_TIMEOUT_MS = 5 * 60 * 1000
local CALLBACK_PORT = 46231
local STATE_FILE = vim.fs.joinpath(vim.fn.stdpath 'state' --[[@as string]], 'notion-mcp.json')

local M = {}

local LOG_FILE = vim.fs.joinpath(vim.fn.stdpath 'log' --[[@as string]], 'notion.log')

---@param msg string
---@param level integer|nil
local function notify(msg, level)
  level = level or vim.log.levels.INFO
  vim.notify('[notion] ' .. msg, level)
  if level >= vim.log.levels.WARN then
    -- Notifications are easy to miss; keep a trail for debugging (:NotionLog)
    pcall(vim.fn.writefile, { ('%s %s'):format(os.date '%Y-%m-%d %H:%M:%S', msg) }, LOG_FILE, 'a')
  end
end

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------

---@param s string
local function b64url(s)
  return (vim.base64.encode(s):gsub('+', '-'):gsub('/', '_'):gsub('=', ''))
end

---@param s string
local function sha256_raw(s)
  return (vim.fn.sha256(s):gsub('%x%x', function(h)
    return string.char(tonumber(h, 16))
  end))
end

---@param s string|nil
---@return table|nil
local function json_decode(s)
  if not s or s == '' then
    return nil
  end
  local ok, v = pcall(vim.json.decode, s, { luanil = { object = true, array = true } })
  return ok and type(v) == 'table' and v or nil
end

---@param args string[]
---@param stdin string|nil
---@return integer code, string stdout, string stderr
local function curl(args, stdin)
  local cmd = { 'curl', '--silent', '--show-error', '--max-time', tostring(TIMEOUT_MS / 1000), '--header', 'Expect:' }
  vim.list_extend(cmd, args)
  local out = vim.system(cmd, { text = true, stdin = stdin }):wait(TIMEOUT_MS + 1000)
  return out.code, out.stdout or '', out.stderr or ''
end

--- Extract a 32-hex page id from a Notion URL, a dashed uuid or a bare id.
---@param input string
---@return string|nil
function M.page_id(input)
  input = vim.trim(input)
  -- Peek/modal URLs carry the real page in `?p=`
  local p = input:match '[?&]p=(%x+)'
  if p and #p == 32 then
    return p
  end
  local undashed = input:gsub('%-', '')
  -- Last 32-hex run wins (titles may contain hex-looking words, the id is always at the end)
  local id
  for run in undashed:gmatch '%x+' do
    if #run >= 32 then
      id = run:sub(-32)
    end
  end
  return id
end

-- ---------------------------------------------------------------------------
-- Backend 2: REST Markdown Content API (integration token)
-- ---------------------------------------------------------------------------

---@return string|nil
local function rest_token()
  if vim.env.NOTION_TOKEN and vim.env.NOTION_TOKEN ~= '' then
    return vim.env.NOTION_TOKEN
  end
  local path = vim.fs.joinpath(vim.fs.dirname(vim.fn.stdpath 'config' --[[@as string]]), 'notion', 'token')
  local lines = vim.fn.filereadable(path) == 1 and vim.fn.readfile(path, '', 1) or {}
  local tok = vim.trim(lines[1] or '')
  return tok ~= '' and tok or nil
end

---@param method 'GET'|'PATCH'
---@param id string
---@param body table|nil
---@return table|nil result, string|nil err
local function rest_request(method, id, body)
  local args = {
    '--request',
    method,
    '--header',
    'Authorization: Bearer ' .. rest_token(),
    '--header',
    'Notion-Version: ' .. REST_VERSION,
    '--header',
    'Content-Type: application/json',
    REST_API .. '/pages/' .. id .. '/markdown',
  }
  local stdin
  if body then
    vim.list_extend(args, { '--data-binary', '@-' })
    stdin = vim.json.encode(body)
  end
  local code, stdout, stderr = curl(args, stdin)
  if code ~= 0 then
    return nil, 'curl failed: ' .. vim.trim(stderr)
  end
  local json = json_decode(stdout)
  if not json then
    return nil, 'unexpected response: ' .. vim.trim(stdout)
  end
  if json.object == 'error' then
    return nil, ('%s (%s): %s'):format(json.code or 'error', tostring(json.status), json.message or '')
  end
  return json, nil
end

local rest = {}

---@param id string
---@return {markdown: string, truncated: boolean, unknown: integer}|nil, string|nil
function rest.fetch(id)
  local res, err = rest_request('GET', id)
  if not res then
    return nil, err
  end
  return { markdown = res.markdown or '', truncated = res.truncated == true, unknown = #(res.unknown_block_ids or {}) }, nil
end

---@param id string
---@param markdown string
---@return string|nil err
function rest.replace(id, markdown)
  local _, err = rest_request('PATCH', id, {
    type = 'replace_content',
    replace_content = { new_str = markdown, allow_deleting_content = false },
  })
  return err
end

-- ---------------------------------------------------------------------------
-- Backend 1: hosted MCP server (OAuth)
-- ---------------------------------------------------------------------------

---@class NotionOAuthState
---@field client_id string
---@field redirect_uri string
---@field access_token string|nil
---@field refresh_token string|nil
---@field expires_at number|nil  -- unix seconds
---@field _pending_state string|nil
---@field _pending_verifier string|nil

---@return NotionOAuthState|nil
local function load_state()
  if vim.fn.filereadable(STATE_FILE) ~= 1 then
    return nil
  end
  return json_decode(table.concat(vim.fn.readfile(STATE_FILE), '\n'))
end

---@param state NotionOAuthState|nil
local function save_state(state)
  if not state then
    vim.fn.delete(STATE_FILE)
    return
  end
  vim.fn.mkdir(vim.fs.dirname(STATE_FILE), 'p')
  vim.fn.writefile({ vim.json.encode(state) }, STATE_FILE)
  vim.uv.fs_chmod(STATE_FILE, 384) -- 0600
end

---@return table|nil metadata, string|nil err
local function auth_metadata()
  local code, stdout, stderr = curl { MCP_AUTH_METADATA }
  if code ~= 0 then
    return nil, 'curl failed: ' .. vim.trim(stderr)
  end
  local meta = json_decode(stdout)
  if not meta or not meta.token_endpoint then
    return nil, 'bad OAuth metadata: ' .. vim.trim(stdout)
  end
  return meta, nil
end

---@param token_endpoint string
---@param form table<string, string>
---@return table|nil tokens, string|nil err, string|nil oauth_error_code
local function token_request(token_endpoint, form)
  local args = { '--request', 'POST', '--header', 'Accept: application/json' }
  for k, v in pairs(form) do
    vim.list_extend(args, { '--data-urlencode', k .. '=' .. v })
  end
  table.insert(args, token_endpoint)
  local code, stdout, stderr = curl(args)
  if code ~= 0 then
    return nil, 'curl failed: ' .. vim.trim(stderr)
  end
  local json = json_decode(stdout)
  if not json then
    return nil, 'unexpected token response: ' .. vim.trim(stdout)
  end
  if json.error then
    return nil, ('%s: %s'):format(json.error, json.error_description or ''), json.error
  end
  if not json.access_token then
    return nil, 'token response without access_token'
  end
  return json, nil
end

---@param state NotionOAuthState
---@param tokens table
local function apply_tokens(state, tokens)
  state.access_token = tokens.access_token
  state.refresh_token = tokens.refresh_token or state.refresh_token
  state.expires_at = os.time() + (tonumber(tokens.expires_in) or (8 * 3600))
  save_state(state)
end

--- Start the loopback server that receives the OAuth redirect.
---@param on_code fun(code: string|nil, state: string|nil, err: string|nil)
---@return string|nil redirect_uri, string|nil err
local function start_callback_server(on_code)
  local server = vim.uv.new_tcp()
  if not server then
    return nil, 'cannot create tcp server'
  end
  local ok = server:bind('127.0.0.1', CALLBACK_PORT)
  if not ok then
    ok = server:bind('127.0.0.1', 0) -- any free port
  end
  if not ok then
    return nil, 'cannot bind loopback port'
  end
  local port = server:getsockname().port
  local done = false
  local timer = vim.uv.new_timer()

  local function finish(code, oauth_state, err)
    if done then
      return
    end
    done = true
    if timer then
      timer:stop()
      timer:close()
    end
    server:close()
    vim.schedule(function()
      on_code(code, oauth_state, err)
    end)
  end

  server:listen(16, function(lerr)
    if lerr then
      return finish(nil, nil, 'listen error: ' .. lerr)
    end
    local client = vim.uv.new_tcp()
    server:accept(client)
    local req = ''
    client:read_start(function(rerr, chunk)
      if rerr or not chunk then
        client:close()
        return
      end
      req = req .. chunk
      if not req:find('\r\n\r\n', 1, true) then
        return
      end
      client:read_stop()
      local path = req:match '^GET (%S+)' or ''
      local is_cb = path:match '^/callback'
      local body = is_cb
          and '<!doctype html><title>Neovim</title><body style="font-family:sans-serif;padding:2rem">Notion connected. You can close this tab and go back to Neovim.</body>'
        or 'not found'
      local head = ('HTTP/1.1 %s\r\nContent-Type: text/html; charset=utf-8\r\nContent-Length: %d\r\nConnection: close\r\n\r\n'):format(
        is_cb and '200 OK' or '404 Not Found',
        #body
      )
      client:write(head .. body, function()
        client:shutdown(function()
          client:close()
        end)
      end)
      if is_cb then
        local code = path:match '[?&]code=([^&%s]+)'
        local oauth_state = path:match '[?&]state=([^&%s]+)'
        local oerr = path:match '[?&]error=([^&%s]+)'
        if code then
          finish(vim.uri_decode(code), oauth_state and vim.uri_decode(oauth_state) or nil, nil)
        else
          finish(nil, nil, 'authorization failed: ' .. (oerr and vim.uri_decode(oerr) or 'no code in callback'))
        end
      end
    end)
  end)

  if timer then
    timer:start(LOGIN_TIMEOUT_MS, 0, function()
      finish(nil, nil, 'login timed out')
    end)
  end
  return ('http://127.0.0.1:%d/callback'):format(port), nil
end

--- Interactive login: register client if needed, open browser, wait for the code, exchange it.
---@param cb fun(err: string|nil)
local function login(cb)
  local meta, merr = auth_metadata()
  if not meta then
    return cb(merr)
  end
  local state = load_state() or {}
  local redirect_uri, serr = start_callback_server(function(code, got_state, cerr)
    if cerr then
      return cb(cerr)
    end
    if got_state ~= state._pending_state then
      return cb 'state mismatch in OAuth callback'
    end
    local tokens, terr = token_request(meta.token_endpoint, {
      grant_type = 'authorization_code',
      code = code,
      code_verifier = state._pending_verifier,
      client_id = state.client_id,
      redirect_uri = state.redirect_uri,
    })
    state._pending_state, state._pending_verifier = nil, nil
    if not tokens then
      return cb(terr)
    end
    apply_tokens(state, tokens)
    cb(nil)
  end)
  if not redirect_uri then
    return cb(serr)
  end

  if not state.client_id or state.redirect_uri ~= redirect_uri then
    local rcode, rout, rerr = curl {
      '--request',
      'POST',
      '--header',
      'Content-Type: application/json',
      '--data-binary',
      vim.json.encode {
        client_name = 'Neovim (notion.lua)',
        redirect_uris = { redirect_uri },
        grant_types = { 'authorization_code', 'refresh_token' },
        response_types = { 'code' },
        token_endpoint_auth_method = 'none',
      },
      meta.registration_endpoint,
    }
    local reg = rcode == 0 and json_decode(rout) or nil
    if not reg or not reg.client_id then
      return cb('client registration failed: ' .. vim.trim(rcode == 0 and rout or rerr))
    end
    state = { client_id = reg.client_id, redirect_uri = redirect_uri }
    save_state(state)
  end

  local verifier = b64url(vim.uv.random(32))
  state._pending_verifier = verifier
  state._pending_state = b64url(vim.uv.random(16))
  local url = meta.authorization_endpoint
    .. '?'
    .. table.concat({
      'response_type=code',
      'client_id=' .. vim.uri_encode(state.client_id, 'rfc3986'),
      'redirect_uri=' .. vim.uri_encode(redirect_uri, 'rfc3986'),
      'state=' .. state._pending_state,
      'code_challenge=' .. b64url(sha256_raw(verifier)),
      'code_challenge_method=S256',
    }, '&')
  notify 'opening the browser to connect Notion …'
  local ok, oerr = pcall(vim.ui.open, url)
  if not ok then
    notify('could not open a browser (' .. tostring(oerr) .. '); open this URL yourself:\n' .. url, vim.log.levels.WARN)
  end
end

--- Get a valid access token, refreshing if needed. Never interactive.
---@return string|nil token, string|nil err, boolean needs_login
local function mcp_token()
  local state = load_state()
  if not state or not state.access_token then
    return nil, 'not logged in', true
  end
  if state.expires_at and os.time() < state.expires_at - 60 then
    return state.access_token, nil, false
  end
  if not state.refresh_token then
    return nil, 'session expired', true
  end
  local meta, merr = auth_metadata()
  if not meta then
    return nil, merr, false
  end
  local tokens, terr, oauth_err = token_request(meta.token_endpoint, {
    grant_type = 'refresh_token',
    refresh_token = state.refresh_token,
    client_id = state.client_id,
  })
  if not tokens then
    if oauth_err == 'invalid_grant' then
      state.access_token, state.refresh_token, state.expires_at = nil, nil, nil
      save_state(state)
      return nil, 'session revoked, login again', true
    end
    return nil, terr, false
  end
  apply_tokens(state, tokens)
  return state.access_token, nil, false
end

--- Ensure we have a token, logging in interactively if needed.
---@param cb fun(token: string|nil, err: string|nil)
local function ensure_mcp_token(cb)
  local tok, err, needs_login = mcp_token()
  if tok then
    return cb(tok, nil)
  end
  if not needs_login then
    return cb(nil, err)
  end
  login(function(lerr)
    if lerr then
      return cb(nil, lerr)
    end
    cb(mcp_token())
  end)
end

local mcp_session_id ---@type string|nil
local mcp_initialized = false
local rpc_id = 0

--- Raw JSON-RPC over streamable HTTP. Handles JSON and SSE-framed responses.
---@param token string
---@param payload table
---@return table|nil message, string|nil err, integer|nil http_status
local function mcp_post(token, payload)
  local args = {
    '--request',
    'POST',
    '--dump-header',
    '-',
    '--header',
    'Authorization: Bearer ' .. token,
    '--header',
    'Content-Type: application/json',
    '--header',
    'Accept: application/json, text/event-stream',
    '--header',
    'MCP-Protocol-Version: ' .. MCP_PROTOCOL,
    '--header',
    'User-Agent: nvim-notion/0.1',
    '--data-binary',
    '@-',
    MCP_URL,
  }
  if mcp_session_id then
    vim.list_extend(args, { '--header', 'Mcp-Session-Id: ' .. mcp_session_id })
  end
  local code, stdout, stderr = curl(args, vim.json.encode(payload))
  if vim.env.NOTION_DEBUG then
    pcall(vim.fn.writefile, vim.split(('--- %s exit=%d\n%s\n%s'):format(payload.method, code, stdout, stderr), '\n'), LOG_FILE, 'a')
  end
  if code ~= 0 then
    return nil, 'curl failed: ' .. vim.trim(stderr)
  end
  -- Split headers / body (skip any interim 1xx blocks). curl dumps HTTP/2 headers
  -- with bare LF line endings, HTTP/1.1 ones with CRLF, so accept both.
  local headers, body = stdout, ''
  repeat
    local s, e = headers:find '\r?\n\r?\n'
    if not s then
      break
    end
    body = headers:sub(e + 1)
    headers = headers:sub(1, s - 1)
  until not body:match '^HTTP/'
  if body:match '^HTTP/' then
    headers, body = body, ''
  end
  local status = tonumber(headers:match 'HTTP/[%d.]+ (%d+)') or 0
  local sid = headers:match '[Mm][Cc][Pp]%-[Ss]ession%-[Ii][Dd]:%s*([^\r\n]+)'
  if sid then
    mcp_session_id = vim.trim(sid)
  end
  if payload.id == nil then
    return {}, nil, status -- notification: no response body expected
  end
  local message
  local is_sse = headers:lower():find 'content%-type:%s*text/event%-stream' or body:match '^%s*event:' or body:match '^%s*data:'
  if is_sse then
    local last
    for data in ('\n' .. body):gmatch '\ndata:%s*([^\n]+)' do
      local m = json_decode(data)
      if m then
        last = m
        if m.id == payload.id then
          message = m
        end
      end
    end
    message = message or last
  else
    message = json_decode(body)
  end
  if status == 401 then
    return nil, 'unauthorized (token rejected)', status
  end
  if not message then
    return nil, ('HTTP %d: %s'):format(status, vim.trim(body):sub(1, 300)), status
  end
  if message.error then
    return nil, ('rpc error %s: %s'):format(tostring(message.error.code), message.error.message or ''), status
  end
  return message, nil, status
end

---@param token string
---@return string|nil err
local function mcp_initialize(token)
  mcp_session_id = nil
  rpc_id = rpc_id + 1
  local _, err = mcp_post(token, {
    jsonrpc = '2.0',
    id = rpc_id,
    method = 'initialize',
    params = {
      protocolVersion = MCP_PROTOCOL,
      capabilities = vim.empty_dict(), -- `{}` would encode as a JSON array
      clientInfo = { name = 'nvim-notion', version = '0.1' },
    },
  })
  if err then
    return err
  end
  mcp_post(token, { jsonrpc = '2.0', method = 'notifications/initialized' })
  mcp_initialized = true
  return nil
end

---@param token string
---@param name string
---@param arguments table
---@return table|nil tool_result_json, string|nil err
local function mcp_tool(token, name, arguments)
  if not mcp_initialized then
    local ierr = mcp_initialize(token)
    if ierr then
      return nil, 'initialize failed: ' .. ierr
    end
  end
  rpc_id = rpc_id + 1
  local msg, err, status = mcp_post(token, { jsonrpc = '2.0', id = rpc_id, method = 'tools/call', params = { name = name, arguments = arguments } })
  if err and (status == 404 or status == 400) then
    -- session probably expired: re-initialize once
    local ierr = mcp_initialize(token)
    if not ierr then
      rpc_id = rpc_id + 1
      msg, err = mcp_post(token, { jsonrpc = '2.0', id = rpc_id, method = 'tools/call', params = { name = name, arguments = arguments } })
    end
  end
  if err then
    return nil, err
  end
  local result = msg and msg.result or {}
  local text = ''
  for _, c in ipairs(result.content or {}) do
    if c.type == 'text' then
      text = text .. c.text
    end
  end
  if result.isError then
    return nil, vim.trim(text) ~= '' and vim.trim(text) or 'tool error'
  end
  local parsed = json_decode(text)
  if parsed then
    return parsed, nil
  end
  return { text = text }, nil
end

local mcp = {}

--- `notion-fetch` wraps a page in an envelope:
---   Here is the result of "fetch" ... as of <date>:
---   <page url="..."><ancestor-path/><properties>{json}</properties><iconMetadata/>
---   <content>
---   ...markdown...
---   </content>
---   </page>
--- Only the <content> body is editable page content; the rest must not be written back.
---@param text string
---@return string
function M.extract_content(text)
  local inner = text:match '\n<content>\n(.-)\n</content>\n</page>%s*$' or text:match '<content>\n?(.-)\n?</content>'
  return inner or text
end

---@param token string
---@param id string
---@return {markdown: string, truncated: boolean, unknown: integer, title: string|nil}|nil, string|nil
function mcp.fetch(token, id)
  local res, err = mcp_tool(token, 'notion-fetch', { id = id })
  if not res then
    return nil, err
  end
  local unknown = res.unknown_block_count or #(res.unknown_block_ids or {})
  return { markdown = M.extract_content(res.text or ''), truncated = res.truncated == true, unknown = unknown, title = res.title }, nil
end

---@param token string
---@param id string
---@param markdown string
---@return string|nil err
function mcp.replace(token, id, markdown)
  local _, err = mcp_tool(token, 'notion-update-page', {
    page_id = id,
    command = 'replace_content',
    new_str = markdown,
    allow_deleting_content = false,
    allow_async = false,
  })
  return err
end

-- ---------------------------------------------------------------------------
-- Buffer glue
-- ---------------------------------------------------------------------------

---@param buf integer
---@param page {markdown: string, truncated: boolean, unknown: integer, title: string|nil}
local function fill_buffer(buf, page)
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end
  local id = vim.b[buf].notion_page_id
  local lines = vim.split(page.markdown, '\n', { plain = true })
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modified = false
  vim.b[buf].notion_truncated = page.truncated
  vim.b[buf].notion_title = page.title
  if page.truncated then
    notify('page is truncated; writes are disabled to avoid data loss', vim.log.levels.WARN)
  elseif page.unknown > 0 then
    notify(('%d block(s) could not be rendered as markdown (see <unknown …/> tags)'):format(page.unknown), vim.log.levels.WARN)
  else
    notify('pulled ' .. (page.title or id))
  end
end

--- BufReadCmd: fill the buffer from Notion.
---@param buf integer
local function pull(buf)
  local id = vim.b[buf].notion_page_id
  notify('pulling ' .. id .. ' …')
  if rest_token() then
    local page, err = rest.fetch(id)
    if not page then
      return notify(err, vim.log.levels.ERROR)
    end
    return fill_buffer(buf, page)
  end
  ensure_mcp_token(function(tok, terr)
    if not tok then
      return notify(terr, vim.log.levels.ERROR)
    end
    local page, err = mcp.fetch(tok, id)
    if not page then
      return notify(err, vim.log.levels.ERROR)
    end
    fill_buffer(buf, page)
  end)
end

--- BufWriteCmd: replace the whole page with the buffer contents.
---@param buf integer
local function push(buf)
  local id = vim.b[buf].notion_page_id
  if vim.b[buf].notion_truncated then
    return notify('refusing to write a truncated page', vim.log.levels.ERROR)
  end
  local markdown = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), '\n')
  notify('pushing ' .. id .. ' …')
  local err
  if rest_token() then
    err = rest.replace(id, markdown)
  else
    local tok, terr = mcp_token()
    if not tok then
      return notify(terr .. ' (run :NotionLogin)', vim.log.levels.ERROR)
    end
    err = mcp.replace(tok, id, markdown)
  end
  if err then
    return notify(err, vim.log.levels.ERROR)
  end
  vim.bo[buf].modified = false
  notify('pushed ' .. (vim.b[buf].notion_title or id))
end

local group = vim.api.nvim_create_augroup('custom_notion', { clear = true })

vim.api.nvim_create_autocmd('BufReadCmd', {
  group = group,
  pattern = 'notion://*',
  callback = function(ev)
    local id = M.page_id(ev.match)
    if not id then
      return notify('bad buffer name: ' .. ev.match, vim.log.levels.ERROR)
    end
    vim.b[ev.buf].notion_page_id = id
    vim.bo[ev.buf].buftype = 'acwrite'
    vim.bo[ev.buf].swapfile = false
    vim.bo[ev.buf].filetype = 'markdown'
    vim.bo[ev.buf].expandtab = false -- Notion-flavored markdown nests with tabs
    vim.bo[ev.buf].shiftwidth = 0
    vim.bo[ev.buf].tabstop = 4
    pull(ev.buf)
  end,
})

vim.api.nvim_create_autocmd('BufWriteCmd', {
  group = group,
  pattern = 'notion://*',
  callback = function(ev)
    push(ev.buf)
  end,
})

vim.api.nvim_create_user_command('NotionEdit', function(opts)
  local id = M.page_id(opts.args)
  if not id then
    return notify('could not find a page id in: ' .. opts.args, vim.log.levels.ERROR)
  end
  vim.cmd.edit('notion://' .. id)
end, { nargs = 1, desc = 'Edit a Notion page (URL or id) as markdown' })

vim.api.nvim_create_user_command('NotionBrowse', function()
  local id = vim.b.notion_page_id
  if not id then
    return notify('not a notion:// buffer', vim.log.levels.ERROR)
  end
  vim.ui.open('https://www.notion.so/' .. id)
end, { desc = 'Open the current Notion page in the browser' })

vim.api.nvim_create_user_command('NotionLogin', function()
  local state = load_state()
  if state then
    state.access_token, state.refresh_token, state.expires_at = nil, nil, nil
    save_state(state)
  end
  mcp_initialized = false
  login(function(err)
    if err then
      return notify('login failed: ' .. err, vim.log.levels.ERROR)
    end
    notify 'connected to Notion'
  end)
end, { desc = 'Authorize Neovim against the Notion MCP server' })

vim.api.nvim_create_user_command('NotionLog', function()
  vim.cmd.split(LOG_FILE)
end, { desc = 'Open the notion.lua warning/error log (set $NOTION_DEBUG=1 for raw responses)' })

vim.api.nvim_create_user_command('NotionLogout', function()
  save_state(nil)
  mcp_initialized = false
  notify 'forgot Notion login'
end, { desc = 'Forget the Notion MCP login' })

return M
