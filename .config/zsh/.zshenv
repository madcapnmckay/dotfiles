typeset -U path
path=(~/.local/bin $path[@])
fpath=(~/.zsh-plugins/zsh-completions/src $fpath)

export EDITOR='code'
export VISUAL="code"

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"

export DOTFILES_HOME="$HOME/.dotfiles" 
export BAT_THEME=tokyonight_night

# export ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR=$(brew --prefix)/share/zsh-syntax-highlighting/highlighters