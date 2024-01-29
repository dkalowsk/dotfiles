local M = {
    "mbbill/undotree",
}


function M.config()
    local wk = require "which-key"
    wk.register {
        ["<leader>uu"] = { "<cmd>UndotreeToggle<cr>", "Undo Tree" },
    }
end

return M

