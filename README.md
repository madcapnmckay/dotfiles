# dotFiles

## Prequisites

Create SSH key

```bash
ssh-keygen -t ed25519 -C "<<WORK_EMAIL>/<<COMPUTER_NAME>>" -f ~/.ssh/id_work
<USE A PASSPHRASE>
ssh-keygen -t ed25519 -C "<<PERSONAL_EMAIL>>>/<<COMPUTER_NAME>>" -f ~/.ssh/id_oss
<USE A PASSPHRASE>

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

Copy the public keys into the appropriate sites.

```bash
pbcopy < ~/.ssh/id_oss.pub
```

## Installation

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/madcapnmckay/dotfiles/refs/heads/main/install.sh)"
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

## Key Binding

## Fantasical

- <kbd>CTRL-D</kbd> Show mini calendar window

## VSCode

- <kbd>CTRL-Tab</kbd> => Show all open files

## Terminal

- <kbd>CTRL-T</kbd> Fuzzy find all files
- <kbd>ALT-C</kbd> Fuzzy find all directories
- <kbd>CTRL-R</kbd> Fuzzy find through your shell history
- `cd **`<kbd>Tab</kbd> Open up fzf to find directory
- `export **`<kbd>Tab</kbd> Look for env variable to export
- `unset **`<kbd>Tab</kbd> Look for env variable to unset
- `unalias **`<kbd>Tab</kbd> Look for alias to unalias
- `ssh **`<kbd>Tab</kbd> Look for recently visited host names
- `kill -9 **`<kbd>Tab</kbd> Look for process name to kill to get pid
- <kbd>CTRL-G</kbd><kbd>CTRL-F</kbd> for **F**iles
- <kbd>CTRL-G</kbd><kbd>CTRL-B</kbd> for **B**ranches
- <kbd>CTRL-G</kbd><kbd>CTRL-H</kbd> for commit **H**ashes

## Git

### Aliases

- <kbd>gs</kbd> = <kbd>git status</kbd>
- <kbd>ga</kbd> = <kbd>git add</kbd>
- <kbd>gp</kbd> = <kbd>git push</kbd>
- <kbd>gpo</kbd> = <kbd>git push origin</kbd>
- <kbd>gtd</kbd> = <kbd>git tag --delete</kbd>
- <kbd>gtdr</kbd> = <kbd>git tag --delete origin</kbd>
- <kbd>gr</kbd> = <kbd>git branch -r</kbd>
- <kbd>gplo</kbd> = <kbd>git pull origin</kbd>
- <kbd>gb</kbd> = <kbd>git branch</kbd>
- <kbd>gc</kbd> = <kbd>git commit</kbd>
- <kbd>gd</kbd> = <kbd>git diff</kbd>
- <kbd>gl</kbd> = <kbd>git log</kbd>
- <kbd>gr</kbd> = <kbd>git remote</kbd>
- <kbd>grs</kbd> = <kbd>git remote show</kbd>
- <kbd>glo</kbd> = <kbd>git log --pretty="oneline"</kbd>
- <kbd>glol</kbd> = <kbd>git log --graph --oneline --decorate</kbd>

### Custom functions

#### <kbd>gco</kbd>

This acts as a pass through for git checkout but will prefix all branch names with the <code>GIT_BRANCH_PREFIX</code> env variable.

- <kbd>gco -b foo</kbd> creates a branch named my-prefix/foo
- <kbd>gco foo</kbd> moves to the branch foo OR my-prefix/foo
- <kbd>gco some/file/path</kbd> checks out that file as normal

#### <kbd>gwt</kbd>

- <kbd>gwt</kbd> moves to the main worktree
- <kbd>gwt <WORKTREE_NAME></kbd> moves to the worktree or creates it
- <kbd>gwt -</kbd> moves to the previous worktree

## How this was setup?

```bash
git init --bare $HOME/.dotfiles --initial-branch=main

dotfiles config --local status.showUntrackedFiles no
dotfiles config --local user.name "Ian Mckay"
dotfiles config --local user.email "ian@avastmehearties.com"
dotfiles config --local core.sshCommand "ssh -i ~/.ssh/id_oss"

alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME'

dotfiles add .zshrc
# add other files
dotfiles commit -m 'Commit message'
dotfiles remote add origin git@github.com:madcapnmckay/dotfiles.git
dotfiles push origin main --force
```
