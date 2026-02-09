#!/bin/bash

# This is to avoid overwriting the default .bashrc

HISTSIZE_SETTING="HISTSIZE=10000"
HISTFILESIZE_SETTING="HISTFILESIZE=20000"
HISTCONTROL_SETTING="HISTCONTROL=ignoredups:erasedups:ignorespace"
HISTAPPEND_SETTING="shopt -s histappend"

BASHRC_FILE="$HOME/.bashrc"

if grep -q "^HISTSIZE=" "$BASHRC_FILE"; then
    sed -i "s/^HISTSIZE=.*/$HISTSIZE_SETTING/" "$BASHRC_FILE"
else
    echo "$HISTSIZE_SETTING" >> "$BASHRC_FILE"
fi

if grep -q "^HISTFILESIZE=" "$BASHRC_FILE"; then
    sed -i "s/^HISTFILESIZE=.*/$HISTFILESIZE_SETTING/" "$BASHRC_FILE"
else
    echo "$HISTFILESIZE_SETTING" >> "$BASHRC_FILE"
fi

if grep -q "^HISTCONTROL=" "$BASHRC_FILE"; then
    sed -i "s/^HISTCONTROL=.*/$HISTCONTROL_SETTING/" "$BASHRC_FILE"
else
    echo "$HISTCONTROL_SETTING" >> "$BASHRC_FILE"
fi

if ! grep -q "^shopt -s histappend" "$BASHRC_FILE"; then
    echo "$HISTAPPEND_SETTING" >> "$BASHRC_FILE"
fi

ALIASES=(
    "alias la='ls -a'"
    "alias ll='ls -al'"
    "alias dup='docker compose up -d'"
    "alias ddown='docker compose down'"
    "alias dpull='docker compose pull'"
)

for ALIAS in "${ALIASES[@]}"; do
    if ! grep -qF "$ALIAS" "$BASHRC_FILE"; then
        echo "$ALIAS" >> "$BASHRC_FILE"
    fi
done

source "$BASHRC_FILE"