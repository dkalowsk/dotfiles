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

    require("lspconfig.ui.windows").default_options.border = "rounded"

    vim.lsp.config('bashls', {})
    vim.lsp.config('clangd', {})
--    vim.lsp.config('ccls', {
--        init_options= {
--            compileationDatabaseDirectory = "build/release/lsp";
--            index = {
--                threads = 0;
--            };
--        }
--    })
    vim.lsp.config('pyright', {})

    -- the following pulled from the nvim-lspconfig lua_ls.lua
     vim.lsp.config('lua_ls', {
       on_init = function(client)
         if client.workspace_folders then
           local path = client.workspace_folders[1].name
           if
             path ~= vim.fn.stdpath('config')
             and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc'))
           then
             return
           end
         end

         client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
           runtime = {
             -- Tell the language server which version of Lua you're using (most
             -- likely LuaJIT in the case of Neovim)
             version = 'LuaJIT',
             -- Tell the language server how to find Lua modules same way as Neovim
             -- (see `:h lua-module-load`)
             path = {
               'lua/?.lua',
               'lua/?/init.lua',
             },
           },
           -- Make the server aware of Neovim runtime files
           workspace = {
             checkThirdParty = false,
             library = {
               vim.env.VIMRUNTIME
             }
           }
         })
       end,
       settings = {
         Lua = {}
       }
    })

    vim.lsp.enable('bashls')
    vim.lsp.enable('clangd')
    vim.lsp.enable('pyright')
    vim.lsp.enable('lua_ls')

end

return M
