" Filename: .vimrc
" Author: Mony Xie(monyxie at gmail dot com)

" vim:fdm=marker


" {{{ VimDispatch
" Open files of different types in seperated vim instances
" (or servers)
" This must be done BEFORE ':set encoding=utf8' to make sure
" the encoding of the filenames stay unchanged
" function! s:GetSvrName(ext)
"     if !exists('s:ext2srv')
"         let s:ext2srv = [
"                     \['VIM', ['vim']],
"                     \['PHP', ['php', 'phtml']],
"                     \['JS', ['js']],
"                     \['CSS', ['css']],
"                     \['HTML', ['htm', 'html', 'dwt', 'lbi']],
"                     \['PY', ['py']],
"                     \['TXT', ['txt', 'text', 'md', 'mkd']],
"                     \['C', ['c', 'cpp', 'h', 'hpp']],
"                     \['LOG', ['log']],
"                     \['INI', ['ini', 'conf']],
"                     \['BAT', ['bat', 'sh']],
"                     \]
"     endif
"     for srv in s:ext2srv 
"         for extname in srv[1]
"             if a:ext == extname
"                 return srv[0]
"                 " break
"             endif
"         endfor
"     endfor
"     return 'GVIM'
" endfunction
" 
" function! s:VimDispatch()
"     if !exists('s:norelist')
"         let s:norelist = ['COMMIT_EDITMSG']
"     endif
"     if &diff || !argc()
"         return 0
"     endif
"     let l:argv = argv()
"     for a in l:argv
"         let l:sp = expand('/')
"         let l:lastsp = strridx(a, l:sp)
"         let l:file = strpart(a, l:lastsp + 1)
"         let l:lastdot = strridx(l:file, '.')
"         let l:ext = strpart(l:file, l:lastdot + 1)
" 		for noreitem in s:norelist 
" 			if l:ext == noreitem
" 				return 0
" 			endif
" 		endfor
"         let l:srvname = <SID>GetSvrName(l:ext)
"         exe 'silent !start gvim --servername ' . l:srvname . ' --remote-tab-silent ' . shellescape(a, 1)
"         call remote_foreground(l:srvname)
"     endfor
"     exit
" endfunction
" 
" call <SID>VimDispatch()

" }}}

" {{{ lang, enc, guiopt, cp and behavior
"====================================================================
"some options need to be set earlier
set langmenu=en_US.UTF-8
let $LANG='en'
"language messages en
set guioptions+=Lr
set guioptions-=T
set encoding=utf8
set fileencodings=utf8,utf16,cp936,latin1
set nocompatible
if has('win32')
    source $VIMRUNTIME/vimrc_example.vim
    source $VIMRUNTIME/mswin.vim
    behave mswin
endif

" }}}

" {{{ general options, font, colorscheme
"set guifont=ProggyTinyBP:h7
"set guifont=Lucida_Console:h9:cANSI
" set guifont=Anonymous:h10:cANSI
set guifont=Monaco:h10:cANSI
set linespace=-3
" set guifont=Anonymous_Pro:h8:cANSI
" set guifont=PT_Mono:h10:cANSI
" set guifont=osaka_unicode:h10:cANSI
" set guifont=Luxi_Mono:h9:cANSI
" set guifont=fixed613
" set guifont=Envy_Code_R:h9:cANSI
" set guifont=Consolas:h9:cANSI
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
" set expandtab
set autoindent
set fileformats=dos,unix
set nobackup
set diffopt=filler,horizontal
set grepprg=grep\ -nH

let g:colorv_loaded = 1
" let php_sql_query = 1
" let php_folding = 1
let mapleader=','

let s:color = 'solarized'
let s:diffcolor = 'solarized'
let s:termcolor = 'default'
let s:termdiffcolor = 'default'

" let g:html_indent_inctags = "html,body,head,tbody"

" }}}

" {{{ Colorscheme Config
" ------------------------------------------------------------------
" Solarized Colorscheme Config
" ------------------------------------------------------------------
function! s:SolarizedConfig()
    let g:solarized_contrast='high'    "default value is normal
    let g:solarized_visibility='high'    "default value is normal
    let g:solarized_diffmode='high'    "default value is normal
    let g:solarized_hitrail=1    "default value is 0
    "syntax enable
    set background=dark
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

" }}}

" {{{ IndentGuides
let g:indent_guides_start_level = 2
let g:indent_guides_guide_size = 1
let g:indent_guides_enable_on_vim_startup = 1

"SnipMate
let g:snips_author = 'Mony Xie'

if &diff
    set lines=999
    set columns=999
	" ignore whitespaces in diff mode
	set diffopt+=iwhite
endif

" }}}

" {{{ MyDiff()
set diffexpr=MyDiff()
function! MyDiff()
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
    if &sh =~ "\<cmd"
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

" }}}

" {{{ custom functions
"=====================================================================================
" custom functions
"=====================================================================================

function! s:DebugRun(cmd)
    :w
    execute '! ' . a:cmd . ' %'
endfunction

"custom title
function! s:MyTitleLine()
	if !exists('g:is_admin')
        let g:is_admin = (filewritable($windir . '/system32/drivers'))
	endif
    " if match(v:servername, '^GVIM$') != -1
    "     "default server
    "     let l:servername = ''
    " else
    "     let l:servername = v:servername
    " endif
    " let line =  "" . l:servername . "<%m" . expand("%:t") . ">" . expand("%:p:h") . " - VIM"
    let line =  "" . "<%m" . expand("%:t") . ">" . expand("%:p:h") . " - VIM"
	if &diff
		let line .= 'DIFF'
	endif
	if g:is_admin
        let line .= ' #'
	endif
    return line
endfunction

function! s:MyCfile()
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
function! s:MyJumpMyCfile()
    let s:mycfile = expand('<cfile>')
    if filereadable(s:mycfile)
        exe 'tabe ' . s:mycfile
    else
        if strpart(s:mycfile, 0, 1) == '/' || strpart(s:mycfile, 0, 1) == '\\'
            let s:mycfile2 = strpart(s:mycfile, 1)
            if filereadable(s:mycfile2)
                exe 'tabe ' . s:mycfile2
            endif
        endif
    endif
endfunction

function! s:MyOpenHttpLink()
	call ShellOpen(expand('<cWORD>'))
endfunction

" open a url or file with associated program
" http://vim.wikia.com/wiki/Open_a_web-browser_with_the_URL_in_the_current_line
function! ShellOpen(url)
	let l:old_reg=@"
	exec 'silent!!start /b cmd /c start "" ' . shellescape(a:url) . ''
	let @"=l:old_reg
endfunction

" }}}

" {{{ key mappings
"=====================================================================================
" maps
"=====================================================================================

"nerdtree
map <F3> :NERDTreeToggle<CR>
map <F3> <Esc><Esc>:NERDTreeToggle<CR>

" 
map <F1> <C-PageUp>
map <F2> <C-PageDown>

nmap <Space> 15j
nmap <S-Space> 15k


nmap d' vi'dhPl2x<Esc>
nmap d" vi"dhPl2x<Esc>

" CTRL+h/j/k/l to navigate between windows
noremap <silent> <C-h> <C-W>h
noremap <silent> <C-j> <C-W>j
noremap <silent> <C-k> <C-W>k
noremap <silent> <C-l> <C-W>l
inoremap <silent> <C-h> <C-\><C-O><C-W>h
inoremap <silent> <C-j> <C-\><C-O><C-W>j
inoremap <silent> <C-k> <C-\><C-O><C-W>k
inoremap <silent> <C-l> <C-\><C-O><C-W>l

"double click to highlight all occurrances
nnoremap <silent> <2-LeftMouse> :let @/='\V\<'.escape(expand('<cword>'), '\').'\>'<cr>:set hls<cr>viw<c-g>
inoremap <silent> <2-LeftMouse> <esc>:let @/='\V\<'.escape(expand('<cword>'), '\').'\>'<cr>:set hls<cr>viw<c-g>
nnoremap <silent> <3-LeftMouse> V

nmap <silent> <MiddleMouse> <LeftMouse>:call <SID>MyJumpMyCfile()<cr>

map <leader>c <c-_><c-_>

noremap <a-`> :echo histget('search', -1) . "\n" . histget('search', -2) . "\n" . histget('search', -3) . "\n" . histget('search', -4) . "\n" . histget('search', -5)<cr>
noremap <a-1> /<up><cr>
noremap <a-2> /<up><up><cr>
noremap <a-3> /<up><up><up><cr>
noremap <a-4> /<up><up><up><up><cr>
noremap <a-5> /<up><up><up><up><up><cr>

" gp to select pasted text in visual mode
nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]l'

" ctrl-shift-n to search recently modified/deleted text(" register)
nnoremap <c-s-n> :exec '/\V' . escape(getreg('"'), '\/')<CR>

nnoremap =<space> =a}``

nnoremap cu ct_

iunmap <c-y>

" }}}

" {{{ autocommands
"=====================================================================================
" autocmds
"=====================================================================================
"php and python execution
au FileType php map <F5> :call <SID>DebugRun('php')<cr>
au FileType php imap <F5> <Esc>:call <SID>DebugRun('php')<cr>
au FileType python map <F5> :call <SID>DebugRun('python')<cr>
au FileType python imap <F5> <Esc>:call <SID>DebugRun('python')<cr>

"title string
au BufEnter     * let &titlestring = <SID>MyTitleLine()
au BufReadPost  * let &titlestring = <SID>MyTitleLine()
au BufWritePost * let &titlestring = <SID>MyTitleLine()

au BufReadPost *.log :set nowrap | :set number
"Automatically change current directory to that of the file in the buffer  
au BufEnter * sil! cd %:p:h
" }}}

" {{{ menus

let s:keepcpo = &cpo
set cpo&vim
if has("menu") && has("gui_running") && &go =~# 'm' && !exists("s:mymenu")
 let s:mymenu= 1
  anoremenu <silent> 11111.01 ★.Select\ All :normal ggVG<CR>
  anoremenu <silent> 11111.05 ★.-sep1- <Nop>
  anoremenu <silent> 11111.10 ★.\*Remove\ trailing\ spaces :g/\v^/s/\v\s+$//<CR>
  anoremenu <silent> 11111.20 ★.Compress\ empty\ lines :call <sid>CompressEL()<CR>
  anoremenu <silent> 11111.30 ★.\*Remove\ \^M :g/\v^/s/\v<C-V><CR>//<CR>``
  anoremenu <silent> 11111.35 ★.\*Delete\ matched :g//d<CR>
  anoremenu <silent> 11111.35 ★.\*Delete\ unmatched :v//d<CR>
  anoremenu <silent> 11111.35 ★.\*Join\ begin\ w/o :call JoinBeginWo()<CR>
  anoremenu <silent> 11111.40 ★.-sep2- <Nop>
  anoremenu <silent> 11111.50 ★.CMD :silent!!start cmd<CR>
  anoremenu <silent> 11111.60 ★.BASH :silent!!start sh --login -i<CR>
  anoremenu <silent> 11111.70 ★.Explore :call <sid>Explore()<CR>
  function s:GenerateSeq(begin, end, step)
  endfunction
  function s:JoinBeginWo()
	  silent! exec '%s/\v\n(' . histget('search', -1) . '\v)@!'
  endfunction
  function s:CompressEL()
	  silent! exec '%s/\v%^\n+/\r/g'
	  silent! exec '%s/\v\n+%$/\r/g'
	  silent! exec '%s/\v\n{2}\zs\n+//g'
  endfunction
  function s:Explore()
	  silent exec '!start explorer '.shellescape(expand('%:p:h'))
  endfunction
endif
let &cpo=s:keepcpo
unlet s:keepcpo

" }}}
"

execute pathogen#infect()

" ------------------------------------------------------------------
" Set color scheme
" ------------------------------------------------------------------
if has('gui_running')
    if &diff
        if s:diffcolor == 'solarized'
            call <SID>SolarizedConfig()
        endif
        execute 'color ' . s:diffcolor
    else
        if s:color == 'solarized'
            call <SID>SolarizedConfig()
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

