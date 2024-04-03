" pip install pyvenv jedi flake8 in virtual environment
" place link to flake8 in ~/bin/
" lock python by pointing to virtual environment
let g:python3_host_prog = '/Users/bob/venv-3.12/bin/python'

" bring in FZF
set rtp+=~/.fzf
" key mapping: fuzzy search and exact search
:map <C-x><C-f> :FZF<Enter>
:map <C-x><C-e> :FZF -e<Enter>

" vertical bar at column 80 for python
hi ColorColumn ctermbg=255
autocmd BufRead *.py setlocal colorcolumn=80

" clean up trailing whitespace on save
autocmd BufWritePre * :%s/\s\+$//e

" leave a few lines at the bottom
:set scrolloff=5

" plugins
" https://jdhao.github.io/2018/12/24/centos_nvim_install_use_guide_en/
call plug#begin('~/.config/nvim/plugged')

  " UI related
  Plug 'chriskempson/base16-vim'
  Plug 'vim-airline/vim-airline'
  Plug 'vim-airline/vim-airline-themes'

  " Better Visual Guide
  Plug 'Yggdroot/indentLine'

  " syntax check
  Plug 'neomake/neomake'

  " Autocomplete
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
  Plug 'zchee/deoplete-jedi'

call plug#end()

" auto completion
let g:deoplete#enable_at_startup = 1

" lint
let g:neomake_python_enabled_makers = ['flake8']
call neomake#configure#automake('wni', 500)

" UI configuration
syntax on
syntax enable
" colorscheme
let base16colorspace=256
" colorscheme base16-gruvbox-dark-hardly
" set background=light
"
colorscheme base16-atelier-forest-light
" colorscheme base16-atelier-heath-light
" colorscheme base16-atelier-lakeside-light
" colorscheme base16-atelier-seaside-light
" True Color Support if it's avaiable in terminal
if has("termguicolors")
    set termguicolors
endif
if has("gui_running")
  set guicursor=n-v-c-sm:block,i-ci-ve:block,r-cr-o:blocks
endif
set number
set relativenumber
set hidden
set mouse=a
set noshowmode
set noshowmatch
set nolazyredraw
" Turn off backup
set nobackup
set noswapfile
set nowritebackup
" Search configuration
set ignorecase                    " ignore case when searching
set smartcase                     " turn on smartcase
" Tab and Indent configuration
set expandtab
set tabstop=4
set shiftwidth=4
