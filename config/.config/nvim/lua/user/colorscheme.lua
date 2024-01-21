local M = {
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
}

function M.config()
    vim.cmd.colorscheme "tokyonight-night"
end

return M
