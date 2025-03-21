local M = {
    "folke/trouble.nvim",
}

function M.config()
    local wk = require "which-key"
    wk.add({
        {"<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Trouble Toggle" },
        {"<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Trouble Buffer Diagnostics" },
        {"<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Trouble Symbols" },
        {"<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Trouble Quickfix" },
        {"<leader>xl", "<cmd>Trouble loclist toggle<cr>", desc = "Trouble Local list" },
        {"<leader>xcl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "Trouble LSP References" },
    }
    )

    require("trouble").setup {
        position = "bottom",
        height = 15,
        icons = false,
        mode = "workspace_diagnostics",
        fold_open = "v",
        fold_closed = ">",
        indent_lines = false,
        signs = {
            error = "error",
            warning = "warn",
            hint = "hint",
            information = "info",
        },
        use_diagnostic_signs = false,
    }
end

return M

