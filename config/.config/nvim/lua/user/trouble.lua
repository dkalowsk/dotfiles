local M = {
    "folke/trouble.nvim",
}

function M.config()
    local wk = require "which-key"
    wk.add({
        {"<leader>to", function() require("trouble").toggle() end, desc = "Trouble Toggle" },
        {"<leader>tw", function() require("trouble").toggle("workspace_diagnostics") end, desc = "Workspace Diagnostics" },
        {"<leader>td", function() require("trouble").toggle("document_diagnostics") end, desc = "Document Diagnostics" },
        {"<leader>tq", function() require("trouble").toggle("quickfix") end, desc = "Quickfix" },
        {"<leader>tl", function() require("trouble").toggle("loclist") end, desc = "Local list" },
        {"gR", function() require("trouble").toggle("lsp_references") end, desc = "LSP References" },
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

