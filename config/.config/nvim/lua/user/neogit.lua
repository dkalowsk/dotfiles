local M = {
    "NeogitOrg/neogit",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "sindrets/diffview.nvim",        -- optional - Diff integration

        "nvim-telescope/telescope.nvim", -- optional
    },
    event = "VeryLazy",
}

function M.config()
    local wk = require "which-key"
    wk.add({
        { "<leader>gg", "<cmd>Neogit<CR>", desc = "NeoGIT" },
    })

    require("neogit").setup {
        auto_refresh = true,
        disable_builtin_notifications = false,
        use_magit_keybindings = false,
        kind = "tab",
        commit_popup = {
            kind = "split",
        },
        popup = {
            kind = "split",
        },
--        signs = {
--            section = { icons.ui.ChevronRight, icons.ui.ChevronShortDown },
--            item = { icons.ui.ChevronRIght, icons.ui.ChevronShortDown },
--            hunk = { "", "" },
--        },
    }
end

return M
