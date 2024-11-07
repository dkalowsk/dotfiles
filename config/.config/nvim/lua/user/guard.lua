local M = {
    "nvimdev/guard.nvim",
    dependencies = {
        "nvimdev/guard-collection",
    },
}

function M.config()
    local ft = require("guard.filetype")

    ft('c'):fmt('clang-format')
           :lint('clang-tidy')

    ft('sh'):lint('shellcheck')
    ft('py'):fmt('black')


    vim.g.guard_config = {
        fmt_on_save = true,
        lsp_as_default_formatter = false
    }
end

return M
