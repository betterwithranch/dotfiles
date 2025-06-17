eval "$(/opt/homebrew/bin/brew shellenv)"
. $(brew --prefix asdf)/libexec/asdf.sh

if command -v ngrok &>/dev/null; then
  eval "$(ngrok completion)"
fi

