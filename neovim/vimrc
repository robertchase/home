syntax on
set number
set autoindent
set tabstop=4
set shiftwidth=4
set expandtab
set hlsearch
set ruler
set softtabstop=4

au BufRead,BufNewFile Makefile* set noexpandtab

" make backspaces more powerfull
set backspace=indent,eol,start

" nicer vimdiff colors
highlight DiffChange cterm=none ctermfg=black ctermbg=LightGreen
highlight DiffText cterm=none ctermfg=black ctermbg=LightRed

" vertical bar at column 80 for python
hi ColorColumn ctermbg=255
autocmd BufRead *.py setlocal colorcolumn=80

" clean up trailing whitespace on save
autocmd BufWritePre * :%s/\s\+$//e

" bring in FZF
set rtp+=~/.fzf
" key mapping: fuzzy search and exact search
:map <C-x><C-f> :FZF<Enter>
:map <C-x><C-e> :FZF -e<Enter>
