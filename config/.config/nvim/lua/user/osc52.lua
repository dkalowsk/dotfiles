local M = {
    "ojroques/nvim-osc52"
}

local function copy(lines, _)
  require('osc52').copy(table.concat(lines, '\n'))
end

local function paste()
  return {vim.fn.split(vim.fn.getreg(''), '\n'), vim.fn.getregtype('')}
end

function M.config()
    local wk = require "which-key"
    wk.register({
        f = "OSC52",
        c = { require("osc52").copy_operator, "Copy text to clipboard" },
    }, { prefix = "<leader>", mode = "n" })
    wk.register({
        f = "OSC52",
        c = { require("osc52").copy_visual, "Copy selection to clipboard" },
    }, { prefix = "<leader>", mode = "v" })

    vim.g.clipboard = {
      name = 'osc52',
      copy = {['+'] = copy, ['*'] = copy},
      paste = {['+'] = paste, ['*'] = paste},
    }
    require("osc52").setup {
        max_length = 0,  -- maximum length of selection, 0 means no limit
        silent = false,  -- disable message on successful copy
        trim = false,    -- trim surrounding whitespaces before copy
        tmux_passthrough = false, -- use tmux?  set this to true 
    }
end

return M
