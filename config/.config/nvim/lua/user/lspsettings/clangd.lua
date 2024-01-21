return {
    settings = {
        clang = {
            schemas = require("schemastore").clang.schemas(),
        },
    },
    setup = {
        commands = {
            Format = {
                function()
                    vim.lsp.buf.range_formatting({}, {0, 0}, {vim.fn.line "$", 0})
                end,
            },
        },
    },
}
