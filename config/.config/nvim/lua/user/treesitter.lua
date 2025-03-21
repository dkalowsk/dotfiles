local M = {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPost", "BufNewFile" },
    build = ":TSUpdate",
}

function M.config()
    require("nvim-treesitter.configs").setup {
        ensure_installed = {
            "bash",
            "c",
            "cmake",
            "cpp",
            "devicetree",
            "dockerfile",
            "doxygen",
            "lua",
            "markdown",
            "markdown_inline",
            "python",
            "rst",
            "vim"
        },
        highlight = {
            enable = true,
            disable = { "kconfig" },
        },
        indent = {
            enable = true
        },
        auto_install = true,
        sync_install = true,
        ignore_install = { },
        additional_vim_regex_highlights = false,
    }
end

return M
