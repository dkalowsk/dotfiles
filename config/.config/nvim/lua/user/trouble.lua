local M = {
    "folke/trouble.nvim",
}

function M.config()
    local wk = require "which-key"
    wk.register {
        ["<leader>to"] = { function() require("trouble").toggle() end, "Trouble Toggle" },
        ["<leader>tw"] = { function() require("trouble").toggle("workspace_diagnostics") end, "Workspace Diagnostics" },
        ["<leader>td"] = { function() require("trouble").toggle("document_diagnostics") end, "Document Diagnostics" },
    }

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

