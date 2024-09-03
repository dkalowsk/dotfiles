local M = {
    "lewis6991/gitsigns.nvim",
    event = "BufEnter",
    cmd = "Gitsigns",
}

M.config = function()
    local icons = require "user.icons"

    local wk = require "which-key"
    wk.register {
        ["<leader>gj"] = { "<cmd>lua require 'gitsigns'.next_hunk({navigation_message = false})<cr>", "Next Hunk"},
        ["<leader>gk"] = { "<cmd>lua require 'gitsigns'.prev_hunk({navigation_message = false})<cr>", "Prev Hunk"},
        ["<leader>gp"] = { "<cmd>lua require 'gitsigns'.preview_hunk()<cr>", "Preview Hunk"},
        ["<leader>gr"] = { "<cmd>lua require 'gitsigns'.reset_hunk()<cr>", "Reset Hunk"},
        ["<leader>gl"] = { function() package.loaded.gitsigns.blame_line{full=true} end, "Blame"},
        ["<leader>gR"] = { "<cmd>lua require 'gitsigns'.reset_buffer()<cr>", "Reset Buffer"},
        ["<leader>gs"] = { "<cmd>lua require 'gitsigns'.stage_hunk()<cr>", "Stage Hunk"},
        ["<leader>gu"] = { "<cmd>lua require 'gitsigns'.undo_stage_hunk()<cr>", "Undo Stage Hunk"},
        ["<leader>gb"] = { "<cmd>lua require 'gitsigns'.toggle_current_line_blame()<cr>", "Toggle Blame"},
        ["<leader>gd"] = { "<cmd>Gitsigns diffthis HEAD<cr>", "Git Diff"},
    }

    require("gitsigns").setup {
        signs = {
            add = { text = icons.ui.BoldLineMiddle },
            change = { text = icons.ui.BoldLineDashedMiddle },
            delete = { text = icons.ui.TriangleShortArrowRight },
            topdelete = { text = icons.ui.TriangleShortArrowRight },
            changedelete = { text = icons.ui.BoldLineMiddle },
        },
        watch_gitdir = {
            interval = 1000,
            follow_files = true,
        },
        signcolumn = true,
        numhl = false,
        linehl = false,
        auto_attach = true,
        attach_to_untracked = true,
        current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
        current_line_blame_opts = {
            virt_text = true,
            virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
            delay = 1000,
            ignore_whitespace = true,
            virt_text_priority = 100,
        },
        update_debounce = 200,
        status_formatter = nil,
        max_file_length = 40000,
        preview_config = {
            border = "rounded",
            style = "minimal",
            relative = "cursor",
            row = 0,
            col = 1,
        },
        on_attach = function(bufnr)
            local gs = package.loaded.gitsigns

            local function map(mode, l, r, opts)
                opts = opts or {}
                opts.buffer = bufnr
                vim.keymap.set(mode, l, r, opts)
            end

            -- navigation 
            map('n', ']c', function()
                if vim.wo.diff then return ']c' end
                vim.schedule(function() gs.next_hunk() end)
                return '<Ignore>'
            end, {expr=true})

            map('n', '[c', function()
                if vim.wo.diff then return '[c' end
                vim.schedul(function() gs.prev_hunk() end)
                return '<Ignore>'
            end, {expr=true})
        end,
    }
end

return M

