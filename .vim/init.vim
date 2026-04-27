" Filename: .vimrc
" Author: Mony Xie(monyxie at gmail dot com)

" vim:fdm=marker

" {{{ terminal settings recommended by kitty
"
" Mouse support
set mouse=a
set ttymouse=sgr
set balloonevalterm
" Styled and colored underline support
let &t_AU = "\e[58:5:%dm"
let &t_8u = "\e[58:2:%lu:%lu:%lum"
let &t_Us = "\e[4:2m"
let &t_Cs = "\e[4:3m"
let &t_ds = "\e[4:4m"
let &t_Ds = "\e[4:5m"
let &t_Ce = "\e[4:0m"
" Strikethrough
let &t_Ts = "\e[9m"
let &t_Te = "\e[29m"
" Truecolor support
let &t_8f = "\e[38:2:%lu:%lu:%lum"
let &t_8b = "\e[48:2:%lu:%lu:%lum"
let &t_RF = "\e]10;?\e\\"
let &t_RB = "\e]11;?\e\\"
" Bracketed paste
let &t_BE = "\e[?2004h"
let &t_BD = "\e[?2004l"
let &t_PS = "\e[200~"
let &t_PE = "\e[201~"
" Cursor control
let &t_RC = "\e[?12$p"
let &t_SH = "\e[%d q"
let &t_RS = "\eP$q q\e\\"
let &t_SI = "\e[5 q"
let &t_SR = "\e[3 q"
let &t_EI = "\e[1 q"
let &t_VS = "\e[?12l"
" Focus tracking
let &t_fe = "\e[?1004h"
let &t_fd = "\e[?1004l"
execute "set <FocusGained>=\<Esc>[I"
execute "set <FocusLost>=\<Esc>[O"
" Window title
let &t_ST = "\e[22;2t"
let &t_RT = "\e[23;2t"

" vim hardcodes background color erase even if the terminfo file does
" not contain bce. This causes incorrect background rendering when
" using a color theme with a background color in terminals such as
" kitty that do not support background color erase.
let &t_ut=''

" }}}

" {{{ lang, enc, guiopt, cp and behavior
"====================================================================
"some options need to be set earlier
set langmenu=en_US.UTF-8
let $LANG='en'
"language messages en
set guioptions+=Lrm
set guioptions-=T
set encoding=utf8
set fileencodings=utf8,utf16,cp936,latin1
set nocompatible
" if has('win32')
source $VIMRUNTIME/vimrc_example.vim
source $VIMRUNTIME/mswin.vim
behave mswin
" endif

" }}}

" {{{ general options, font, colorscheme
set number

" expand tabs to spaces
set expandtab

set tabstop=4

" Number of spaces to use for each step of (auto)indent.  Used for
" |'cindent'|, |>>|, |<<|, etc.
" When zero the 'ts' value will be used.
set shiftwidth=0

" numbers of spaces a <Tab> inserts when editing, 0 to disable
" set softtabstop=2

" Round indent to multiple of 'shiftwidth'.  Applies to > and <
" set shiftround

set cindent
set smartindent
" set autoindent
set wrap
set hlsearch
" set cursorline
" set smarttab
set fileformats=unix,dos
set nobackup
set diffopt=filler,horizontal
set grepprg=grep\ -nH
set iminsert=0
set imsearch=0
set laststatus=2
set noundofile
" set rnu
set splitright
set splitbelow

set list
set listchars=tab:.\ ,trail:-,extends:>,precedes:<,nbsp:+

" let php_sql_query = 1
" let php_folding = 1
" set foldmethod=manual
let mapleader=','

let s:termcolor = 'slate'
let s:termdiffcolor = 'default'

" }}}

" {{{ plugin settings

" plugin:syntastic
" :help syntastic_mode_map
let g:syntastic_mode_map = {
            \ "mode": "active",
            \ "passive_filetypes": ["python"] }
let g:syntastic_javascript_checkers = ['jshint']
let g:syntastic_python_python_exe = 'python'
" let g:syntastic_php_checkers = ["php", "phpcs", "phpmd"]
let g:syntastic_php_checkers = ["php"]

" plugin:ctrlp
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlPMixed'
let g:ctrlp_by_filename = 1
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_lazy_update = 1
let g:ctrlp_mruf_relative = 1

"SnipMate
let g:snips_author = 'Mony Xie'
let g:snipMate = { 'snippet_version' : 1 }

" vim-mark
" no default mappings
:let g:mw_no_mappings = 1

let g:fontsize#timeout = 0

" editor-config
let g:EditorConfig_exclude_patterns = ['fugitive://.*', 'scp://.*']

" align
" see :h align
let g:Align_xstrlen=3

" }}}

" {{{ custom functions
"=====================================================================================
" custom functions
"=====================================================================================

"custom title
function! s:MyTitleLine()
    let line = " %m"
    let cd = fnamemodify(getcwd(), ":~")                    " current directory
    if cd != "~" && cd != "/" && cd != "~/"
        let cd = fnamemodify(cd, ":t")
    endif
    let line .= cd
    if expand("%") != ""
        let line .= " - " . expand("%:.")                      " current file %m is modified indicator
    endif
    if &diff
        let line .= 'DIFF'
    endif
    return line
endfunction

" }}}

" {{{ key mappings
"=====================================================================================
" maps
"=====================================================================================

"nerdtree
map <F3> <Esc><Esc>:NERDTreeToggle<CR>
map <leader><F3> <Esc><Esc>:NERDTreeMirror<CR>
nmap <leader>gt :NERDTreeFind<CR>
let NERDTreeMinimalUI=1

" CTRL+h/j/k/l to navigate between windows
noremap <silent> <C-h> <C-W>h
noremap <silent> <C-j> <C-W>j
noremap <silent> <C-k> <C-W>k
noremap <silent> <C-l> <C-W>l
inoremap <silent> <C-h> <C-\><C-O><C-W>h
inoremap <silent> <C-j> <C-\><C-O><C-W>j
inoremap <silent> <C-k> <C-\><C-O><C-W>k
inoremap <silent> <C-l> <C-\><C-O><C-W>l

" CTRL+BACKSPACE to delete one word in insert mode
inoremap <C-bs> <Esc>dbs
" CTRL+DEL to delete one word in insert mode
inoremap <C-del> <C-o>cw

"double click to highlight all occurrances
nnoremap <silent> <2-LeftMouse> :let @/='\V\<'.escape(expand('<cword>'), '\').'\>'<cr>:set hls<cr>viw
inoremap <silent> <2-LeftMouse> <esc>:let @/='\V\<'.escape(expand('<cword>'), '\').'\>'<cr>:set hls<cr>viw
nnoremap <silent> <3-LeftMouse> 2V

map <c-/> <c-_><c-_>

" noremap <a-`> :echo histget('search', -1) . "\n" . histget('search', -2) . "\n" . histget('search', -3) . "\n" . histget('search', -4) . "\n" . histget('search', -5)<cr>
nmap <a-1> :set fdl=1<cr>
nmap <a-2> :set fdl=2<cr>
nmap <a-3> :set fdl=3<cr>
nmap <a-4> :set fdl=4<cr>
nmap <a-5> :set fdl=5<cr>

" gp to visual select pasted text
nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]l'

" <leader>n to search recently modified/deleted text(" register)
nnoremap <leader>n :call setreg('/', '\V' . escape(getreg('"'), '\/'))<cr>n
" <leader>N to search recently modified/deleted text(" register) in a
" whole-word search manner
nnoremap <leader>N :call setreg('/', '\V\<' . escape(getreg('"'), '\/') . '\>')<cr>n

nnoremap =<space> =a}``

nnoremap <c-d> <LeftMouse>gelve
inoremap <c-d> <Esc><LeftMouse>gelve
vnoremap <c-d> <Esc><LeftMouse>gElvE
snoremap <c-d> <c-g>gElvE

nmap <leader>v :execute getline(".")<cr>

vmap <leader>h <Plug>(visualstar-*)N
nmap <leader>gc :Gcommit<cr>
nmap <leader>gs :Gstatus<cr>

nmap <space> za

nmap <c-s-t> :tabnew<cr>
imap <c-s-t> <esc><esc>:tabnew<cr>

nmap <a-p> ".p
nmap <a-P> ".P


" Allow saving of files as sudo when I forgot to start vim using sudo.
cmap w!! w !sudo tee > /dev/null %

" }}}

" {{{ autocommands
"=====================================================================================
" autocmds
"=====================================================================================
"
"title string
au BufEnter     * let &titlestring = <SID>MyTitleLine()
au BufReadPost  * let &titlestring = <SID>MyTitleLine()
au BufWritePost * let &titlestring = <SID>MyTitleLine()

au BufReadPost *.log :set nowrap | :set number
"Automatically change current directory to that of the file in the buffer  
"au BufEnter * sil! cd %:p:h

" set new file's fileformat
au BufNewFile * set ff=unix
" }}}

" {{{ Plugins

call plug#begin()
Plug 'junegunn/vim-easy-align'
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'tomtom/tlib_vim'
Plug 'MarcWeber/vim-addon-mw-utils'
" Plug 'garbas/vim-snipmate'
Plug 'tpope/vim-surround'
" Plug 'honza/vim-snippets'
Plug 'tpope/vim-fugitive'
Plug 'vim-scripts/Align'
Plug 'tomtom/tcomment_vim'
Plug 'scrooloose/syntastic'
Plug 'vim-scripts/ScrollColors'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'tpope/vim-sensible'
Plug 'editorconfig/editorconfig-vim'
Plug 'sheerun/vim-polyglot'
Plug 'thinca/vim-visualstar'
Plug 'drmikehenry/vim-fontsize'
Plug 'tpope/vim-sleuth'
Plug 'inkarkat/vim-ingo-library'
Plug 'inkarkat/vim-mark'
call plug#end()

" }}}

" ------------------------------------------------------------------
" Set color scheme
" ------------------------------------------------------------------
if &diff
    execute 'color ' . s:termdiffcolor
else
    execute 'color ' . s:termcolor
endif

syntax on
filetype plugin indent on

if filereadable(expand('~/.vimrc_local'))
    source ~/.vimrc_local
endif
