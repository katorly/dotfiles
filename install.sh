#!/usr/bin/env bash

DOTFILES_DIR=$(dirname "$(realpath "$0")") # Don't use $(pwd) because the path obtained in some CDEs is incorrect.
log() {
    echo -e "${PREFIX} $1"
}

show_help() {
    cat <<EOF
Usage: ./install.sh [component...]

Components:
  all              Install all components
  git              Configure Git
  shell            Configure Shell
  vscode           Configure VS Code
  ai|codex|claude  Configure Codex and Claude Code

Examples:
  ./install.sh
  ./install.sh git vscode
  ./install.sh shell ai
EOF
}

set_git() {
  log "🍴 Configuring Git"
  if command -v git &> /dev/null; then
    ln -sf "$DOTFILES_DIR/git/.gitconfig" ~/
    ln -sf "$DOTFILES_DIR/git/.gitignore_global" ~/
  else
    log "Git is not installed."
  fi
}

set_shell() {
  log "🐚 Configuring Shell"
  if [ "$SHELL" = "/bin/bash" ] || [ "$SHELL" = "/usr/bin/bash" ]; then
    # ln -sf "$DOTFILES_DIR/bash/.bash_profile" ~/
    # ln -sf "$DOTFILES_DIR/bash/.bashrc" ~/
    bash "$DOTFILES_DIR/bash/update_bashrc.sh"
  else
    log "Bash is not used for shell."
  fi
}

set_vscode() {
  log "💻 Configuring VS Code"
  if command -v code &> /dev/null; then # VS Code
    VSCODE_DIR="code"
    VSCODE_CONFIG_DIR="$HOME/.config/Code/User"
  elif command -v code-server &> /dev/null; then # code-server
    VSCODE_DIR="code-server"
    VSCODE_CONFIG_DIR="$HOME/.local/share/code-server/User"
  elif [ -x "/tmp/vscode-web/bin/code-server" ]; then # Coder CDE (VS Code)
    VSCODE_DIR="/tmp/vscode-web/bin/code-server"
    VSCODE_CONFIG_DIR="$HOME/.local/share/code-server/User"
  elif [ -x "/tmp/code-server/bin/code-server" ]; then # Coder CDE (code-server)
    VSCODE_DIR="/tmp/code-server/bin/code-server"
    VSCODE_CONFIG_DIR="$HOME/.local/share/code-server/User"
  elif [ -x "/ide/bin/gitpod-code" ]; then # Gitpod CDE
    VSCODE_DIR="/ide/bin/gitpod-code"
    VSCODE_CONFIG_DIR="$HOME/.config/Code/User"
  fi
  if command -v code &> /dev/null || command -v code-server &> /dev/null || [ -x "/tmp/vscode-web/bin/code-server" ] || [ -x "/tmp/code-server/bin/code-server" ] || [ -x "/ide/bin/gitpod-code" ]; then
    mkdir -p "$VSCODE_CONFIG_DIR"
    ln -sf "$DOTFILES_DIR/vscode/settings.json" "$VSCODE_CONFIG_DIR/"
    ln -sf "$DOTFILES_DIR/vscode/keybindings.json" "$VSCODE_CONFIG_DIR/"
    ln -sf "$DOTFILES_DIR/vscode/chatLanguageModels.json" "$VSCODE_CONFIG_DIR/"

    # Install extensions
    while IFS= read -r extension
    do
      $VSCODE_DIR --install-extension "$extension" --force
    done < "$DOTFILES_DIR/vscode/extensions.txt"
  else
    log "VS Code or code-server is not installed."
  fi
}

set_ai() {
  log "🤖 Configuring Codex, Claude Code"
  mkdir -p "$HOME/.codex"
  ln -sf "$DOTFILES_DIR/.codex/config.toml" "$HOME/.codex/"
  ln -sf "$DOTFILES_DIR/.codex/auth.json" "$HOME/.codex/"
  ln -sf "$DOTFILES_DIR/.codex/AGENTS.md" "$HOME/.codex/"
  mkdir -p "$HOME/.claude"
  ln -sf "$DOTFILES_DIR/.claude/config.json" "$HOME/.claude/"
  ln -sf "$DOTFILES_DIR/.claude/settings.json" "$HOME/.claude/"
  ln -sf "$DOTFILES_DIR/.claude/CLAUDE.md" "$HOME/.claude/"
}

SET_GIT=false
SET_SHELL=false
SET_VSCODE=false
SET_AI=false

install_all() {
  SET_GIT=true
  SET_SHELL=true
  SET_VSCODE=true
  SET_AI=true
}

if [ "$#" -eq 0 ]; then
  show_help
  exit 0
else
  for component in "$@"; do
    case "$component" in
      all)
        install_all
        ;;
      git)
        SET_GIT=true
        ;;
      shell)
        SET_SHELL=true
        ;;
      vscode)
        SET_VSCODE=true
        ;;
      ai|codex|claude)
        SET_AI=true
        ;;
      -h|--help)
        show_help
        exit 0
        ;;
      *)
        echo "Unknown component: $component" >&2
        show_help >&2
        exit 1
        ;;
    esac
  done
fi

PREFIX="\033[1m  >>\033[0m"
echo -e "\n\n\033[1m------ 🏃‍ Installing dotfiles... ------\n"

[ "$SET_GIT" = true ] && set_git
[ "$SET_SHELL" = true ] && set_shell
[ "$SET_VSCODE" = true ] && set_vscode
[ "$SET_AI" = true ] && set_ai

echo -e "\n\033[1m-------- ✅ dotfiles installed! --------\n\n"