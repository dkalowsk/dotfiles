"
" To start this whole thing off you'll need to go get vundle like so:
" git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

" {{{ Vundle setup
"autocmd FileType python NeoCompleteLock
let vundle_install_needed=1
if !filereadable(expand("~/.vim/bundle/Vundle.vim/README.md"))
  echo "Installing Vundle..."
  echo ""
  silent git clone https://github.com/VundleVim/Vundle.vim ~/.vim/bundle/Vundle.vim
  let vundle_install_needed=0
endif

" Vundle setup {{{
set nocompatible				" does not work with old original vi, only VIM
filetype off					" required for vundle to startup
set rtp+=~/.vim/bundle/Vundle.vim
" }}}

" Vundle plugins {{{
" The following commands help run stuff:
" :PluginList    -- Lists the configured plugins
" :PluginInstall -- installs the plugins
" :PluginUpdate  -- updates the installed plugins
" :PluginSearch  -- search for a plugin
" :PluginClean   -- Removal of unused plugins

call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
if filereadable(expand("~/.vimrc.bundles.local"))
	source ~/.vimrc.bundles.local
endif

if vundle_install_needed == 0
	echo "Installing Vundle plugins"
	echo ""
	:PluginInstall
endif

call vundle#end()
filetype plugin on "load filetype plugins/indent settings
" }}}
" }}}

"leader is a comma, because / is too hard to hit constantly
let mapleader=","

" C++ auto file configuration {{{
augroup configgroup
  autocmd!
  autocmd VimEnter * highlight clear SignColumn
"  autocmd BufWritePre *.cpp, *.h \:call <SID>StripTrailingWhitespaces()
  autocmd FileType cpp setlocal tabstop=2
  autocmd FileType cpp setlocal shiftwidth=2
  autocmd FileType cpp setlocal softtabstop=2
  autocmd FileType cpp setlocal expandtab
  autocmd FileType cpp setlocal autoindent
  autocmd FileType cpp setlocal copyindent

augroup END
" }}}

" clang-complete {{{
if filereadable(expand("~/.vim/bundle/clang_complete/README.md"))
  "let s:clang_library_path='/Developer/usr/clang-ide/lib'
  "let s:clang_library_path='/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib'
  let s:clang_library_path='/Library/Developer/CommandLineTools/usr/lib'
  if isdirectory(s:clang_library_path)
    let g:clang_library_path=s:clang_library_path
  endif
  let g:clang_use_library=1
  let g:clang_complete_auto = 1
  let g:clang_auto_select = 1
  let g:clang_hl_errors = 1
  let g:clang_snippets = 1
  let g:clang_snippets_engine = 'clang_complete'
endif
" }}}

" {{{ autocmd filetype overrides
" Avoid doing all of this for the crontab!
autocmd FileType crontab setlocal nowritebackup
" }}}

" {{{ vim UI settings
"
set number
"set norelativenumber
"set relativenumber
set wildmenu         " visual autocomplete for command menu
"set wildmode=longest,list:longest " match to the longest string possible
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

" {{{ status line contents
set laststatus=2     " Enable lower status bar
" Broken down into easily includeable segments
set statusline=%<%f\                     " Filename
set statusline+=%w%h%m%r                 " Options
if !exists('g:override_spf13_bundles')
    set statusline+=%{fugitive#statusline()} " Git Hotness
endif
set statusline+=\ [%{&ff}/%Y]            " Filetype
set statusline+=\ [%{getcwd()}]          " Current dir
set statusline+=%=%-14.(%l,%c%V%)\ %p%%  " Right aligned file nav info
" }}}

" code folding {{{ 
"
set foldenable        " enable the folding option
set foldlevelstart=10 " open most folds by default
set foldnestmax=10    " 10 nested folds maximum
nnoremap <space> za   " use space to open/close a fold
set foldmethod=indent " try using the indent method
" }}}

" {{{ search 
"
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
if has('clipboard')
	if has('unnamedplus')  " When possible use + register for copy-paste
            set clipboard=unnamed,unnamedplus
        else         " On mac and Windows, use * register for copy-paste
            set clipboard=unnamed
        endif
endif
" }}}

scriptencoding utf-8

"
" Enable a marker line on a Column not to overstep
set colorcolumn=120

" local buffer remap keys {{{
" set ctrl-tab to be next buffer
nnoremap <C-Tab> :bn<CR>
" set ctrl-shift-tab to be back one buffer
nnoremap <C-S-Tab> :bp<CR>
" }}}

set shortmess+=filmnrxoOtT          " Abbrev. of messages (avoids 'hit enter')
set viewoptions=folds,options,cursor,unix,slash " Better Unix / Windows compatibility
set virtualedit=onemore             " Allow for cursor beyond last character
set spell                           " Spell checking on
set hidden                          " Allow buffer switching without saving
set iskeyword-=.                    " '.' is an end of word designator
set iskeyword-=#                    " '#' is an end of word designator
set iskeyword-=-                    " '-' is an end of word designator

" Instead of reverting the cursor to the last position in the buffer, we
" set it to the first line when editing a git commit message
au FileType gitcommit au! BufEnter COMMIT_EDITMSG call setpos('.', [0, 1, 1, 0])

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
else
  let &t_SI = "\<Esc>]50;CursorShape=1\x7"
  let &t_EI = "\<Esc>]50;CursorShape=0\x7"
endif
" }}}

" window shift keys {{{
" Remap the standard VIM movement keys to also work for moving between window frames
" while holding down Cntrl
"map <C-J> <C-W>j<C-W>_
"map <C-K> <C-W>k<C-W>_
"map <C-L> <C-W>l<C-W>_
"map <C-H> <C-W>h<C-W>_
"map <C-K> <C-W>k<C-W>_
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

" color scheme {{{
"-----------------------------------------------------------
syntax enable
set t_Co=256
set background=dark
let g:solarized_termcolors=256
let g:solarized_style="dark"
let g:solarized_termtrans=1
let g:solarized_constract = "normal"
let g:solarized_visibility = "normal"
colorscheme solarized
"color solarized
" }}}

" Session List {{{
set sessionoptions=blank,buffers,curdir,folds,tabpages,winsize
if isdirectory(expand("~/.vim/bundle/sessionman.vim/"))
	nmap <leader>sl :SessionList<CR>
        nmap <leader>ss :SessionSave<CR>
        nmap <leader>sc :SessionClose<CR>
endif
" }}}

" vim-airline {{{
"-----------------------------------------------------------
if filereadable(expand("~/.vim/bundle/vim-airline/README.md"))

	let g:airline#extensions#tabline#enabled = 1
	let g:airline_detect_modified=1

if isdirectory(expand("~/.vim/bundle/vim-airline-themes/"))
	let g:airline_theme = 'luna'
endif
	if !exists('g:airline_theme')
	  let g:airline_theme='solarized'
	endif

	let g:airline_powerline_fonts = 1
	if !exists('g:airline_powerline_fonts')
	  let g:airline_left_sep='›'  " Slightly fancier than '>'
	  let g:airline_right_sep='‹' " Slightly fancier than '<'
	endif

	if !exists('g:airline_symbols')
	  let g:airline_symbols = {}
	endif

endif
" }}}

" tagbar {{{
"-----------------------------------------------------------
if isdirectory(expand("~/.vim/bundle/tagbar/"))
	nnoremap <silent> <leader>tt :TagbarToggle<CR>
endif
let g_tagbar_foldlevel = 2

" }}}

" ctrl-p {{{
"-----------------------------------------------------------
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_match_window = 'bottom,order:ttb'
let g:ctrlp_dont_split = 'nerdtree'
let g:ctrlp_switch_buffer = 0
" r = Search from the nearest ancestor that contains a .git, .svn, or .hg directory
" a = the directory of the current file if there is no 'r' available
let g:ctrlp_working_path_mode = 'ra'
"let g:ctrlp_user_command = 'ag %s -l --nocolor --hideen -g ""'
" The nearest ancestor that contains git or set to 0 for disable
"let g:ctrlp_custom_ignore = '\v[\/]\.(git|hi|svn)$'
let g:ctrlp_custom_ignore = {
  \ 'dir':    '\v[\/]\.(git|hg|svn)$',
  \ 'file':   '\v\.(exe|so|dll|old)$',
  \ }
if executable('ag')
	" Use ag in CtrlP for listing files.  Lightning fast and respects .gitignore
	let g:ctrlp_user_command = 'ag %s --nocolor -l -g ""'
	" Since ag is fast enough, CtrlP doesn't need to cache
	let g:ctrlp_use_caching = 0
endif

if filereadable(expand("~/.vim/bundle/vim-airline/README.md"))
	let g:airline#extensions#ctrlp#color_template = 'insert'
	"let g:airline#extensions#ctrlp#color_template = 'normal'
	"let g:airline#extensions#ctrlp#color_template = 'visual'
	"let g:airline#extensions#ctrlp#color_template = 'replace'
endif
" }}}

" vim-fugitive {{{
"-----------------------------------------------------------
set diffopt+=vertical " Set fugitive's Gdiff to vertical position instead of horizontal
" }}}

" indent guides {{{
"-----------------------------------------------------------
let g:indent_guides_auto_colors = 1
"if 
"hi IndentGuidesOdd   ctermbg=black
"hi IndentGuidesEven  ctermbg=darkgrey
" When using background=light use these settings:
"hi IndentGuidesOdd   ctermbg=white
"hi IndentGuidesEvent ctermbg=lightgrey
" }}}

" syntastic {{{
"-----------------------------------------------------------
if exists(":SyntasticCheck")
	set statusline+=%#warningmsg#
	set statusline+=%{SyntasticStatuslineFlag()}
	set statusline+=%*

	let g:syntastic_always_populate_loc_list = 1
	let g:syntastic_auto_loc_list = 1
	let g:syntastic_check_on_open = 1
	let g:syntastic_check_on_wq = 0
"  let g:synatastic_clang_tidy_config_file = $clang_tidy
"  let g:synatastic_cpp_checkers = ['clang_check', 'clang-tidy', 'cppcheck' ]
endif
" }}}

" Fugitive {{{
if isdirectory(expand("~/.vim/bundle/vim-fugitive/"))
    nnoremap <silent> <leader>gs :Gstatus<CR>
    nnoremap <silent> <leader>gd :Gdiff<CR>
    nnoremap <silent> <leader>gc :Gcommit<CR>
    nnoremap <silent> <leader>gb :Gblame<CR>
    nnoremap <silent> <leader>gl :Glog<CR>
    nnoremap <silent> <leader>gp :Git push<CR>
    nnoremap <silent> <leader>gr :Gread<CR>
    nnoremap <silent> <leader>gw :Gwrite<CR>
    nnoremap <silent> <leader>ge :Gedit<CR>
    " Mnemonic _i_nteractive
    nnoremap <silent> <leader>gi :Git add -p %<CR>
    nnoremap <silent> <leader>gg :SignifyToggle<CR>
endif
"}}}

" NERDtree {{{
"-----------------------------------------------------------
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

if filereadable(expand("~/.vim/bundle/vim-gutentags/README.md"))
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
	map <silent> <leader>jd :CtrlPTag<cr><c-\>w
endif
" }}}

" indent_guides {{{
if filereadable(expand("~/.vim/bundle/vim-indent-guides/README.markdown"))
	let g:indent_guides_start_level=2
	let g:indent_guides_guide_size=1
	let g:indent_guides_enable_on_vim_startup=1
endif
" }}}

" YouCompleteMe {{{
"-------------------------------------------
" Use exuberant ctags to help speed up options
if filereadable(exists("~/.vim/bundle/youcompleteme/README.md"))
	let g:acp_enableAtStartup = 0
	let g:ycm_collect_identifiers_from_tags_files = 1
	let g:ycm_register_as_syntastic_checker = 1
	let g:Show_diagnostics_ui = 1

	" Put icons in vim's gutter on lines that have a diagnostic
	let g:ycm_enable_diagnostic_signs = 1
	let g:ycm_always_populate_location_list = 1
	let g:ycm_open_loclist_on_ycm_diags = 1
	let g:ycm_autoclose_preview_window_after_insertion = 1
	" Don't enable pop up window in comments
	let g:ycm_complete_in_comments = 0

	let g:ycm_complete_in_strings = 1
	let g:ycm_collect_identifiers_from_tags_files = 0
	let g:ycm_path_to_python_interpreter = ''

	" These are to enable compatibility with syntastic
	let g:ycm_warning_symbol = '>>'
	let g:ycm_error_symbol = '>>'
	let g:ycm_enable_diagnostic_highlighting = 1

	let g:ycm_server_use_vim_stdout = 0
	let g:ycm_server_log_level = 'info'

	"let g:ycm_filetype_whitelist = {'cpp': 1}
	let g:ycm_filetype_whitelist = {'*': 1}
	let g:ycm_confirm_extra_conf = 0
	let g:ycm_global_ycm_extra_conf = '~/.vim/.ycm_extra_conf.py'
	let g:ycm_extra_conf_globlist = []

	let g:ycm_key_invoke_completion = '<C-Space>'
	"map <C-]> :YouCompleter GoToImprecise<CR>
	nnoremap <F10> :YcmForceCompileAndDiagnostics <CR>
endif
" }}}

" rainbow parens {{{
if filereadable(expand("~/.vim/bundle/rainbow/README.md"))
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

" vim-ag {{{
if executable('ag')
	let g:ags_agexe = 'ag --vimgrep'
	let g:ags_agmaxcount = 2000
	let g:ags_agcontext = 3
	let g:ags_enable_async = 1
	let g:ags_results_per_tab = 0
	let g:ags_no_stats = 0
	let g:ags_stats_max_ln = 5000
	let g:ags_agargs = {
									\ '--break'             : [ '', ''  ],
									\ '--color'             : [ '', ''  ],
  								\ '--color-line-number' : [ '"1;30"', ''  ],
  								\ '--color-match'       : [ '"32;40"', ''  ],
  								\ '--color-path'        : [ '"1;31"', ''  ],
									\ '--column'            : [ '', ''  ],
									\ '--context'           : [ 'g:ags_agcontext', '-C', '3' ],
									\ '--filename'          : [ '', ''  ],
									\ '--group'             : [ '', ''  ],
									\ '--heading'           : [ '', '-H'  ],
									\ '--max-count'         : [ 'g:ags_agmaxcount', '-m', '2000' ],
									\ '--numbers'           : [ '', ''  ],
									\ '--ignore-dir'        : [ '.git','' ]
									\ }

	set statusline+=%ags#get_status_string()
	" search for the text under the cursor and show the results in a quickfix window
	"nnoremap <leader>k :Ags! "\b<C-R><C-W>\b"<CR>:cw<CR>
	"nnoremap <leader>k :Ag "def <cword>"
	" bind the \ key to be an ags shortcut
	command -nargs=+ -complete=file -bar Ag silent! grep! <args>|cwindow|redraw!
	nnoremap \ :Ags<SPACE>
endif
" }}}

" UndoTree {{{
if isdirectory(expand("~/.vim/bundle/undotree/"))
      nnoremap <Leader>u :UndotreeToggle<CR>
      " If undotree is opened, it is likely one wants to interact with it.
      let g:undotree_SetFocusWhenToggle=1
endif
" }}}

" vim-mucomplete {{{
if isdirectory(expand("~/.vim/bundle/vim-mucomplete"))
	" For automatic completion, you most likely want this:
	set completeopt+=menuone,noinsert,noselect
	set noshowmode shortmess+=c

	" Enable mucomplete at startup
	let g:clang_user_options = '-std=c++14'
	let g:clang_complete_auto = 1
	let g:mucomplete#enable_auto_at_startup = 1
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
