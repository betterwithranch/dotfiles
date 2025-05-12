# cd ~/.zsh
# curl -o _git https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.zsh
# cd -

for f in .asdfrc .bash_profile .bashrc .editrc .gemrc .gitconfig .inputrc .irbrc .pryrc .rspec .tmux.conf .zshrc
do
  if [[ -L ~/$f ]]; then
    echo "removing symbolic link ~/$f"
    rm -f ~/$f
  fi

  if [[ -f ~/$f ]]; then
    echo "backing up ~/$f"
    mv ~/$f ~/backups/$f
    ls ~/$f
  fi

  echo "linking ~/$f"
  ln -s ~/dev/dotfiles/$f ~/$f
done

echo "removing aliases"
rm -f ~/.aliases

if [[ ! -L ~/.aliases ]]; then
  echo "adding aliases"
  ln -s ~/dev/dotfiles/.zshrc ~/.aliases
fi

echo "symlinking .config directories"
for f in .config/*
do

  if [[ -L ~/$f ]]; then
    echo "removing symbolic link ~/$f"
    rm -f ~/$f
  fi

  if [[ -f ~/$f ]]; then
    echo "backing up ~/.config/$f"
    mv ~/$f ~/backups/$f
    ls ~/$f
  fi

  echo "linking ~/$f"
  ln -s ~/dev/dotfiles/$f ~/$f
done
