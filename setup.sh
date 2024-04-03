BASE=$(pwd)
pushd $HOME

[ -d shell_custom ] && { echo "shell_custom directory already exists"; exit 1; }
[ -r .zshrc.orig ] && { echo ".zshrc.orig already exists"; exit 1; }
[ -r .vimrc.orig ] && { echo ".vimrc.orig already exists"; exit 1; }

[ -r .zshrc ] && mv .zshrc .zshrc.orig
ln -s $BASE/custom.sh .zshrc

mkdir $_custom
for _item in $(echo "alias.sh pip.sh podman.sh python.sh settings.sh virtenv.sh"); do
    ln -s $BASE/$_item $_custom
done

[ ! -r .config ] && mkdir .config
[ ! -r .config/nvim ] && mkdir .config/nvim
[ ! -r .config/nvim/init.vim ] && ln -s $BASE/neovim .config/nvim/init.vim

[ ! -r .gitconfig ] && .cat $BASE/gitconfig | sed 's/GIT-EMAIL/${GIT_EMAIL:-git-email-here}/' > .gitconfig

[ ! -d bin ] && mkdir bin
[ ! -r bin/gdf ] && ln -s $BASE/gdf bin/gdf

if [ ! -d .fzf ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
fi

popd
