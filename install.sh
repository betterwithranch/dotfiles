# cd ~/.zsh
# curl -o _git https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.zsh
# cd -

mkdir -p ~/.vim/ftplugin
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

# link gitignore to default position
mkdir -p ~/.config/git

echo "removing aliases"
rm ~/.aliases

if [[ ! -L ~/.aliases ]]; then
  echo "adding aliases"
  ln -s ~/dev/dotfiles/.zshrc ~/.aliases
fi

echo "removing git ignore"
rm ~/.config/git/ignore

if [[ ! -L ~/.config/git/ignore ]]; then
  echo "adding git ignore"
  ln -s ~/dev/dotfiles/.gitignore ~/.config/git/ignore
fi
