local M = {
    "lewis6991/gitsigns.nvim",
    event = "BufEnter",
    cmd = "Gitsigns",
}

M.config = function()
    local icons = require "user.icons"
    local gitsigns = require('gitsigns')

    local wk = require "which-key"
    wk.add({
        { "<leader>gR", gitsigns.reset_buffer, desc = "Reset Buffer" },
        { "<leader>gb", gitsigns.toggle_current_line_blame, desc = "Toggle Blame" },
        { "<leader>gd", gitsigns.diffthis, desc = "Git Diff" },
        { "<leader>gj", "<cmd>lua require 'gitsigns'.next_hunk({navigation_message = false})<cr>", desc = "Next Hunk" },
        { "<leader>gk", "<cmd>lua require 'gitsigns'.prev_hunk({navigation_message = false})<cr>", desc = "Prev Hunk" },
        { "<leader>gl", function() gitsigns.blame_line{full=true} end, desc = "Blame" },
        { "<leader>gp", gitsigns.preview_hunk, desc = "Preview Hunk" },
        { "<leader>gr", gitsigns.reset_hunk, desc = "Reset Hunk" },
        { "<leader>gs", gitsigns.stage_hunk, desc = "Stage Hunk" },
        { "<leader>gu", gitsigns.undo_stage_hunk, desc = "Undo Stage Hunk" },
    },
    {
        mode = { "v" },
        { "<leader>gs", function() gitsigns.stage_hunk() {vim.fn.line('.'), vim.fn.line('v')} end, desc = "Stage Hunk" },
        { "<leader>gr", function() gitsigns.reset_hunk() {vim.fn.line('.'), vim.fn.line('v')} end, desc = "Reset Hunk" },
    })

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

