mkdir -p ~/backups
for f in .asdfrc .bash_profile .bashrc .editrc .gemrc .gitconfig .gitignore .inputrc .irbrc .pryrc .rspec .tmux.conf .vim .vimrc
do
  if [[ -f "$f" ]]; then
    mv ~/$f ~/backups/$f
  fi
  ln -s ~/dev/dotfiles/$f ~/$f
done


