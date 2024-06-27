neovim
======

neovim configuration

# python smarts

Use `vim-plug` to bring in fancy tools.

1. `brew install neovim`
0. https://github.com/junegunn/vim-plug:
    `sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'`
0. isolate a python environment with venv
0. `pip install pynvim jedi flake8` in the virtual env
0. export `VIM_PYTHON3` to point to the venv's python executable
0. make sure `init.vim` is linked to `~/.config/nvim/init.vim`
0. `nvim + :PlugInstall`

# basic

For basic `vim` niceties, link `vimrc` to `~.vimrc`.
