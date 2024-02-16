local M = {
    "ludovicchabant/vim-gutentags",
}

function M.config()
    vim.cmd [[
        set tags=expand('~/.cache/vim/ctags')
        let g:gutentags_enabled = 1
        let g:gutentags_generate_on_new = 1
        let g:gutentags_generate_on_missing = 1
        let g:gutentags_generate_on_write = 1
        let g:gutentags_generate_on_empty_buffer = 0
        let g:gutentags_background_update = 1
        let g:gutentags_add_default_project_roots = 1
        let g:gutentags_project_root = ['.west']
        let g:gutentags_cache_dir = expand('~/.cache/vim/ctags')
        let g:gutentags_file_list_command = {
            \'markers': {
            \  '.git': 'git ls-files',
            \  },
            \}
        let g:gutentags_ctags_extra_args = [
        \ '--tag-relative=yes',
        \ '--fields=ailmnSt',
        \ '--fields-C=*',
        \ '--fields-C++=*',
        \ ]
    ]]

    vim.keymap.set('n', '<C-]>', 'g<C-]>')
    vim.keymap.set('n', '<A-]>', ':vsp <CR>:exec("tag ".expand("<cword>"))<CR>')
end

return M
