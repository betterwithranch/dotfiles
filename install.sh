mkdir -p ~/backups
for f in .asdfrc .bash_profile .bashrc .editrc .gemrc .gitconfig .inputrc .irbrc .pryrc .rspec .tmux.conf .vim .vimrc
do
  if [[ -f "$f" ]]; then
    mv ~/$f ~/backups/$f
  fi
  ln -s ~/dev/dotfiles/$f ~/$f
done

# link gitignore to default position
mkdir -p ~/.config/git

if [[ ! -f "$f" ]]; then
  ln -s ~/dev/dotfiles/.gitignore ~/.config/git/ignore
fi

if [[ ! -f "$f" ]]; then
  ln -s ~/dev/dotfiles/.zhsrc ~/.aliases
fi
