"some options need to be set earlier
set langmenu=en_US.UTF-8
let $LANG="en"
"language messages en
set guioptions+=Lr
set guioptions-=T
set encoding=utf8
set fileencodings=utf8,cp936,latin1
set nocompatible
if has('win32')
    source $VIMRUNTIME/vimrc_example.vim
    source $VIMRUNTIME/mswin.vim
    behave mswin
endif

"set guifont=ProggyTinyBP:h7
"set guifont=ProggyTinyBP:h7
"set guifont=Lucida_Console:h9:cANSI
"set guifont=Anonymous:h8:cANSI
set guifont=Anonymous_Pro:h8:cANSI
set number
set shiftwidth=4
set cindent
set smartindent
set wrap
set columns=128
set lines=48
set hlsearch
set cursorline
set tabstop=4
set smarttab
set shiftround
set expandtab
set autoindent
set fileformats=dos,unix
set nobackup
set diffopt=filler,vertical
set grepprg=grep\ -nH

let s:color = 'solarized'
let s:diffcolor = 'solarized'
let s:termcolor = 'default'
let s:termdiffcolor = 'default'

" ------------------------------------------------------------------
" Solarized Colorscheme Config
" ------------------------------------------------------------------
function SolarizedConfig()
    let g:solarized_contrast="high"    "default value is normal
    let g:solarized_visibility="high"    "default value is normal
    let g:solarized_diffmode="high"    "default value is normal
    let g:solarized_hitrail=1    "default value is 0
    "syntax enable
    set background=light
    "colorscheme solarized
    " ------------------------------------------------------------------
    " The following items are available options, but do not need to be
    " included in your .vimrc as they are currently set to their defaults.

    " let g:solarized_termtrans=0
    " let g:solarized_degrade=0
    " let g:solarized_bold=1
    " let g:solarized_underline=1
    " let g:solarized_italic=1
    " let g:solarized_termcolors=16
    " let g:solarized_menu=1
endfunction

" ------------------------------------------------------------------
" Colorscheme Config
" ------------------------------------------------------------------
if has("gui_running")
    if &diff
        if s:diffcolor == 'solarized'
            call SolarizedConfig()
        endif
        execute 'color ' . s:diffcolor
    else
        if s:color == 'solarized'
            call SolarizedConfig()
        endif
        execute 'color ' . s:color
    endif
else "no gui
    if &diff
        execute 'color ' . s:termdiffcolor
    else
        execute 'color ' . s:termcolor
    endif
endif

let php_sql_query = 1
"let php_folding = 1

"IndentGuides
let g:indent_guides_start_level = 2
let g:indent_guides_guide_size = 1
let g:indent_guides_enable_on_vim_startup = 1

"SnipMate
let g:snips_author = 'Mony Xie'

if &diff
    set lines=999
    set columns=999
endif


set diffexpr=MyDiff()
function MyDiff()
  let opt = '-a --binary '
  if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
  if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
  let arg1 = v:fname_in
  if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif
  let arg2 = v:fname_new
  if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif
  let arg3 = v:fname_out
  if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif
  let eq = ''
  if $VIMRUNTIME =~ ' '
    if &sh =~ '\<cmd'
      let cmd = '""' . $VIMRUNTIME . '\diff"'
      let eq = '"'
    else
      let cmd = substitute($VIMRUNTIME, ' ', '" ', '') . '\diff"'
    endif
  else
    let cmd = $VIMRUNTIME . '\diff'
  endif
  silent execute '!' . cmd . ' ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3 . eq
endfunction

"=====================================================================================
" custom functions
"=====================================================================================

function DebugRun(cmd)
    :w
    execute '!' . a:cmd . ' %'
endfunction

"custom title
function MyTitleLine()
    if match(v:servername, "^GVIM\\d*$") != -1
        "default server
        let l:servername = ''
    else
        let l:servername = v:servername
    endif
    let line =  "" . l:servername . "<%m" . expand("%:t") . ">" . expand("%:p:h") . " - VIM"
    return line
endfunction

function MyCfile()
    let s:mycfile = expand('<cfile>')
    if !filereadable(s:mycfile)
        if strpart(s:mycfile, 0, 1) == '/' || strpart(s:mycfile, 0, 1) == '\\'
            let s:mycfile2 = strpart(s:mycfile, 1)
            if filereadable(s:mycfile2)
                let s:mycfile = s:mycfile2
            endif
        endif
    endif
    return s:mycfile
endfunction

"
function MyJumpMyCfile()
    let s:mycfile = expand('<cfile>')
    if filereadable(s:mycfile)
        :exec 'tabe ' . s:mycfile
    else
        if strpart(s:mycfile, 0, 1) == '/' || strpart(s:mycfile, 0, 1) == '\\'
            let s:mycfile2 = strpart(s:mycfile, 1)
            if filereadable(s:mycfile2)
                :exec 'tabe ' . s:mycfile2
            endif
        endif
    endif
endfunction

function VimClientHandle()
    let l:argv = argv();
    for a in l:argv
        let l:sp = expand("/")
        let l:lastsp = strridx(a, l:sp)
        let l:file = strpart(a, l:lastsp + 1)
        let l:lastdot = strridx(l:file, ".")
        let l:ext = strpart(l:file, l:lastdot + 1)
        let l:re = "\\c^" . l:ext . "$"
        echo l:re
        let l:srvlst = split(serverlist())
        let l:srvex = 0
        for srv in l:srvlst
            echo srv
            if match(srv, l:re) == 0
                exe "!start gvim --servername " . srv . " --remote-tab-silent \"" . a . "\""
                call remote_foreground(srv)
                let l:srvex = 1
                break
            endif
        endfor
        if (l:srvex == 1)
            exit
        else
            exe "!start gvim --servername " . srv . " --remote-tab-silent \"" . a . "\""
            file
        endif
    endfor
    exit
endfunction

"=====================================================================================
" maps
"=====================================================================================

"nerdtree
map <F3> :NERDTreeToggle<CR>
map <F3> <Esc><Esc>:NERDTreeToggle<CR>

nmap <F1> :tabp<CR>
nmap <F2> :tabn<CR>
imap <F1> <Esc><Esc>:tabp<CR>
imap <F2> <Esc><Esc>:tabn<CR>

nmap <Space> 15j
nmap <S-Space> 15k


nmap d' vi'dhPl2x<Esc>
nmap d" vi"dhPl2x<Esc>

" CTRL+h/j/k/l to navigate between windows
map <silent> <C-h> :wincmd h<CR>
map <silent> <C-j> :wincmd j<CR>
map <silent> <C-k> :wincmd k<CR>
map <silent> <C-l> :wincmd l<CR>
imap <silent> <C-h> <Esc>:wincmd h<CR>
imap <silent> <C-j> <Esc>:wincmd j<CR>
imap <silent> <C-k> <Esc>:wincmd k<CR>
imap <silent> <C-l> <Esc>:wincmd l<CR>

"double click to highlight all occurrances
nnoremap <silent> <2-LeftMouse> :let @/='\V\<'.escape(expand('<cword>'), '\').'\>'<cr>:set hls<cr>viw<c-g>
inoremap <silent> <2-LeftMouse> <esc>:let @/='\V\<'.escape(expand('<cword>'), '\').'\>'<cr>:set hls<cr>viw<c-g>
nnoremap <silent> <3-LeftMouse> V

nmap <silent> <MiddleMouse> <LeftMouse>:call MyJumpMyCfile()<cr>

"=====================================================================================
" autocmds
"=====================================================================================
"php and python execution
au FileType php map <F5> :call DebugRun('php')<cr>
au FileType php imap <F5> <Esc>:call DebugRun('php')<cr>
au FileType python map <F5> :call DebugRun('python')<cr>
au FileType python imap <F5> <Esc>:call DebugRun('python')<cr>

"title string
au BufEnter     * let &titlestring = MyTitleLine()
au BufReadPost  * let &titlestring = MyTitleLine()
au BufWritePost * let &titlestring = MyTitleLine()

au BufReadPost *.log :set nowrap | :set number
