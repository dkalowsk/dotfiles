local M = {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
        "williamboman/mason.nvim",
    },
}

function M.config()
    local servers = {
        "bashls",
        "clangd",
        "lua_ls",
        "pyright",
    }

    require("mason").setup {
        ui = {
            border = "rounded",
            icons = {
                package_installed = "✓",
                package_pending = "➜",
                package_uninstalled = "✗"
            },
        },
    }

    require("mason-lspconfig").setup {
        ensure_installed = servers,
    }
end

return M
