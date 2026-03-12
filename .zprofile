if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
  ASDF_SH="$(brew --prefix asdf)/libexec/asdf.sh"
  if [ -f "$ASDF_SH" ]; then
    . "$ASDF_SH"
  fi
fi

if command -v ngrok &>/dev/null; then
  eval "$(ngrok completion)"
fi

