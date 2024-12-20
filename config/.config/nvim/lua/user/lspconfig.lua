local M = {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        {
            "folke/neodev.nvim",
        },
    },
}

local function lsp_keymaps(bufnr)
    local opts = { noremap = true, silent = true }
    local keymap = vim.api.nvim_buf_set_keymap

    print("LSP started")

    opts.desc = "Goto Declaration"
    keymap(bufnr, "n", "gD", "vim.lsp.buf.declaration", opts)
    opts.desc = "Goto Definition"
    keymap(bufnr, "n", "gd", "vim.lsp.buf.definition", opts)
    opts.desc = "Hover"
    keymap(bufnr, "n", "K", "vim.lsp.buf.hover", opts)
    opts.desc = "Goto Implementaiton"
    keymap(bufnr, "n", "gI", "vim.lsp.buf.implementation", opts)
    opts.desc = "Find References"
    keymap(bufnr, "n", "gr", "vim.lsp.buf.references", opts)
    opts.desc = "Diagnostics Open Float"
    keymap(bufnr, "n", "gl", "vim.diagnostic.open_float", opts)
end

M.on_attach = function(client, bufnr)
    lsp_keymaps(bufnr)

    if client.supports_method "textDocument/inlayHint" then
        vim.lsp.inlay_hint.enable(true, { bufnr })
    end
end

function M.common_capabilities()
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument.completion.completionItem.snippetSupport = true
    return capabilities
end

M.toggle_inlay_hints = function()
    local bufnr = vim.api.nvim_get_current_buf()
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr }), { bufnr })
end

function M.config()
    local wk = require "which-key"
    wk.add({
        { "<leader>la", "<cmd>lua vim.lsp.buf.code_action()<cr>", desc = "Code Action" },
        { "<leader>li", "<cmd>LspInfo<cr>", desc = "Info" },
        { "<leader>lh", "<cmd>lua require('user.lspconfig').toggle_inlay_hints()<cr>", desc = "Hints Toggle" },
        { "<leader>lj", "<cmd>lua vim.diagnostic.goto_next()<cr>", desc = "Next Diagnostic" },
        { "<leader>lk", "<cmd>lua vim.diagnostic.goto_prev()<cr>", desc = "Previous Diagnostic" },
        { "<leader>ll", "<cmd>lua vim.lsp.codelens.run()<cr>", desc = "CodeLens Action" },
        { "<leader>lq", "<cmd>lua vim.diagnostic.setloclist()<cr>", desc = "Quickfix" },
        { "<leader>lr", "<cmd>lua vim.lsp.buf.rename()<cr>", desc = "Rename" },
    },
    {
        mode = { "v" },  -- VISUAL mode additions
        { "<leader>la", group = "LSP" },
        { "<leader>laa", "<cmd>lua vim.lsp.buf.code_action()<cr>", descr = "Code Action"},
    })

    local lspconfig = require "lspconfig"
    local icons = require "user.icons"

    local servers = {
        "bashls",
        -- "clangd",
        "ccls",
        "lua_ls",
        "pyright",
    }

    local default_diagnostic_config = {
        signs = {
            active = true,
            values = {
                { name  = "DiagnosticSignError", text = icons.diagnostics.Error },
                { name  = "DiagnosticSignWarn", text = icons.diagnostics.Warning },
                { name  = "DiagnosticSignHint", text = icons.diagnostics.Hint },
                { name  = "DiagnosticSignInfo", text = icons.diagnostics.Information },
            },
        },
        virtual_text = false,
        update_in_insert = false,
        underline = true,
        severity_sort = true,
        float = {
            focusable = true,
            style = "minimal",
            border = "rounded",
            source = "always",
            header = "",
            prefix = "",
        },
    }

    vim.diagnostic.config(default_diagnostic_config)

    for _, sign in ipairs(vim.tbl_get(vim.diagnostic.config(), "signs", "values") or {}) do
        vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = sign.name })
    end

    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
    vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })
    require("lspconfig.ui.windows").default_options.border = "rounded"

    for _, server in pairs(servers) do
        local opts = {
            on_attach = M.on_attach,
            capabilities = M.common_capabilities(),
        }

        local require_ok, settings = pcall(require, "user.lspsettings." .. server)
        if require_ok then
            opts = vim.tbl_deep_extend("force", settings, opts)
        end

        if server == "lua_ls" then
            require("neodev").setup {}
        end

        if server == "ccls" then
            local cc_path_full = vim.loop.cwd()
            local cc_path_relative = "build/release/lsp/mpro_fw"
            if vim.fn.isdirectory(cc_path_full .. cc_path_relative) == 0 then
                cc_path_relative = "ampere-zephyr/" .. cc_path_relative
                if vim.fn.isdirectory(cc_path_full .. cc_path_relative) == 0 then
                    cc_path_relative = ""
                end
            end
            opts.compilationDatabaseDirectory = cc_path_full .. cc_path_relative
        end

        lspconfig[server].setup(opts)
    end
end

return M
