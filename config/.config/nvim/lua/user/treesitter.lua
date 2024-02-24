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
            "lua",
            "markdown",
            "markdown_inline",
            "python",
            "vim"
        },
        highlight = {
            enable = true,
            disable = { "kconfig" },
        },
        indent = {
            enable = true
        },
    }
end

return M
