local telescope_builtin = require "telescope.builtin"

local function lsp_references()
  local params = vim.lsp.util.make_position_params()
  vim.lsp.buf_request(0, "textDocument/references", params, function(err, result, ctx, config)
    if err or not result or vim.tbl_isempty(result) then
      print "No references found"
      return
    end
    telescope_builtin.lsp_references { results = result }
  end)
end

return {
  lsp_references = lsp_references,
}
