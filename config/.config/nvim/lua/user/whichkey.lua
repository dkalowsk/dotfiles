local M = {
  "folke/which-key.nvim",
}

function M.config()
  local which_key = require("which-key")
  which_key.add({
    mode = { "n" }, -- NORMAL mode
    { "<leader><space>", "<cmd>nohlsearch<CR>", desc ="No HL" },
    { "<leader>;", "<cmd>tabnew | terminal<CR>", desc ="Term" },
    { "<leader>h", "<cmd>split<CR>", desc ="Split" },
    { "<leader>b", group = "Buffers" },
    { "<leader>d", group = "Debug" },
    { "<leader>f", group = "Find" },
    { "<leader>g", group = "Git" },
    { "<leader>l", group = "LSP" },
    { "<leader>p", group = "Plugins" },
    { "<leader>t", group = "Test" },
    { "<leader>a", group = "Tab" },
    { "<leader>an", "<cmd>$tabnew<cr>", desc ="New Empty Tab" },
    { "<leader>aN", "<cmd>tabnew %<cr>", desc ="New Tab" },
    { "<leader>ao", "<cmd>tabonly<cr>", desc ="Only" },
    { "<leader>ah", "<cmd>-tabmove<cr>", desc ="Move Left" },
    { "<leader>al", "<cmd>+tabmove<cr>", desc ="Move Right" },
    { "<leader>T", group = "Treesitter" },
  })

  which_key.setup {
    plugins = {
      marks = true,
      registers = true,
      spelling = {
        enabled = true,
        suggestions = 20,
      },
      presets = {
        operators = false,
        motions = false,
        text_objects = false,
        windows = false,
        nav = false,
        z = false,
        g = false,
      },
    },
    win= {
      no_overlap = true,
      padding = { 2, 2 }, -- [ top/bottom, right/left ]
      title = true,
    },
    filter = function(mapping)
        return true
        end,
    show_help = false,
    show_keys = false,
    disable = {
      buftypes = {},
      filetypes = { "TelescopePrompt" },
    },
  }
end

return M
