local M = {
    "nvim-lualine/lualine.nvim",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
        opt = true,
    },
}

function M.config()
    require("lualine").setup {
        options = {
            icons_enabled = false,
            theme = "horizon",
            component_separators = { left = "▒░", right = "░▒" },
            section_separators = { left = "▓▒░", right = "░▒▓" },
            ignore_focus = { "NvimTree" },
        },
        sections = {
            lualine_a = { "mode", "diff" },
            lualine_b = { "branch", "diagnostics" },
            lualine_c = { "filename" },
            lualine_x = { "encoding", "fileformat", "filetype" },
            lualine_y = { "progress" },
            lualine_z = { "selectioncount", "location" },
        },
        inactive_sections = {
            lualine_a = { },
            lualine_b = { },
            lualine_c = { "filename" },
            lualine_x = { },
            lualine_y = { },
            lualine_z = { "selectioncount", "location" },
        },
        tabline = {},
        winbar = {},
        inactive_winbar = {},
        extensions = {},
    }
end

return M 
