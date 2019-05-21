"
" To start this whole thing off you'll need to go get vundle like so:
" git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
"
set nocompatible  " None of this works with old original vi, only VIM

if has("unix")
let s:uname = substitute(system("uname -s"), '\n', '', '') " remove the trailing \n
endif

" vim-plug setup {{{
let plugin_install_needed=0
if has('nvim')
if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  let plugin_install_needed=1
endif
else
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  let plugin_install_needed=1
endif
endif

call plug#begin('~/.vim/bundle')

if filereadable(expand("~/.vimrc.bundles.local"))
	source ~/.vimrc.bundles.local
endif

if exists(plugin_install_needed)
  if plugin_install_needed == 1
    echo "Installing vim plugins"
    echo ""
    autocmd VimEnter * PlugInstall --sync
  endif
endif

call plug#end()
" }}}

"leader is a comma, because / is too hard to hit constantly
let mapleader=","
set encoding=utf-8

" vim UI settings {{{
set number
"set norelativenumber
"set relativenumber
set wildmenu         " visual autocomplete for command menu
set wildmode=longest,list:full " match to the longest string possible
set wildignore=*.o,*.obj,*~
set lazyredraw       " redraw only when we need time_colon
set timeoutlen=1000  " timeout mapping delays after 1000 ms
set ttimeoutlen=50   " timeout key code delays after 50 ms
set backspace=indent,eol,start
set history=1000      " Store a ton of history (default is 20)
set undolevels=1000   " lots of undo
set visualbell
set noerrorbells      " we don't want audio bells
set nowrap
set whichwrap=b,s,h,l,<,>,[,]   " backspace and cursor keys wrap too
set list
set listchars=tab:»\ ,extends:›,precedes:‹,nbsp:·,trail:·
set scrolloff=3

" status line contents {{{
set laststatus=2     " Enable lower status bar
" Broken down into easily includeable segments
set statusline=%<%f\                     " Filename
set statusline+=%w%h%m%r                 " Options
set statusline+=\ [%{&ff}/%Y]            " Filetype
set statusline+=\ [%{getcwd()}]          " Current dir
set statusline+=%=%-14.(%l,%c%V%)\ %p%%  " Right aligned file nav info
" }}}

" code folding {{{
set foldenable        " enable the folding option
set foldlevelstart=10 " open most folds by default
set foldnestmax=10    " 10 nested folds maximum
nnoremap <space> za   " use space to open/close a fold
set foldmethod=indent " try using the indent method
" }}}

" search {{{
set showmatch   " highlight matching [{()}]
set incsearch   " search as characters are entered
set hlsearch    " enable highlight of matches
set ignorecase  " ignore case when searching
set smartcase   " ignore case if search pattern is all lowercase
" turn off search highlight
nnoremap <leader><space> :nohlsearch<CR>
"
" }}}

" {{{ enable mouse and clipboard
set mouse=a                 " Automatically enable mouse usage
set mousehide               " Hide the mouse cursor while typing

let ssh_remote_env=$SSH_CLIENT
if ssh_remote_env == ''
if has('clipboard')
	if has('unnamedplus')  " When possible use + register for copy-paste
            set clipboard=unnamed,unnamedplus
        else         " On mac and Windows, use * register for copy-paste
            set clipboard=unnamed
        endif
endif
endif
" }}}

scriptencoding utf-8

"
" Enable a marker line on a Column not to overstep
set colorcolumn=120

" local buffer remap keys {{{
" set ctrl-tab to be next buffer
"nnoremap <C-Tab> :bn<CR>
" set ctrl-shift-tab to be back one buffer
"noremap <C-S-Tab> :bp<CR>
" }}}

set shortmess+=filmnrxoOtT          " Abbrev. of messages (avoids 'hit enter')
set viewoptions=folds,options,cursor,unix,slash " Better Unix / Windows compatibility
set virtualedit=onemore             " Allow for cursor beyond last character
set spell                           " Spell checking on
set hidden                          " Allow buffer switching without saving
set iskeyword-=.                    " '.' is an end of word designator
set iskeyword-=#                    " '#' is an end of word designator
set iskeyword-=-                    " '-' is an end of word designator

set tabpagemax=10                   " Only show 10 tabs

set completeopt=menuone,longest,noinsert,noselect
" enable vim to auto update a file if it has changes
set autoread

" disable the search highlight
nmap <silent> <leader>/ :set invhlsearch<CR>

if has('nvim')
  if s:uname == "Darwin"
    let g:python_host_prog = '/usr/bin/python'
  else
    let g:python_host_prog = '/usr/local/bin/python'
  endif
  let g:python3_host_prog = '/usr/local/bin/python3'
end

" }}}

"  FileType overrides {{{
" ============================================================================

" filetype_cpp {{{
augroup filetype_cpp
  autocmd!
  autocmd VimEnter * highlight clear SignColumn
  autocmd BufEnter *.cpp setlocal filetype=cpp
  autocmd BufEnter *.h setlocal filetype=cpp
  autocmd BufEnter *.hpp setlocal filetype=cpp
"  autocmd BufWritePre *.cpp, *.h \:call <SID>StripTrailingWhitespaces()
  autocmd FileType cpp setlocal tabstop=2
  autocmd FileType cpp setlocal shiftwidth=2
  autocmd FileType cpp setlocal softtabstop=2
  autocmd FileType cpp setlocal expandtab
  autocmd FileType cpp setlocal autoindent
  autocmd FileType cpp setlocal copyindent

augroup END
" }}}

" filetype_text {{{
augroup filetype_text
  " Source of the commented out line: https://stackoverflow.com/a/11068175
  "autocmd WinEnter * :if &ft=='text' | DisableAcp | else | EnableAcp | endif
  "autocmd WinEnter README,*.txt :DisableAcp
  "autocmd WinLeave README,*.txt :EnableAcp
augroup END
" }}}

" filetype_markdown {{{
augroup filetype_markdown
  autocmd FileType *.md setlocal filetype=markdown
  autocmd FileType markdown setlocal textwidth=80
  autocmd FileType markdown setlocal autoindent
  autocmd FileType markdown setlocal copyindent
augroup END
" }}}

" filetype_vim {{{
augroup filetype_vim
  autocmd!
  autocmd FileType vim setlocal expandtab
  autocmd FileType vim setlocal tabstop=2
  autocmd FileType vim setlocal shiftwidth=2
  autocmd FileType vim setlocal softtabstop=2
  autocmd FileType vim setlocal number
  autocmd FileType vim setlocal ruler
  " Enable code folding for vimscript files
  autocmd FileType vim setlocal foldmethod=marker
augroup END
" }}}

" {{{ filetype_crontab
augroup filetype_crontab
  autocmd!
  " Avoid doing all of this for the crontab!
  autocmd FileType crontab setlocal nowritebackup
augroup END
" }}}

" {{{ filetype_python 
augroup filetype_python
  autocmd!
  autocmd FileType python setlocal autoindent
  autocmd FileType python setlocal smartindent
  autocmd FileType python setlocal textwidth=79 " Keep things PEP-8 friendly
  autocmd FileType python setlocal shiftwidth=4
  autocmd FileType python setlocal tabstop=4
  autocmd FileType python setlocal softtabstop=4
augroup END
" }}}

" filetype_bash {{{
augroup filetype_bash
  autocmd!
  autocmd BufEnter *.sh setlocal filetype=sh
  autocmd FileType sh setlocal autoindent
  autocmd FileType sh setlocal smartindent
  autocmd FileType sh setlocal copyindent
  autocmd FileType sh setlocal shiftwidth=2
  autocmd FileType sh setlocal tabstop=2
  autocmd FileType sh setlocal expandtab
  autocmd FileType sh setlocal softtabstop=2
augroup END
" }}}
"
" {{{ filetype_gitcommit
" Instead of reverting the cursor to the last position in the buffer, we
" set it to the first line when editing a git commit message
augroup filetype_gitcommit
  autocmd!
  autocmd FileType gitcommit autocmd BufEnter COMMIT_EDITMSG call setpos('.', [0, 1, 1, 0])
"au FileType gitcommit au! BufEnter COMMIT_EDITMSG setlocal textwidth=75
augroup END
" }}}

" ============================================================================

" http://vim.wikia.com/wiki/Restore_cursor_to_file_position_in_previous_editing_session
" Restore cursor to file position in previous editing session
" To disable this, add the following to top of .vimrc:
"   let g:no_restore_cursor = 1
if !exists('g:no_restore_cursor')
  function! ResCur()
      if line("'\"") <= line("$")
	  silent! normal! g`"
	  return 1
      endif
  endfunction

  augroup resCur
      autocmd!
      autocmd BufWinEnter * call ResCur()
  augroup END
endif

" Fix cursor shape for use in tmux
if exists('$TMUX')
  let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
  let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
elseif empty('$MSYSTEM')
  " Do not set this on MING as it causes weird error messages
  let &t_SI = "\<Esc>]50;CursorShape=1\x7"
  let &t_EI = "\<Esc>]50;CursorShape=0\x7"
endif
" }}}

" window shift and tab keys {{{
" Remap the standard VIM movement keys to also work for moving between window frames
" while holding down Cntrl
map <C-J> <C-W><C-J>
map <C-K> <C-W><C-K>
map <C-L> <C-W><C-L>
map <C-H> <C-W><C-H>
"map <C-K> <C-W><C-W>
noremap <Tab> :bn<CR>
noremap <S-Tab> :bp<CR>
" }}}

" backup {{{
"set backup
"set backupdir=~/.vim-tmp,~/.tmp, ~/tmp,/var/tmp,/tmp
"set backupskip=/tmp/*,/private/tmp/*
"set directory=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
"set writebackup
set nobackup
set noswapfile
" }}}

" {{{ persistent_undo
if has('persistent_undo')
    " Save all undo files in a single location (less messy, more risky)...
    set undodir=$HOME/.VIM_UNDO_FILES

    " Save a lot of back-history...
    set undolevels=5000

    " Actually switch on persistent undo
    set undofile

endif
" }}}

" {{{ visual block configurations

" Visual Block mode is far more useful that Visual mode (so swap the commands)...
nnoremap v <C-V>
nnoremap <C-V> v

vnoremap v <C-V>
vnoremap <C-V> v

"Square up visual selections...
set virtualedit=block

" Make BS/DEL work as expected in visual modes (i.e. delete the selected text)...
vmap <BS> x

" Make vaa select the entire file...
vmap aa VGo1G


"=====[ Make arrow keys move visual blocks around ]======================

vmap <up>    <Plug>SchleppUp
vmap <down>  <Plug>SchleppDown
vmap <left>  <Plug>SchleppLeft
vmap <right> <Plug>SchleppRight

vmap D       <Plug>SchleppDupLeft
vmap <C-D>   <Plug>SchleppDupLeft
"}}}

" color scheme {{{
"-----------------------------------------------------------
syntax enable
set t_Co=256
set background=dark
if exists('g:plugs["vim-colors-solarized"]')
	let g:solarized_termcolors=256
	let g:solarized_style="dark"
	let g:solarized_termtrans=1
	let g:solarized_constract = "normal"
	let g:solarized_visibility = "normal"
	colorscheme solarized
else
	colorscheme slate
endif
" }}}

" Session List {{{
set sessionoptions=blank,buffers,curdir,folds,tabpages,winsize
" }}}

" lightline {{{
if exists('g:plugs["lightline"]')
	" Using this as a replacement for airline removing the need
	" for hacked up fonts
	let g:lightline.colorscheme = 'jellybeans'

	let g:lightline.component_expand = {
	\   'linter_checking': 'lightline#ale#checking',
	\   'linter_warnings': 'lightline#ale#warnings',
	\   'linter_errors': 'lightline#ale#errors',
	\   'linter_ok': 'lightline#ale#ok'
	\ }

	let g:lightline.component_type = {
	\   'linter_checking': 'left',
	\   'linter_warnings': 'warning',
	\   'linter_errors': 'error',
	\   'linter_ok': 'left',
	\ }

	let g:lightline.active = {
	\   'left': [['mode', 'paste'], ['filename', 'modified']],
	\   'right': [['readonly', 'linter_warnings', 'linter_errors', 'linter_ok'], ['lineinfo'], ['percent']],
	\ }

	let g:lightline.enable = {
	\ 'statusline': 1,
	\ 'tabline': 1
	\ }

	let g:lightline#ale#indicator_warnings = '◆'
	let g:lightline#ale#indicator_errors = '✗'
	let g:lightline#ale#indicator_ok = '✓ '

	set showtabline=2 " show tabline
	set guioptions-=e " don't use GUI tabline
endif
" }}}

" tagbar {{{
"-----------------------------------------------------------
if exists('g:plugs["tagbar"]')
	nnoremap <silent> <leader>tt :TagbarToggle<CR>
	let g_tagbar_foldlevel = 2

	let g:tagbar_type_cpp = {
            \ 'ctagstype' : 'c++',
            \ 'kinds'     : [
                \ 'd:macros:1:0',
                \ 'p:prototypes:1:0',
                \ 'g:enums',
                \ 'e:enumerators:0:0',
                \ 't:typedefs:0:0',
                \ 'n:namespaces',
                \ 'c:classes',
                \ 's:structs',
                \ 'u:unions',
                \ 'f:functions',
                \ 'm:members:0:0',
                \ 'v:variables:0:0'
            \ ],
            \ 'sro'        : '::',
            \ 'kind2scope' : {
                \ 'g' : 'enum',
                \ 'n' : 'namespace',
                \ 'c' : 'class',
                \ 's' : 'struct',
                \ 'u' : 'union'
            \ },
            \ 'scope2kind' : {
                \ 'enum'      : 'g',
                \ 'namespace' : 'n',
                \ 'class'     : 'c',
                \ 'struct'    : 's',
                \ 'union'     : 'u'
            \ }
        \ }
endif

" }}}

" NERDtree {{{
"-----------------------------------------------------------
if exists('g:plugs["nerdtree"]')
	map <F2> :NERDTreeToggle<CR>  " set F2 to be the key to open NERDTree
	" Configure to open NERDTree if no file is given
	"autocmd StdinReadPre * let s:std_in=1
	"autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
	"autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

	let g:nerdtree_tabs_open_on_console_startup = 0
	let g:nerdtree_tabs_open_on_gui_startup=0
	let g:nerdtree_tabs_meaningful_tab_names = 1
	let g_nerdtree_tabs_autoclose = 1
	let g:NERDTreeIndicatorMapCustom = {
    \ "Modified"  : "✹",
    \ "Staged"    : "✚",
    \ "Untracked" : "✭",
    \ "Renamed"   : "➜",
    \ "Unmerged"  : "═",
    \ "Deleted"   : "✖",
    \ "Dirty"     : "✗",
    \ "Clean"     : "✔︎",
    \ "Unknown"   : "?"
    \ }
	let NERDTreeShowBookmarks=1
	let NERDTreeIgnore=['\.py[cd]$', '\~$', '\.swo$', '\.swp$', '^\.git$', '^\.hg$', '^\.svn$', '\.bzr$']
	let NERDTreeChDirMode=0
	let NERDTreeQuitOnOpen=1
	let NERDTreeMouseMode=2
	let NERDTreeShowHidden=1
	let NERDTreeKeepTreeInNewTab=1
endif
" }}}

" gundo {{{
"-----------------------------------------------------------
nnoremap <leader>u :GundoToggle<CR>
" }}}

" ctags && gutentags {{{
"-----------------------------------------------------------
set tags=~/.vimtags
  
" Make tags placed in .git/tags file available in all levels of a repository
let gitroot = substitute(system('git rev-parse --show-toplevel'), '[\n\r]', '', 'g')
if gitroot != ''
	let &tags = &tags . ',' . gitroot . '/.git/tags'
endif

if exists('g:plugs["vim-gutentags"]')
	let g:gutentags_enabled=1
	let g:gutentags_generate_on_new=1
	let g:gutentags_generate_on_missing=1
	let g:gutentags_generate_on_write=1
	let g:gutentags_background_update=1
	let g:gutentags_cache_dir = '~/.vimtags'
	let g:gutentags_file_list_command = {
				\'markers': {
				\  '.git': 'git ls-files',
				\  },
				\}
	set statusline+=%{gutentags#statusline()}
endif

if executable('ctags')
	nnoremap <C-]> g<C-]>
	map <A-]> :vsp <CR>:exec("tag ".expand("<cword>"))<CR>
endif
" }}}

" indent_guides {{{
if exists('g:plugs["vim-indent-guides"]')
	let g:indent_guides_auto_colors = 1
	let g:indent_guides_start_level=2
	let g:indent_guides_guide_size=1
	let g:indent_guides_enable_on_vim_startup=1
"hi IndentGuidesOdd   ctermbg=black
"hi IndentGuidesEven  ctermbg=darkgrey
" When using background=light use these settings:
"hi IndentGuidesOdd   ctermbg=white
"hi IndentGuidesEvent ctermbg=lightgrey
endif
" }}}

" cpp-enhanced-highlight {{{
if exists('g:plugs["vim-cpp-enhanced-highlight"]')
	let g:cpp_class_scope_highlight=1
	let g:cpp_member_variable_highlight=1
	let g:cpp_experimental_simple_template_highlight=0
	let g:cpp_experimental_template_highlight=0
	let g:cpp_concepts_highlight=0
endif
"}}}

" rainbow parens {{{
if exists('g:plugs["rainbow"]')
	let g:rainbow_active = 1
	let g:rainbow_conf = {
	\   'guifgs': ['royalblue3', 'darkorange3', 'seagreen3', 'firebrick'],
	\   'ctermfgs': ['lightblue', 'lightyellow', 'lightcyan', 'lightmagenta'],
	\   'operators': '_,_',
	\   'parentheses': ['start=/(/ end=/)/ fold', 'start=/\[/ end=/\]/ fold', 'start=/{/ end=/}/ fold'],
	\   'separately': {
	\       '*': {},
	\       'tex': {
	\           'parentheses': ['start=/(/ end=/)/', 'start=/\[/ end=/\]/'],
	\       },
	\       'lisp': {
	\           'guifgs': ['royalblue3', 'darkorange3', 'seagreen3', 'firebrick', 'darkorchid3'],
	\       },
	\       'vim': {
	\           'parentheses': ['start=/(/ end=/)/', 'start=/\[/ end=/\]/', 'start=/{/ end=/}/ fold', 'start=/(/ end=/)/ containedin=vimFuncBody', 'start=/\[/ end=/\]/ containedin=vimFuncBody', 'start=/{/ end=/}/ fold containedin=vimFuncBody'],
	\       },
	\       'html': {
	\           'parentheses': ['start=/\v\<((area|base|br|col|embed|hr|img|input|keygen|link|menuitem|meta|param|source|track|wbr)[ >])@!\z([-_:a-zA-Z0-9]+)(\s+[-_:a-zA-Z0-9]+(\=("[^"]*"|'."'".'[^'."'".']*'."'".'|[^ '."'".'"><=`]*))?)*\>/ end=#</\z1># fold'],
	\       },
	\       'css': 0,
	\   }
	\}
"if executable('ag')
"	let g:rainbow_conf += { 'separately' : { 'agsv' : 0 } }
"endif
endif

" }}}

" asyncrun {{{
if exists('g:plugs["asyncrun"]')
	if exists(':Ack')
	  let g:ack_use_asyncrun = 0
	endif
endif
" }}}

" UndoTree {{{
if exists('g:plugs["undotree"]')
      nnoremap <Leader>u :UndotreeToggle<CR>
      " If undotree is opened, it is likely one wants to interact with it.
      let g:undotree_SetFocusWhenToggle=1
endif
" }}}

" quickmenu {{{
if exists('g:plugs["quickmenu"]')
  " choose a favorite key to show/hide quickmenu
  noremap <silent><F12> :call quickmenu#toggle(0)<cr>

  " enable cursorline (L) and cmdline help (H)
  let g:quickmenu_options = "HL"
endif
" }}}

"  tig support {{{
if executable('tig')

	if has('nvim')
	  " Apdated from: https://news.ycombinator.com/item?id=14306217
	  "nnoremap <leader>tb :echo system("git rev-parse --abbrev-ref @ <bar> tr -d '\n'")<CR>
	  nnoremap <leader>to :silent term tig<CR>:silent redraw!<CR>
	  nnoremap <leader>tb :silent term tig blame % +<C-r>=expand(line('.'))<CR><CR>:silent redraw!<CR>
	  nnoremap <leader>ts :silent term tig status<CR>:silent redraw!<CR>
	else
	  " Apdated from: https://news.ycombinator.com/item?id=14306217
	  "nnoremap <leader>tb :echo system("git rev-parse --abbrev-ref @ <bar> tr -d '\n'")<CR>
	  nnoremap <leader>to :silent !tig<CR>:silent redraw!<CR>
	  nnoremap <leader>tb :silent !tig blame % +<C-r>=expand(line('.'))<CR><CR>:silent redraw!<CR>
	  nnoremap <leader>ts :silent !tig status<CR>:silent redraw!<CR>
	end
	
endif
" }}}

" ale {{{
if exists('g:plugs["ale"]')
	" Only run the linter when saving the file
	"let g:ale_lint_on_text_changed = 'never'
	
	"let g:ale_open_list = 1
	" Set this if you want to.
	" This can be useful if you are combining ALE with
	" some other plugin which sets quickfix errors, etc.
	"let g:ale_keep_list_window_open = 1
	let g:ale_cpp_clang_executable = "/usr/bin/clang++"
	let g:ale_cpp_clang_options = "-std=c++14 -Wall"
	let g:ale_cpp_clangd_executable = "/usr/local/bin/clangd"
	let g:ale_cpp_clangd_options = "-std=c++14 -Wall"
	let g:ale_c_build_dir_names = [ 'runtimecore', 'build', 'bin' ]
	let g:ale_cache_executable_check_failures = 1
	let g:ale_c_parse_makefile = 1
	let g:ale_lint_on_enter = 0
	let g:ale_sign_column_always = 1
	let g:ale_c_parse_compile_commands = 1
	let g:ale_clangformat_executable= '/Users/dkalowsk/clang/clang_8/bin/clang-format'
	let g:ale_clangtidy_executable = '/Users/dkalowsky/clang/clang_8/bin/clang-tidy'
	let g:ale_linters = {
	\ 'c'   : ['clangd', 'clang-tidy'],
	\ 'cpp' : ['clangd', 'clang-tidy'],
	\}
	let g:ale_fixers = {
	\ 'c'   : ['clang-format'],
	\ 'cpp' : ['clang-format'],
	\}
	let g:ale_completion_max_suggestions = 100
	let g:ale_completion_enabled = 1

	let g:ale_sign_warning = '▲'
	let g:ale_sign_error = '✗'
	highlight link ALEWarningSign String
	highlight link ALEErrorSign Title
	nmap ]w :ALENextWrap<CR>
	nmap [w :ALEPreviousWrap<CR>
	nmap <Leader>af <Plug>(ale_fix)
endif

"}}}

" fzf {{{
if exists('g:plugs["fzf.vim"]')
	nmap ; :Buffers<CR>
	" Search all tags
	nmap <Leader>fT :Tags<CR>
	" Search only the local buffer for the specific tag
	nmap <Leader>ft :BTags<CR>
	" Use AG for some fuzzy find
	nmap <Leader>fa :Ag --ignore tags<Space>
	" Search only for git tracked files
	nnoremap <C-p> :GFiles<CR>
	" Search for non-git tracked files
	nnoremap <C-P> :Files<CR>

	" Have fzf colors match color scheme
	let g:fzf_colors =
	\ {
	  \ 'fg':      ['fg', 'Normal'],
	  \ 'bg':      ['bg', 'Normal'],
	  \ 'hl':      ['fg', 'Comment'],
	  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
	  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
	  \ 'hl+':     ['fg', 'Statement'],
	  \ 'info':    ['fg', 'PreProc'],
	  \ 'border':  ['fg', 'Ignore'],
	  \ 'prompt':  ['fg', 'Conditional'],
	  \ 'pointer': ['fg', 'Exception'],
	  \ 'marker':  ['fg', 'Keyword'],
	  \ 'spinner': ['fg', 'Label'],
	  \ 'header':  ['fg', 'Comment']
	\ }

	" Default fzf layout
	" - down / up / left / right
	let g:fzf_layout = { 'down': '~40%' }

	if has('nvim')
	  aug fzf_setup
	    au!
	    au TermOpen term://*FZF tnoremap <silent> <buffer><nowait> <esc> <c-c>
	  aug END
	  " In Neovim, you can set up fzf window using a Vim command
	  let g:fzf_layout = { 'window': 'enew' }
	  let g:fzf_layout = { 'window': '-tabnew' }
	  let g:fzf_layout = { 'window': '10split enew' }
	end

	" Override Colors command. You can safely do this in your .vimrc as fzf.vim
	" will not override existing commands.
	command! -bang Colors
	  \ call fzf#vim#colors({'left': '15%', 'options': '--reverse --margin 30%,0'}, <bang>0)

	endif
"}}}
"
" vim-which-key {{{
if exists('g:plugs["which-key.vim"]')
  nnoremap <silent> <leader> :WhichKey '<,>'<CR>
endif
" }}}

function! ClangCheckImpl(cmd)
if &autowrite | wall | endif
echo "Running " . a:cmd . " ..."
  let l:output = system(a:cmd)
  cexpr l:output
  cwindow
  let w:quickfix_title = a:cmd
  if v:shell_error != 0
    cc
  endif
  let g:clang_check_last_cmd = a:cmd
endfunction

function! ClangCheck()
  let l:filename = expand('%')
  if l:filename =~ '\.\(cpp\|cxx\|cc\|c\)$'
    call ClangCheckImpl("clang-check " . l:filename)
  elseif exists("g:clang_check_last_cmd")
    call ClangCheckImpl(g:clang_check_last_cmd)
  else
    echo "Can't detect file's compilation arguments and no previous clang-check invocation!"
  endif
endfunction

nmap <silent> <F5> :call ClangCheck()<CR><CR>


" Strips trailing whitespace at the end of files.  This is called on buffer
" write in the autogroup above.
function! <SID>StripTrailingWhitespaces()
	" save last search and cursor position
	let _s=@/
	let l = line(".")
	let c = col(".")
	%s/\s+$//e
	let @/=_s
	call cursor(l, c)
endfunction

" vim:foldmethod=marker:foldlevel=0
