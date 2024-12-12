# dotFiles

## Prequisites

Create SSH key

```bash
ssh-keygen -t ed25519 -C "<<WORK_EMAIL>/<<COMPUTER_NAME>>" -f ~/.ssh/id_work
<USE A PASSPHRASE>
ssh-keygen -t ed25519 -C "<<WORK_EMAIL>>>/<<COMPUTER_NAME>>" -f ~/.ssh/id_oss

open ~/.ssh/config
```

Paste into `.ssh/config`.

```
Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_work
```

```bash
ssh-add --apple-use-keychain ~/.ssh/id_oss
ssh-add --apple-use-keychain ~/.ssh/id_work
```

## Installation

```bash
curl https://github.netflix.net/raw/imckay/dotfiles/main/install.sh?token=GHSAT0AAAAAAAAAOLDGC5Y56IBFO6PFJYJKZ3A3XFA | bash
```

# VSCode Settings

```json
{
  "window.newWindowDimensions": "maximized",
  "terminal.integrated.scrollback": 100000,
  "search.followSymlinks": false,
  "editor.stickyScroll.enabled": true,
  "editor.formatOnSave": true,
  "debug.toolBarLocation": "commandCenter",
  "workbench.sideBar.location": "right",
  "settingsSync.ignoredSettings": [
    "typescript.tsserver.maxTsServerMemory",
    "typescript.tsserver.nodePath"
  ],
  "typescript.tsserver.nodePath": "",
  "typescript.tsserver.maxTsServerMemory": 8196
}
```

## VSCode Shortcuts

Ctrl+Tab => Show all open files

# How this was setup

```bash
git init --bare $HOME/.dotfiles --initial-branch=main

dotfiles config --local status.showUntrackedFiles no
dotfiles config --local user.name "Ian Mckay"
dotfiles config --local user.email "ian@avastmehearties.con"
dotfiles config --local core.sshCommand "ssh -i ~/.ssh/id_oss"

alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME'

dotfiles add .zshrc
# add other files
dotfiles commit -m 'Commit message'
dotfiles remote add origin git@github.com:madcapnmckay/dotfiles.git
dotfiles push
```
