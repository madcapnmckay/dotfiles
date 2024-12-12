#!/bin/bash

# Install Configuration file path, used to store user input in the event of multiple runs
CONFIG_FILE=~/.dotfiles-install-config
PWD=$(pwd)

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
EOF

DOTFILES_FOLDER=".dotfiles"
DOTFILES_PATH="$HOME/$DOTFILES_FOLDER"
WORK_PATH="$HOME/$WORK_FOLDER"
OSS_PATH="$HOME/$OSS_FOLDER"
INSTALL_DIR=$HOME/.config

echo
echo "This script will setup the machine with the following settings:"
echo "User Name: $NAME"
echo "User Name: $MACHINE_NAME"
echo
echo "Work Email: $WORK_EMAIL"
echo "Work Dir: $WORK_PATH"
echo
echo "OSS Email: $OSS_EMAIL"
echo "OSS Dir: $OSS_PATH"
echo
read -rp "Is this correct? [y/n]: " -n 1 user_input
echo 
if [[ $user_input == "y" || $user_input == "Y" ]]; then
    echo "You confirmed yes."
else
    exit 1
fi

sudo scutil --set HostName $MACHINE_NAME.local
sudo scutil --set LocalHostName $MACHINE_NAME
sudo scutil --set ComputerName $MACHINE_NAME

# -----------------------------------
# *** Git ***
# -----------------------------------

mkdir -p $WORK_PATH
mkdir -p $OSS_PATH

git config -f "$WORK_PATH/.gitconfig-work" user.name "${NAME}"
git config -f "$WORK_PATH/.gitconfig-work" user.email "${WORK_EMAIL}"
git config -f "$WORK_PATH/.gitconfig-work" core.sshCommand "ssh -i ~/.ssh/id_work"

git config -f "$OSS_FOLDER/.gitconfig-oss" user.name "${name:-$defaultName}"
git config -f "$OSS_FOLDER/.gitconfig-oss" user.email "${ossemail:-$defaultEmail}"
git config -f "$WORK_PATH/.gitconfig-oss" core.sshCommand "ssh -i ~/.ssh/id_oss"

# -----------------------------------
# *** xCode ***
# -----------------------------------

# This installs git which can then be used to clone the dotfiles repo, we can then install a new git via brew
if [[ "$(uname)" == "Darwin" ]]; then
    echo "macOS detected..."

    if xcode-select -p &>/dev/null; then
        echo "Xcode already installed"
    else
        echo "Installing commandline tools..."
        xcode-select --install
    fi
fi

# -----------------------------------
# *** dotFiles ***
# -----------------------------------

# Pull down dotFiles
# See https://www.ackama.com/articles/the-best-way-to-store-your-dotfiles-a-bare-git-repository-explained/
echo "$DOTFILES_FOLDER" >> .gitignore

if [ -d "$DOTFILES_PATH" ]; then
	echo "Updating $DOTFILES_FOLDER"
	git pull
else
	echo "Creating $DOTFILES_FOLDER"
	git clone --bare git@github.com:madcapnmckay/dotfiles.git $DOTFILES_PATH
fi

## Define the alias in the current shell scope:
alias dotfiles='/usr/bin/git --git-dir=$DOTFILES_PATH --work-tree=$HOME'
## Checkout the dotfiles
dotfiles checkout

# -----------------------------------
# *** Homebrew ***
# -----------------------------------

echo "Installing Brew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew analytics off

# ** Formulae **
echo "Installing Brew Formulae..."

brew install git
brew install bash
brew install git-lfs
brew install curl
brew install wget
brew install mas
brew install fzf
brew install bat
brew install git-delta
brew install fd
brew install eza
brew install zoxide
brew install mas
brew install alt-tab
brew install watchman
brew install tldr
brew install tree
brew install tmux

brew install starship

brew install zplug
brew install zsh-completions
brew install zsh-autosuggestions
brew install zsh-syntax-highlighting
brew install zsh-history-substring-search

# ** Casks **

brew install --cask raycast
brew install --cask hiddenbar
brew install --cask stats
brew install --cask karabiner-elements
brew install --cask font-monaspace-nerd-font
brew install --cask docker
brew install --cask warp
brew install --cask tuple

# -----------------------------------
# *** FZF ***
# -----------------------------------

mkdir -p $INSTALL_DIR

if [ -d "$INSTALL_DIR/fzf-git.sh" ]; then
	echo "Updating fzf-git"
    cd $INSTALL_DIR/fzf-git.sh
	git pull
else
	echo "Cloning fzf-git"
    cd $INSTALL_DIR
	git clone https://github.com/junegunn/fzf-git.sh.git
fi

cd "$PWD"

# -----------------------------------
# *** Bat (Better cat) ***
# -----------------------------------

mkdir -p "$(bat --config-dir)/themes"
cd "$(bat --config-dir)/themes"
curl -O https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/sublime/tokyonight_night.tmTheme
bat cache --build

# -----------------------------------
# *** NVM ***
# -----------------------------------
brew install nvm
mkdir -p ~/.nvm
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


echo "Dotfiles setup complete!"