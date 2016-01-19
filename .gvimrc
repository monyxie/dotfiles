"set guifont=ProggyTinyBP:h7
"set guifont=Lucida_Console:h9:cANSI
" set guifont=Anonymous:h8:cANSI
" set guifont=Monaco:h10:cANSI
" set linespace=-2
" set guifont=Anonymous_Pro:h10:cANSI
" set guifont=Anonymice_Powerline:h10:cANSI
" set guifont=monofur_for_Powerline:h10:cANSI
set guifont=PT_Mono:h12
" set guifont=osaka_unicode:h10:cANSI
" set guifont=Luxi_Mono:h9:cANSI
" set guifont=fixed613
" set guifont=Envy_Code_R:h9:cANSI
" set guifont=Consolas:h9:cANSI
" set guifont=NSimsun:h9:cANSI

let s:color = 'zenburn'
let s:diffcolor = 'solarized'

" don't set window cols and rows in console
if &diff
	set lines=999
	set columns=999
	" ignore whitespaces in diff mode
	set diffopt+=iwhite
else
	set columns=128
	set lines=30
endif

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
