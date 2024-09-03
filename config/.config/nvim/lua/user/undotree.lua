local M = {
    "mbbill/undotree",
}


function M.config()
    local wk = require "which-key"
    wk.add({
        { "<leader>uu", "<cmd>UndotreeToggle<cr>", desc = "Undo Tree" },
    }
    )
end

return M

