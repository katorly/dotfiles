#!/usr/bin/env bash

DOTFILES_DIR=$(dirname "$(realpath "$0")") # Don't use $(pwd) because the path obtained in some CDEs is incorrect.
log() {
    echo -e "${PREFIX} $1"
}

PREFIX="\033[1m  >>\033[0m"
echo -e "\n\n\033[1m------ 🏃‍ Installing dotfiles... ------\n"


log "🍴 Configuring Git"
if command -v git &> /dev/null; then
    ln -sf "$DOTFILES_DIR/git/.gitconfig" ~/
    ln -sf "$DOTFILES_DIR/git/.gitignore_global" ~/
else
    log "Git is not installed."
fi


log "🐚 Configuring Shell"
if [ "$SHELL" = "/bin/bash" ] || [ "$SHELL" = "/usr/bin/bash" ]; then
    # ln -sf "$DOTFILES_DIR/bash/.bash_profile" ~/
    # ln -sf "$DOTFILES_DIR/bash/.bashrc" ~/
    bash "$DOTFILES_DIR/bash/update_bashrc.sh"
else
    log "Bash is not used for shell."
fi


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

    # Install extensions
    while IFS= read -r extension
    do
        $VSCODE_DIR --install-extension "$extension" --force
    done < "$DOTFILES_DIR/vscode/extensions.txt"
else
    log "VS Code or code-server is not installed."
fi


echo -e "\n\033[1m-------- ✅ dotfiles installed! --------\n\n"