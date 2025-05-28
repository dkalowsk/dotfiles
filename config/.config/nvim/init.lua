require "user.launch"
require "user.options"
require "user.keymaps"
spec "user.colorscheme"
spec "user.devicons"
spec "user.gitsigns"
spec "user.guard"
-- schemastore and mason need to be before lspconfig so we can get the right schemea
spec "user.schemastore"
spec "user.treesitter"
spec "user.mason"
--spec "user.osc52"
spec "user.lspconfig"
-- cmp must come after lspconfig it seems
spec "user.cmp"
spec "user.lualine"
spec "user.neoclip"
spec "user.neogit"
spec "user.telescope"
spec "user.trouble"
spec "user.undotree"
spec "user.whichkey"
-- spec "user.gutentags"
require "user.lazy"

local icons = require "user.icons"
vim.diagnostic.config {
  virtual_text = false,
  signs = {
    active = true,
    text = {
      [vim.diagnostic.severity.ERROR] = icons.diagnostics.Error,
      [vim.diagnostic.severity.WARN] = icons.diagnostics.Warning,
      [vim.diagnostic.severity.INFO] = icons.diagnostics.Information,
      [vim.diagnostic.severity.HINT] = icons.diagnostics.Hint,
    },
  },
  float = {
    border = "rounded",
    format = function(d)
      return ("%s (%s) [%s]"):format(d.message, d.source, d.code or d.user_data.lsp.code)
    end,
  },
  underline = true,
  jump = {
    float = true,
  },
}

-- the below clip was found at:
-- https://github.com/neovim/neovim/issues/16339#issuecomment-1457394370
-- 
vim.api.nvim_create_autocmd('BufRead', {
  callback = function(opts)
    vim.api.nvim_create_autocmd('BufWinEnter', {
      once = true,
      buffer = opts.buf,
      callback = function()
        local ft = vim.bo[opts.buf].filetype
        local last_known_line = vim.api.nvim_buf_get_mark(opts.buf, '"')[1]
        if
          not (ft:match('commit') and ft:match('rebase'))
          and last_known_line > 1
          and last_known_line <= vim.api.nvim_buf_line_count(opts.buf)
        then
          vim.api.nvim_feedkeys([[g`"]], 'nx', false)
        end
      end,
    })
  end,
})
