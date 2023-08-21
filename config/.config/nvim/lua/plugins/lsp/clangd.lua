
function! LspAttached

local capabilities = require("cmp_nvim_lsp").default_capabilities()
local lspconfig = require("lspconfig")

lspconfig[clangd].setup({
	-- on_attach goes here
	capabilities = capabilities,
})
