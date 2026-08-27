local M = {}

function M.update_quickfix()
  local path = '/tmp/vitest.json'
  local f = io.open(path, 'r')
  if not f then
    print 'No vitest.json file found'
    return
  end

  local raw = f:read '*a'
  f:close()

  if raw == '' then
    print 'vitest.json is empty'
    return
  end

  local ok, data = pcall(vim.json.decode, raw)
  if not ok or not data.testResults then
    print 'Failed to parse vitest.json'
    return
  end

  local qf = {}

  for _, suite in ipairs(data.testResults) do
    local filename = suite.name

    for _, test in ipairs(suite.assertionResults or {}) do
      if test.status == 'failed' then
        local label = table.concat(test.ancestorTitles or {}, ' ')
        if label ~= '' then
          label = label .. ' - '
        end
        label = label .. (test.title or '')

        for _, msg in ipairs(test.failureMessages or {}) do
          table.insert(qf, {
            filename = filename,
            lnum = 1, -- JSON reporter does not include line numbers
            col = 1,
            text = label .. ' → ' .. msg,
          })
        end
      end
    end
  end

  vim.fn.setqflist(qf, 'r')
  print('Quickfix updated (' .. #qf .. ' items)')
end

return M
