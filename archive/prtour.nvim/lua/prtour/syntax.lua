-- Treesitter syntax highlighting for the code portion of each diff line in the
-- tour buffer. Highlights each line independently with its file's parser, layered
-- on top of the red/green diff backgrounds.
local M = {}

M.ns = vim.api.nvim_create_namespace("prtour_syntax")

-- filetype -> treesitter lang (or false if no usable parser). Cached.
local lang_cache = {}
local function lang_for(ft)
  if ft == nil or ft == "" then
    return nil
  end
  if lang_cache[ft] ~= nil then
    return lang_cache[ft] or nil
  end
  local lang = vim.treesitter.language.get_lang(ft)
  if not lang then
    lang_cache[ft] = false
    return nil
  end
  -- Only usable if the parser is actually installed.
  local ok = pcall(vim.treesitter.language.add, lang)
  lang_cache[ft] = ok and lang or false
  return lang_cache[ft] or nil
end

local query_cache = {}
local function highlights_query(lang)
  if query_cache[lang] ~= nil then
    return query_cache[lang] or nil
  end
  local ok, q = pcall(vim.treesitter.query.get, lang, "highlights")
  query_cache[lang] = (ok and q) or false
  return query_cache[lang] or nil
end

-- Apply per-line treesitter highlights for all recorded diff code lines.
---@param session table
function M.highlight(session)
  if not vim.api.nvim_buf_is_valid(session.bufnr) then
    return
  end
  vim.api.nvim_buf_clear_namespace(session.bufnr, M.ns, 0, -1)
  local code_lines = session.code_lines or {}

  for _, cl in ipairs(code_lines) do
    local lang = lang_for(cl.ft)
    local q = lang and highlights_query(lang) or nil
    if q and cl.text ~= "" then
      pcall(function()
        local parser = vim.treesitter.get_string_parser(cl.text, lang)
        local tree = (parser:parse() or {})[1]
        if not tree then
          return
        end
        for id, node in q:iter_captures(tree:root(), cl.text, 0, 1) do
          local name = q.captures[id]
          local srow, scol, erow, ecol = node:range()
          if srow == 0 and name and not name:find("^_") then
            local end_col = (erow == 0) and ecol or #cl.text
            vim.api.nvim_buf_set_extmark(session.bufnr, M.ns, cl.bufline - 1, cl.col + scol, {
              end_row = cl.bufline - 1,
              end_col = cl.col + end_col,
              hl_group = "@" .. name,
              priority = 110,
            })
          end
        end
      end)
    end
  end
end

return M
