mkdir -p ~/backups
for f in .bash_profile .bashrc .editrc .gemrc .gitconfig .inputrc .irbrc .pryrc .rspec .tmux.conf .vim .vimrc
do
mv ~/$f ~/backups/$f
ln -s ~/dev/dotfiles/$f ~/$f
done


