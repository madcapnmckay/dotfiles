#!/bin/bash

ZDOTDIR=~/.config/zsh
CONFIG_FILE=~/.dotfiles-install-config

mkdir -p "$HOME/.config"

# -----------------------------------
# *** User Input ***
# -----------------------------------

# Load previous values if the config file exists
if [[ -f $CONFIG_FILE ]]; then
    source $CONFIG_FILE
else
    # Set default values if the config file does not exist
    NAME=$(id -F)
    MACHINE_NAME=""
    WORK_EMAIL=""
    WORK_FOLDER="dev/work"
    OSS_EMAIL=""
    OSS_FOLDER="dev/oss"
    GITHUB_URL="github.netflix.net"
fi

# Function to construct the prompt with optional default
prompt_with_default() {
    local prompt_message=$1
    local default_value=$2
    if [[ -n $default_value ]]; then
        echo "$prompt_message [$default_value]: "
    else
        echo "$prompt_message: "
    fi
}

# Prompt the user for input, using previous values as defaults
read -rp "$(prompt_with_default "What's your name?" "$NAME")" input
NAME=${input:-$NAME}

read -rp "$(prompt_with_default "Enter a name for your machine e.g <username>-mbp-<number>" "$MACHINE_NAME")" input
MACHINE_NAME=${input:-$MACHINE_NAME}

read -rp "$(prompt_with_default "Enter work email address, to be used for work github, stash etc" "$WORK_EMAIL")" input
WORK_EMAIL=${input:-$WORK_EMAIL}

read -rp "$(prompt_with_default "Enter folder in which to save work code in HOME" "$WORK_FOLDER")" input
WORK_FOLDER=${input:-$WORK_FOLDER}

read -rp "$(prompt_with_default "Enter work personal address, to be used for work github, stash etc" "$OSS_EMAIL")" input
OSS_EMAIL=${input:-$OSS_EMAIL}

read -rp "$(prompt_with_default "Enter the url of your github enterprise instance" "$GITHUB_URL")" input
GITHUB_URL=${input:-$GITHUB_URL}

read -rp "$(prompt_with_default "Enter folder in which to save open source/personal code in HOME" "$OSS_FOLDER")" input
OSS_FOLDER=${input:-$OSS_FOLDER}



# Save the current values to the config file
cat <<EOF > $CONFIG_FILE
NAME="$NAME"
MACHINE_NAME="$MACHINE_NAME"
WORK_EMAIL="$WORK_EMAIL"
WORK_FOLDER="$WORK_FOLDER"
OSS_EMAIL="$OSS_EMAIL"
OSS_FOLDER="$OSS_FOLDER"
GITHUB_URL="$GITHUB_URL"
EOF

WORK_PATH="$HOME/$WORK_FOLDER"
OSS_PATH="$HOME/$OSS_FOLDER"

echo
echo "This script will setup the machine with the following settings:"
echo "User Name: $NAME"
echo "Machine Name: $MACHINE_NAME"
echo ""
echo "Work Email: $WORK_EMAIL"
echo "Work Dir: $WORK_PATH"
echo ""
echo "OSS Email: $OSS_EMAIL"
echo "OSS Dir: $OSS_PATH"
echo ""
read -rp "Is this correct? [y/n]: " -n 1 user_input
echo ""

if [[ $user_input == "y" || $user_input == "Y" ]]; then
    echo "Beginning install."
else
    exit 1
fi

# -----------------------------------
# *** Backup Previous files to avoid conflicts when checking out ***
# -----------------------------------

echo "Backing up existing dotfiles"
shopt -s extglob
zfiles=(${ZDOTDIR:-~}/.zsh* ${ZDOTDIR:-~}/.zlog* ${ZDOTDIR:-~}/.zprofile)
mkdir -p ~/.bak
for zfile in $zfiles; do
  mv $zfile ~/.bak 2> /dev/null
done
unset zfile zfiles

# change the root .zshenv file to use ZDOTDIR
cat << 'EOF' >| ~/.zshenv
export XDG_CONFIG_HOME="$HOME/.config"
export ZDOTDIR="$HOME/.config/zsh"
[[ -f $ZDOTDIR/.zshenv ]] && . $ZDOTDIR/.zshenv
EOF

source ~/.zshenv

# -----------------------------------
# *** Machine Properties ***
# -----------------------------------

sudo scutil --set HostName $MACHINE_NAME.local
sudo scutil --set LocalHostName $MACHINE_NAME
sudo scutil --set ComputerName $MACHINE_NAME

# -----------------------------------
# *** Git ***
# -----------------------------------

mkdir -p $WORK_PATH
mkdir -p $OSS_PATH

git config --global user.name "${NAME}"
git config --global --add include.path ~/.gitconfig-user
git config --global includeIf."gitdir:~/dev/work/".path ~/dev/work/.gitconfig-work
git config --global includeIf."gitdir:~/dev/oss/".path ~/dev/oss/.gitconfig-oss

git config -f "$WORK_PATH/.gitconfig-work" user.name "${NAME}"
git config -f "$WORK_PATH/.gitconfig-work" user.email "${WORK_EMAIL}"
git config -f "$WORK_PATH/.gitconfig-work" core.sshCommand "ssh -i ~/.ssh/id_work"

git config -f "$OSS_FOLDER/.gitconfig-oss" user.name "${NAME}"
git config -f "$OSS_FOLDER/.gitconfig-oss" user.email "${OSS_EMAIL}"
git config -f "$OSS_FOLDER/.gitconfig-oss" core.sshCommand "ssh -i ~/.ssh/id_oss"


# -----------------------------------
# *** Homebrew ***
# -----------------------------------
if test ! $(which brew); then
  echo "Installing Brew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

echo "Updating homebrew..."
brew update
brew analytics off

# ** Formulae **
echo "Installing Brew Formulae..."

brew install git
brew install gh
brew install yarn
brew install pnpm
brew install bash
brew install git-lfs
brew install wget
brew install mas
brew install fzf
brew install bat
brew install git-delta
brew install fd
brew install eza
brew install zoxide
brew install alt-tab
brew install watchman
brew install tldr
brew install tree
brew install tmux

brew install starship

brew install zsh-completions
brew install zsh-autosuggestions
brew install zsh-syntax-highlighting
brew install zsh-history-substring-search

# ** Casks **
brew install --cask visual-studio-code
brew install --cask docker
brew install --cask tuple
brew install --cask google-drive
brew install --cask zoom

brew install --cask raycast
brew install --cask hiddenbar
brew install --cask stats
brew install --cask karabiner-elements
brew install --cask font-monaspace-nerd-font
brew install --cask wezterm
brew install --cask ghostty
brew install --cask spotify
brew install --cask dropbox
brew install --cask nikitabobko/tap/aerospace

# Setup Github Enterprise CLI tools
gh auth login -p https -h $GITHUB_URL -w

# -----------------------------------
# *** Pull down dotFiles ***
# See https://www.ackama.com/articles/the-best-way-to-store-your-dotfiles-a-bare-git-repository-explained/
# -----------------------------------

DOTFILES_HOME="$HOME/.dotfiles"
# function to act as an alias
function dotfiles() {
    /usr/bin/git --git-dir=$DOTFILES_HOME --work-tree=$HOME "$@" 
}

if [ -d "$DOTFILES_HOME" ]; then
  echo "Updating $DOTFILES_HOME"
  dotfiles pull
else
  echo "Creating $DOTFILES_HOME"
  git clone --bare git@github.com:madcapnmckay/dotfiles.git $DOTFILES_HOME
fi

## Checkout the dotfiles
dotfiles checkout

# -----------------------------------
# *** FZF ***
# -----------------------------------
if [ -d "$XDG_CONFIG_HOME/fzf-git.sh" ]; then
  echo "Updating fzf-git"
  cd $XDG_CONFIG_HOME/fzf-git.sh
  git pull
else
  echo "Cloning fzf-git"
  cd $XDG_CONFIG_HOME
  git clone https://github.com/junegunn/fzf-git.sh.git
  dotfiles config --local status.showUntrackedFiles no
fi

cd "$HOME"

# -----------------------------------
# *** Bat (Better cat) ***
# -----------------------------------

mkdir -p "$(bat --config-dir)/themes"
cd "$(bat --config-dir)/themes"
wget -P "$(bat --config-dir)/themes" https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Mocha.tmTheme
bat cache --build

# -----------------------------------
# *** NVM ***
# -----------------------------------
brew install nvm
mkdir -p ~/.nvm
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
nvm install --lts

csrutil status
echo "Installation complete..."

# -----------------------------------
# * MacOS Defaults *
# -----------------------------------
echo "Changing macOS defaults..."

# ** Settings > Desktop & Dock **

defaults write com.apple.dock tilesize -int 45
# Magnification: off
defaults write com.apple.dock magnification -bool false
# Position on screen: bottom
defaults write com.apple.dock orientation -string "bottom"
# Automatically hide and show the dock: true
defaults write com.apple.dock autohide -bool true
# disable delay when you hide the Dock
defaults write com.apple.Dock autohide-delay -float 0
# disable delay before animating the Dock hiding
defaults write com.apple.dock autohide-time-modifier -int 0
# disable gaps between tiled windows
defaults write com.apple.dock tile-windows-have-margins -bool false
# disable mission control
defaults write com.apple.dock expose-group-apps -bool true && killall Dock
# disable displays having separate spaces
defaults write com.apple.spaces spans-displays -bool true && killall SystemUIServer

defaults write com.apple.doc mineffect -string "scale"

# ** Finder **

# View > show status bar
defaults write com.apple.finder ShowStatusBar -bool true
# View > show path bar
defaults write com.apple.finder ShowPathbar -bool true
# View > as list
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
# Settings > advanced > show warning before changing an extension: false
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
# Settings > advanced > show all filename extensions
defaults write .GlobalPreferences AppleShowAllExtensions -bool true

killall Dock

chmod go-w $(brew --prefix)/share
chmod -R go-w $(brew --prefix)/share/zsh

echo "dotfiles setup complete!"
