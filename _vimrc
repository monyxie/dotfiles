set guioptions+=Lr
set guioptions-=T
set encoding=utf8
set fileencodings=utf8,cp936,latin1
set nocompatible
source $VIMRUNTIME/vimrc_example.vim
source $VIMRUNTIME/mswin.vim
behave mswin
lang messages zh_CH.UTF-8

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
let s:color = 'github'
let s:diffcolor = 'molokaini'

"IndentGuides
let g:indent_guides_start_level = 2
let g:indent_guides_guide_size = 1
let g:indent_guides_enable_on_vim_startup = 1

"SnipMate
let g:snips_author = 'Mony Xie'

if &diff
    execute 'color ' . s:diffcolor
    if has('win32')
        "au GUIEnter * simalt ~x | "x on an English Windows version. n on a French one
        "above didn't work sometimes
        set lines=999
        set columns=999
    endif
else
    execute 'color ' + s:color
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

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

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
