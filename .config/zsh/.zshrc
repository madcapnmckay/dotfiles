#!/usr/bin/env zsh

export XDG_CONFIG_HOME=$HOME/.config

# Editor alias
alias code="cursor"

# Set the default editor
export EDITOR="code"
export VISUAL="code"

# Don’t clear the screen after quitting a manual page
export MANPAGER="less -X"

# DotFiles
export DOTFILES_PATH="$HOME/.dotfiles";

# -----------------------------------
# *** Zsh Config ***
# -----------------------------------

# ** Navigation **

setopt AUTO_CD              # Go to folder path without using cd.

setopt AUTO_PUSHD           # Push the old directory onto the stack on cd.
setopt PUSHD_IGNORE_DUPS    # Do not store duplicates in the stack.
setopt PUSHD_SILENT         # Do not print the directory stack after pushd or popd.

setopt CORRECT              # Spelling correction
setopt CDABLE_VARS          # Change directory to a path stored in a variable.
setopt EXTENDED_GLOB        # Use extended globbing syntax.

# ** History **

export HISTFILE=$HOME/.zsh_history
# The number of lines of history you want to be saved.
export SAVEHIST=100000
# The number of lines loaded into the shell memory.
export HISTSIZE=10000
# Make some commands not show up in history
export HISTIGNORE="ls:cd:cd -:pwd:exit:date:* --help"

setopt EXTENDED_HISTORY          # Write the history file in the ':start:elapsed;command' format.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire a duplicate event first when trimming history.
setopt HIST_IGNORE_DUPS          # Do not record an event that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete an old recorded event if a new event is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a previously found event.
setopt HIST_IGNORE_SPACE         # Do not record an event starting with a space.
setopt HIST_SAVE_NO_DUPS         # Do not write a duplicate event to the history file.
setopt HIST_VERIFY               # Do not execute immediately upon history expansion.

# completion using arrow keys (based on history)
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
bindkey '^Xa' _expand_alias

autoload -U compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# ** Plugins **

if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH

  autoload -Uz compinit
  compinit
fi

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=247'
ZSH_AUTOSUGGEST_USE_ASYNC=1

# -----------------------------------
# *** FZF ***
# -----------------------------------

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}

show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git --exclude .cache"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
--color=selected-bg:#45475a \
--multi"

# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo ${}'"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
  esac
}

source $XDG_CONFIG_HOME/fzf-git.sh/fzf-git.sh

# -----------------------------------
# *** Bat (Better Cat) ***
# -----------------------------------

export BAT_THEME="Catppuccin Mocha"

# -----------------------------------
# *** Eza (Better LS) ***
# -----------------------------------

alias ls-old="/bin/ls "
alias ls="eza --all --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions --group-directories-first "

# -----------------------------------
# *** Oxide (Better cd) ***
# -----------------------------------

eval "$(zoxide init zsh)"

alias cd="z"

# -----------------------------------
# *** Starship Prompt ***
# -----------------------------------

eval "$(starship init zsh)"

# -----------------------------------
# *** NVM ***
# -----------------------------------

export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# -----------------------------------
# *** Aliases ***
# -----------------------------------
alias aliases='print -rl -- ${(k)aliases}'
alias funcs='print -rl -- ${(k)functions}'

# An alias for git that works with the bare repo
# Use this exactly like you would use `git <WHATEVER>` but replace 'git' with `gdf <WHATEVER>``
alias gdf='/usr/bin/git --git-dir=$DOTFILES_PATH --work-tree=$HOME'
alias gdf='code $HOME'
# alias dotFiles = 'code ~/'
# Indexed directory navigation
alias d='dirs -v'
for index ({1..9}) alias "$index"="cd +${index}"; unset index


# -----------------------------------
# *** Git Aliases ***
# -----------------------------------

export GIT_BRANCH_PREFIX='imckay'
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
alias g-='git main'
alias gst='git status'
alias gchk='git checkout '
alias gadd='git add'
alias gpsh='git push'
alias gupd='git pull-main'
alias gpul='git pull'
alias gbra='git branch'
alias gcmt='git commit'
alias gdif='git difftool'
alias grem='git remote --verbose'
alias glog='git leaf'
alias glbr='git twig'
alias gcln='git cleanup'
alias gund='git undo'

# from https://sites.google.com/netflix.com/deved/onboarding/system-setup
ghrepo(){

    if [[ -e .git/ ]]; then

        $(which gh) -R corp/$(basename $PWD) "$@"

    else

        $(which gh) "$@"

    fi
}

# Define the gco function
# This acts as a pass through for git checkout but will prefix all branch names with
# the GIT_BRANCH_PREFIX env variable
# Usage: 
# - `gco -b foo` creates a branch named my-prefix/foo
# - `gco foo` moves to the branch foo OR my-prefix/foo
# - `gco some/file/path` checks out that file as normal
gco() {
    if [ -z "$GIT_BRANCH_PREFIX" ]; then
        echo "Error: GIT_BRANCH_PREFIX is not set."
        return 1
    fi

    local prefix="$GIT_BRANCH_PREFIX/"
    local branch_name=""
    local is_new_branch=false
    local additional_args=()

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -b)
                is_new_branch=true
                shift
                branch_name="$1"
                ;;
            *)
                if [ -z "$branch_name" ]; then
                    branch_name="$1"
                else
                    additional_args+=("$1")
                fi
                ;;
        esac
        shift
    done

    if $is_new_branch; then
        # Create a new branch with the prefix and pass additional arguments
        git checkout -b "${prefix}${branch_name}" "${additional_args[@]}"
    else
        # Check if the branch with the prefix exists
        if git show-ref --verify --quiet "refs/heads/${prefix}${branch_name}"; then
            git checkout "${prefix}${branch_name}" "${additional_args[@]}"
        else
            # If not a branch, assume it's a file and checkout
            git checkout "$branch_name" "${additional_args[@]}"
        fi
    fi
}

# Define the gwt function
# Usage: 
# - `gwt` moves to the main worktree
# - `gwt <WORKTREE_NAME>` moves to the worktree or creates it
# - `gwt -` moves to the previous worktree
gwt() {
  local worktree_dir=".worktrees"
  local current_dir="$PWD"
  local target_dir
  local GIT_BRANCH_PREFIX="${GIT_BRANCH_PREFIX:-feature}"  # Use global or default to "feature"

  # Helper function to find the root of the main Git repository
  find_git_root() {
    git rev-parse --git-common-dir 2>/dev/null | xargs -I{} realpath {}/..
  }

  # Determine the last worktree file path
  local git_root
  git_root=$(find_git_root)
  if [[ -z "$git_root" ]]; then
    echo "Not a git repository."
    return 1
  fi
  local last_worktree_file="$git_root/$worktree_dir/.last_worktree"

  # Ensure the .worktrees directory and last worktree file exist at the root
  mkdir -p "$git_root/$worktree_dir"
  touch "$last_worktree_file"

  # If no parameter is specified
  if [[ -z "$1" ]]; then
    # Navigate to the root of the worktree if within a worktree
    if [[ "$current_dir" == *"/$worktree_dir/"* ]]; then
      target_dir="$git_root"
    else
      echo "Not within a .worktrees directory."
      return 1
    fi
  elif [[ "$1" == "-" ]]; then
    # If the parameter is "-"
    if [[ -f "$last_worktree_file" ]]; then
      target_dir=$(<"$last_worktree_file")
    else
      echo "No previous worktree directory recorded."
      return 1
    fi
  else
    local passthroughs=("add" "list" "lock", "move", "prune", "remove", "repair", "unlock")

    for param in "${passthroughs[@]}"; do
        if [[ "$1" == "$param" ]]; then
            git worktree "$1"
            return 0
        fi
    done

    # If a string parameter is specified
    if [[ "$current_dir" == *"/$worktree_dir/"* ]]; then
      # If within a .worktrees directory, create a sibling
      target_dir="$(dirname "$current_dir")/$1"
    else
      # Otherwise, create in the root .worktrees directory
      target_dir="$git_root/$worktree_dir/$1"
    fi

    # Check if the target worktree directory exists, if not, create it
    if [[ ! -d "$target_dir" ]]; then
      git worktree add "$target_dir" -b "$GIT_BRANCH_PREFIX/$1" || return 1
    fi
  fi

  # Navigate to the target directory
  if [[ -n "$target_dir" ]]; then
    # Save the current directory to the last worktree file before changing
    echo "$PWD" > "$last_worktree_file"
    cd "$target_dir" || return 1
  fi
}

# -----------------------------------
# *** Sourcing ***
# -----------------------------------

source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $(brew --prefix)/share/zsh-history-substring-search/zsh-history-substring-search.zsh

# -----------------------------------
# *** User extra ***
# -----------------------------------

USER_FILE=~/.zshrc-user
if [[ -f $USER_FILE ]]; then
    # Source the file
    source "$USER_FILE"
fi
unset file
