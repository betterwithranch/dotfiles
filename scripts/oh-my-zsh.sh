#!/usr/bin/env zsh

echo
echo
echo "Oh-my-zsh"
echo
echo

# define config alias locally since the dotfiles
# aren't installed on the system yet
function config {
  /usr/bin/git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME" "$@"
}

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Oh-my-zsh is not installed. Installing ..."
  if ! sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; then
    echo "Error installing oh-my-zsh. Exiting ..."
    return 1
  fi

  if ! config checkout .zshrc || ! rm ~/.zshrc.pre-oh-my-zsh; then
    echo "Error restoring .zshrc file. Exiting ..."
    return 1
  fi
fi

source ~/.zshrc

echo "Oh-my-zsh is installed"
