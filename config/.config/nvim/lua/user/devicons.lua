local M = {
    "nvim-tree/nvim-web-devicons",
    event = "VeryLazy",
}

function M.config()
    require("nvim-web-devicons").setup {
        color_icons = true,
        default = true,
    }
end

return M
