# cd ~/.zsh
# curl -o _git https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.zsh
# cd -

mkdir -p ~/backups/ftplugin
for f in .asdfrc .bash_profile .bashrc .editrc .gemrc .gitconfig .inputrc .irbrc .pryrc .rspec .tmux.conf .vimrc .vim/ftplugin/*.vim
do
  if [[ -L ~/$f ]]; then
    echo "removing symbolic link ~/$f"
    rm ~/$f
  fi

  if [[ -f ~/$f ]]; then
    echo "backing up ~/$f"
    mv ~/$f ~/backups/$f
    ls ~/$f
  fi

  echo "linking ~/$f"
  ln -s ~/dev/dotfiles/$f ~/$f
done

if [[ -f "~/.aliases" ]]; then
  ln -s ~/dev/dotfiles/.zshrc ~/.aliases
fi

# link gitignore to default position
mkdir -p ~/.config/git

if [[ ! -f "$f" ]]; then
  ln -s ~/dev/dotfiles/.gitignore ~/.config/git/ignore
fi

if [[ ! -f "$f" ]]; then
  ln -s ~/dev/dotfiles/.zhsrc ~/.aliases
fi
