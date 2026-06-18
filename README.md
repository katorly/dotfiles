# dotfiles
A collection of my dotfiles.

## Usage
Shows available install options:
```sh
./install.sh
./install.sh -h
./install.sh --help
```

Install all components:
```sh
./install.sh all
```

Install selected components:
```sh
./install.sh git vscode
./install.sh shell ai
```

Available components: `git`, `shell`, `vscode`, `ai`, `codex`, `claude`, `all`.

If permission is denied, run `chmod 755 install.sh` and execute it again.
