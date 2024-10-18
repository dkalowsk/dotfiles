local M = {
  "nvim-telescope/telescope.nvim",
  dependencies = {
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make", lazy = true },
      { "nvim-lua/plenary.nvim" } },
}

function M.find_files()
    require("user.telescopePickers").prettyFilesPicker {
        picker = "find_files",
        -- options = { search_dirs = get_search_dirs() },
    }
end

function M.config()
  local wk = require "which-key"
  local custom_picker = require "user.telescopePickers"

  wk.add({
    { "<leader>fb", "<cmd>Telescope buffers previewer=true sort_mru=true<cr>", desc = "List Buffers" },
    { "<leader>fc", "<cmd>Telescope colorscheme<cr>", desc = "List Colorschemes" },
    { "<leader>ff", function() M.find_files() end, desc = "Find Files" },
    { "<leader>ft", function() custom_picker.prettyGrepPicker({ picker = 'live_grep' }) end, desc = "Find Text" },
    { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "nvim Help" },
    { "<leader>fl", "<cmd>Telescope resume<cr>", desc = "Last Search" },
    { "<leader>fr", function() custom_picker.prettyFilesPicker({ picker = 'oldfiles' }) end, desc = "Recent Files" },
    { "<leader>fa", function() custom_picker.prettyGrepPicker({ picker = 'grep_string' }) end, desc = "Find Cursor Text" },
    { "<leader>fp", "<cmd>Telescope projects<cr>", desc = "List Projects" },
    { "<leader>s", "<cmd>Telescope registers<cr>", desc = "Registers" },
  })
--    custom_picker.prettyGrepPicker({ picker = 'live_grep' }),
--    custom_picker.prettyGrepPicker({ picker = 'grep_string' }),
--    custom_picker.prettyFilesPicker({ picker = 'oldfiles' }),
--    custom_picker.prettyFilesPicker({ picker = 'find_files' }),

  local icons = require "user.icons"
  local actions = require "telescope.actions"

  require("telescope").setup {
    defaults = {
       prompt_prefix = icons.ui.Telescope .. " ",
      selection_caret = icons.ui.Forward .. " ",
      file_ignore_patterns = { ".git/", ".west/", ".venv/" },
      entry_prefix = "   ",
      initial_mode = "insert",
      selection_strategy = "reset",
      path_display = { "smart" },
      color_devicons = true,
      vimgrep_arguments = {
        "rg",
        "--color=never",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
        "--smart-case",
        "--hidden",
        "--glob=!.git/",
      },

      mappings = {
        i = {
          ["<C-n>"] = actions.cycle_history_next,
          ["<C-p>"] = actions.cycle_history_prev,

          ["<C-j>"] = actions.move_selection_next,
          ["<C-k>"] = actions.move_selection_previous,
        },
        n = {
          ["<esc>"] = actions.close,
          ["j"] = actions.move_selection_next,
          ["k"] = actions.move_selection_previous,
          ["q"] = actions.close,
        },
      },
    },
    pickers = {
      live_grep = {
        theme = "dropdown",
        previewer = true,
      },

      grep_string = {
        theme = "dropdown",
      },

      find_files = {
        theme = "dropdown",
        previewer = true,
        path_display = function(opts, path)
            local tail = require("telescope.utils").path_tail(path)
            return string.format("%s (%s)", tail, path), { { { 1, #tail }, "Constant" } }
        end,
      },

      buffers = {
        theme = "dropdown",
        previewer = false,
        initial_mode = "normal",
        mappings = {
          i = {
            ["<C-d>"] = actions.delete_buffer,
          },
          n = {
            ["dd"] = actions.delete_buffer,
          },
        },
      },

      planets = {
        show_pluto = true,
        show_moon = true,
      },

      colorscheme = {
        enable_preview = true,
      },

      lsp_references = {
        theme = "dropdown",
        initial_mode = "normal",
      },

      lsp_definitions = {
        theme = "dropdown",
        initial_mode = "normal",
      },

      lsp_declarations = {
        theme = "dropdown",
        initial_mode = "normal",
      },

      lsp_implementations = {
        theme = "dropdown",
        initial_mode = "normal",
      },
    },
    extensions = {
      fzf = {
        fuzzy = true, -- false will only do exact matching
        override_generic_sorter = true, -- override the generic sorter
        override_file_sorter = true, -- override the file sorter
        case_mode = "smart_case", -- or "ignore_case" or "respect_case"
      },
    },
  }
end

return M
