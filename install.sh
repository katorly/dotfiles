#!/usr/bin/env bash

DOTFILES_DIR=$(dirname "$(realpath "$0")")  # Do not use $(pwd) because the path obtained in some CDEs is incorrect.
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
if command -v code &> /dev/null; then
    VSCODE_DIR="code"
elif command -v code-server &> /dev/null; then
    VSCODE_DIR="code-server"
elif [ -x "/tmp/vscode-web/bin/code-server" ]; then
    VSCODE_DIR="/tmp/vscode-web/bin/code-server"
elif [ -x "/tmp/code-server/bin/code-server" ]; then
    VSCODE_DIR="/tmp/code-server/bin/code-server"
elif [ -x "/ide/bin/gitpod-code" ]; then
    VSCODE_DIR="/ide/bin/gitpod-code"
fi
if command -v code &> /dev/null || command -v code-server &> /dev/null || [ -x "/tmp/vscode-web/bin/code-server" ] || [ -x "/tmp/code-server/bin/code-server" ] || [ -x "/ide/bin/gitpod-code" ]; then
    VSCODE_USER_DIR="$HOME/.config/Code/User"
    mkdir -p "$VSCODE_USER_DIR"
    ln -sf "$DOTFILES_DIR/vscode/settings.json" "$VSCODE_USER_DIR/"
else
    log "VS Code or code-server is not installed."
fi


# Scripts after this will be executed after CDE workspace init
wait

(

log "🧩 Installing VS Code extensions"
while IFS= read -r extension
do
    $VSCODE_DIR --install-extension "$extension" --force
done < "$DOTFILES_DIR/vscode/extensions.txt"

) &

# Give terminal control back to the user
bg_pid=$!
wait $bg_pid

echo -e "\n\033[1m-------- ✅ dotfiles installed! --------\n\n"