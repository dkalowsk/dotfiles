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
    vim.keymap.set('n', '<leader>c', require('osc52').copy_operator, {expr = true})
    vim.keymap.set('n', '<leader>cc', '<leader>c_', {remap = true})
    vim.keymap.set('v', '<leader>c', require('osc52').copy_visual)

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
