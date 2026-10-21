" syntax highlighting
syntax on
filetype plugin indent on

" indentation
set autoindent
set expandtab
set shiftwidth=4
set smarttab
set tabstop=4

" line numbers
set number
set relativenumber

" show cursorline as grey background
set cursorline
highlight clear CursorLine
highlight CursorLine ctermbg=255

" vertical bar at column 88 for python
highlight ColorColumn ctermbg=255
autocmd BufRead *.py setlocal colorcolumn=88

" clean up trailing whitespace on save
autocmd BufWritePre * :%s/\s\+$//e

" search
set hlsearch  " highlight
set incsearch  " highlight while typing
set ignorecase
set smartcase  " uppercase letters in search disable ignorecase

" no backup file
set nobackup
set noswapfile
set nowritebackup

" keep tabs for Makefile
au BufRead,BufNewFile Makefile* set noexpandtab

" make backspaces more powerfull
set backspace=indent,eol,start

" bring in FZF
set rtp+=~/.fzf
:map <C-x><C-f> :FZF<Enter>
:map <C-x><C-e> :FZF -e<Enter>
