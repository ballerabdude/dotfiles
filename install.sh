#!/usr/bin/env bash

###########################
# This script installs the dotfiles and runs all other system configuration scripts
# @author Adam Eivy
###########################

# include my library helpers for colorized echo and require_brew, etc
source ./lib_sh/echos.sh
source ./lib_sh/requirers.sh

bot "Hi! I'm going to install tooling and tweak your system settings. Here I go..."

# Ask for the administrator password upfront
if ! sudo grep -q "%wheel		ALL=(ALL) NOPASSWD: ALL #atomantic/dotfiles" "/etc/sudoers"; then

  # Ask for the administrator password upfront
  bot "I need you to enter your sudo password so I can install some things:"
  sudo -v

  # Keep-alive: update existing sudo time stamp until the script has finished
  while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

  bot "Do you want me to setup this machine to allow you to run sudo without a password?\nPlease read here to see what I am doing:\nhttp://wiki.summercode.com/sudo_without_a_password_in_mac_os_x \n"

  read -r -p "Make sudo passwordless? [y|N] " response

  if [[ $response =~ (yes|y|Y) ]];then
      sudo cp /etc/sudoers /etc/sudoers.back
      echo '%wheel		ALL=(ALL) NOPASSWD: ALL #atomantic/dotfiles' | sudo tee -a /etc/sudoers > /dev/null
      sudo dscl . append /Groups/wheel GroupMembership $(whoami)
      bot "You can now run sudo commands without password!"
  fi
fi

# /etc/hosts
read -r -p "Overwrite /etc/hosts with the ad-blocking hosts file from someonewhocares.org? (from ./configs/hosts file) [y|N] " response
if [[ $response =~ (yes|y|Y) ]];then
    action "cp /etc/hosts /etc/hosts.backup"
    sudo cp /etc/hosts /etc/hosts.backup
    ok
    action "cp ./configs/hosts /etc/hosts"
    sudo cp ./configs/hosts /etc/hosts
    ok
    bot "Your /etc/hosts file has been updated. Last version is saved in /etc/hosts.backup"
fi

grep 'user = GITHUBUSER' ./homedir/.gitconfig > /dev/null 2>&1
if [[ $? = 0 ]]; then
    read -r -p "What is your github.com username? " githubuser

  fullname=`osascript -e "long user name of (system info)"`

  if [[ -n "$fullname" ]];then
    lastname=$(echo $fullname | awk '{print $2}');
    firstname=$(echo $fullname | awk '{print $1}');
  fi

  if [[ -z $lastname ]]; then
    lastname=`dscl . -read /Users/$(whoami) | grep LastName | sed "s/LastName: //"`
  fi
  if [[ -z $firstname ]]; then
    firstname=`dscl . -read /Users/$(whoami) | grep FirstName | sed "s/FirstName: //"`
  fi
  email=`dscl . -read /Users/$(whoami)  | grep EMailAddress | sed "s/EMailAddress: //"`

  if [[ ! "$firstname" ]];then
    response='n'
  else
    echo -e "I see that your full name is $COL_YELLOW$firstname $lastname$COL_RESET"
    read -r -p "Is this correct? [Y|n] " response
  fi

  if [[ $response =~ ^(no|n|N) ]];then
    read -r -p "What is your first name? " firstname
    read -r -p "What is your last name? " lastname
  fi
  fullname="$firstname $lastname"

  bot "Great $fullname, "

  if [[ ! $email ]];then
    response='n'
  else
    echo -e "The best I can make out, your email address is $COL_YELLOW$email$COL_RESET"
    read -r -p "Is this correct? [Y|n] " response
  fi

  if [[ $response =~ ^(no|n|N) ]];then
    read -r -p "What is your email? " email
    if [[ ! $email ]];then
      error "you must provide an email to configure .gitconfig"
      exit 1
    fi
  fi


  running "replacing items in .gitconfig with your info ($COL_YELLOW$fullname, $email, $githubuser$COL_RESET)"

  # test if gnu-sed or MacOS sed

  sed -i "s/GITHUBFULLNAME/$firstname $lastname/" ./homedir/.gitconfig > /dev/null 2>&1 | true
  if [[ ${PIPESTATUS[0]} != 0 ]]; then
    echo
    running "looks like you are using MacOS sed rather than gnu-sed, accommodating"
    sed -i '' "s/GITHUBFULLNAME/$firstname $lastname/" ./homedir/.gitconfig;
    sed -i '' 's/GITHUBEMAIL/'$email'/' ./homedir/.gitconfig;
    sed -i '' 's/GITHUBUSER/'$githubuser'/' ./homedir/.gitconfig;
    ok
  else
    echo
    bot "looks like you are already using gnu-sed. woot!"
    sed -i 's/GITHUBEMAIL/'$email'/' ./homedir/.gitconfig;
    sed -i 's/GITHUBUSER/'$githubuser'/' ./homedir/.gitconfig;
  fi
fi

# MD5_NEWWP=$(md5 img/wallpaper.jpg | awk '{print $4}')
# MD5_OLDWP=$(md5 /System/Library/CoreServices/DefaultDesktop.jpg | awk '{print $4}')
# if [[ "$MD5_NEWWP" != "$MD5_OLDWP" ]]; then
#   read -r -p "Do you want to use the project's custom desktop wallpaper? [Y|n] " response
#   if [[ $response =~ ^(no|n|N) ]];then
#     echo "skipping...";
#     ok
#   else
#     running "Set a custom wallpaper image"
#     # `DefaultDesktop.jpg` is already a symlink, and
#     # all wallpapers are in `/Library/Desktop Pictures/`. The default is `Wave.jpg`.
#     rm -rf ~/Library/Application Support/Dock/desktoppicture.db
#     sudo rm -f /System/Library/CoreServices/DefaultDesktop.jpg > /dev/null 2>&1
#     sudo rm -f /Library/Desktop\ Pictures/El\ Capitan.jpg > /dev/null 2>&1
#     sudo rm -f /Library/Desktop\ Pictures/Sierra.jpg > /dev/null 2>&1
#     sudo rm -f /Library/Desktop\ Pictures/Sierra\ 2.jpg > /dev/null 2>&1
#     sudo cp ./img/wallpaper.jpg /System/Library/CoreServices/DefaultDesktop.jpg;
#     sudo cp ./img/wallpaper.jpg /Library/Desktop\ Pictures/Sierra.jpg;
#     sudo cp ./img/wallpaper.jpg /Library/Desktop\ Pictures/Sierra\ 2.jpg;
#     sudo cp ./img/wallpaper.jpg /Library/Desktop\ Pictures/El\ Capitan.jpg;ok
#   fi
# fi

#####
# install homebrew (CLI Packages)
#####

running "checking homebrew install"
brew_bin=$(which brew) 2>&1 > /dev/null
if [[ $? != 0 ]]; then
  action "installing homebrew"
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    if [[ $? != 0 ]]; then
      error "unable to install homebrew, script $0 abort!"
      exit 2
  fi
else
  ok
  # Make sure we???re using the latest Homebrew
  running "updating homebrew"
  brew update
  ok
  bot "before installing brew packages, we can upgrade any outdated packages."
  read -r -p "run brew upgrade? [y|N] " response
  if [[ $response =~ ^(y|yes|Y) ]];then
      # Upgrade any already-installed formulae
      action "upgrade brew packages..."
      brew upgrade
      ok "brews updated..."
  else
      ok "skipped brew package upgrades.";
  fi
fi

#####
# install brew cask (UI Packages)
#####
running "checking brew-cask install"
output=$(brew tap | grep cask)
if [[ $? != 0 ]]; then
  action "installing brew-cask"
  require_brew caskroom/cask/brew-cask
fi
brew tap caskroom/versions > /dev/null 2>&1
ok

# skip those GUI clients, git command-line all the way
require_brew git
# need fontconfig to install/build fonts
require_brew fontconfig
# update zsh to latest
require_brew zsh
# update ruby to latest
# use versions of packages installed with homebrew
RUBY_CONFIGURE_OPTS="--with-openssl-dir=`brew --prefix openssl` --with-readline-dir=`brew --prefix readline` --with-libyaml-dir=`brew --prefix libyaml`"
require_brew ruby
# set zsh as the user login shell
CURRENTSHELL=$(dscl . -read /Users/$USER UserShell | awk '{print $2}')
if [[ "$CURRENTSHELL" != "/usr/local/bin/zsh" ]]; then
  bot "setting newer homebrew zsh (/usr/local/bin/zsh) as your shell (password required)"
  # sudo bash -c 'echo "/usr/local/bin/zsh" >> /etc/shells'
  # chsh -s /usr/local/bin/zsh
  sudo dscl . -change /Users/$USER UserShell $SHELL /usr/local/bin/zsh > /dev/null 2>&1
  ok
fi

if [[ ! -d "./oh-my-zsh/custom/themes/powerlevel9k" ]]; then
  git clone https://github.com/bhilburn/powerlevel9k.git oh-my-zsh/custom/themes/powerlevel9k
fi

bot "creating symlinks for project dotfiles..."
pushd homedir > /dev/null 2>&1
now=$(date +"%Y.%m.%d.%H.%M.%S")

for file in .*; do
  if [[ $file == "." || $file == ".." ]]; then
    continue
  fi
  running "~/$file"
  # if the file exists:
  if [[ -e ~/$file ]]; then
      mkdir -p ~/.dotfiles_backup/$now
      mv ~/$file ~/.dotfiles_backup/$now/$file
      echo "backup saved as ~/.dotfiles_backup/$now/$file"
  fi
  # symlink might still exist
  unlink ~/$file > /dev/null 2>&1
  # create the link
  ln -s ~/.dotfiles/homedir/$file ~/$file
  echo -en '\tlinked';ok
done

popd > /dev/null 2>&1


bot "Installing vim plugins"
# cmake is required to compile vim bundle YouCompleteMe
# require_brew cmake
vim +PluginInstall +qall > /dev/null 2>&1

bot "installing fonts"
./fonts/install.sh
brew tap caskroom/fonts
require_cask font-fontawesome
require_cask font-awesome-terminal-fonts
require_cask font-hack
require_cask font-inconsolata-dz-for-powerline
require_cask font-inconsolata-g-for-powerline
require_cask font-inconsolata-for-powerline
require_cask font-roboto-mono
require_cask font-roboto-mono-for-powerline
require_cask font-source-code-pro
ok

if [[ -d "/Library/Ruby/Gems/2.0.0" ]]; then
  running "Fixing Ruby Gems Directory Permissions"
  sudo chown -R $(whoami) /Library/Ruby/Gems/2.0.0
  ok
fi

# node version manager
require_brew nvm

# nvm
require_nvm stable

# always pin versions (no surprises, consistent dev/build machines)
npm config set save-exact true

#####################################
# Now we can switch to node.js mode
# for better maintainability and
# easier configuration via
# JSON files and inquirer prompts
#####################################

bot "installing npm tools needed to run this project..."
npm install
ok

bot "installing packages from config.js..."
node index.js
ok

running "cleanup homebrew"
brew cleanup > /dev/null 2>&1
ok

###############################################################################
bot "Configuring General System UI/UX..."
###############################################################################
# Close any open System Preferences panes, to prevent them from overriding
# settings we???re about to change
running "closing any system preferences to prevent issues with automated changes"
osascript -e 'tell application "System Preferences" to quit'
ok


git clone git://github.com/concordusapps/pyenv-implict.git ~/.pyenv/plugins/pyenv-implict


###############################################################################
bot "Terminal & iTerm2"
###############################################################################

# running "Only use UTF-8 in Terminal.app"
# defaults write com.apple.terminal StringEncodings -array 4;ok
#
# running "Use a modified version of the Solarized Dark theme by default in Terminal.app"
TERM_PROFILE='Solarized Dark xterm-256color';
CURRENT_PROFILE="$(defaults read com.apple.terminal 'Default Window Settings')";
if [ "${CURRENT_PROFILE}" != "${TERM_PROFILE}" ]; then
	open "./configs/${TERM_PROFILE}.terminal";
	sleep 1; # Wait a bit to make sure the theme is loaded
	defaults write com.apple.terminal 'Default Window Settings' -string "${TERM_PROFILE}";
	defaults write com.apple.terminal 'Startup Window Settings' -string "${TERM_PROFILE}";
fi;

#running "Enable ???focus follows mouse??? for Terminal.app and all X11 apps"
# i.e. hover over a window and start `typing in it without clicking first
defaults write com.apple.terminal FocusFollowsMouse -bool true
#defaults write org.x.X11 wm_ffm -bool true;ok
running "Installing the Solarized Light theme for iTerm (opening file)"
open "./configs/Solarized Light.itermcolors";ok
running "Installing the Patched Solarized Dark theme for iTerm (opening file)"
open "./configs/Solarized Dark Patch.itermcolors";ok

running "Don???t display the annoying prompt when quitting iTerm"
defaults write com.googlecode.iterm2 PromptOnQuit -bool false;ok
running "hide tab title bars"
defaults write com.googlecode.iterm2 HideTab -bool true;ok
running "set system-wide hotkey to show/hide iterm with ^\`"
defaults write com.googlecode.iterm2 Hotkey -bool true;ok
running "hide pane titles in split panes"
defaults write com.googlecode.iterm2 ShowPaneTitles -bool false;ok
running "animate split-terminal dimming"
defaults write com.googlecode.iterm2 AnimateDimming -bool true;ok
defaults write com.googlecode.iterm2 HotkeyChar -int 96;
defaults write com.googlecode.iterm2 HotkeyCode -int 50;
defaults write com.googlecode.iterm2 FocusFollowsMouse -int 1;
defaults write com.googlecode.iterm2 HotkeyModifiers -int 262401;
running "Make iTerm2 load new tabs in the same directory"
/usr/libexec/PlistBuddy -c "set \"New Bookmarks\":0:\"Custom Directory\" Recycle" ~/Library/Preferences/com.googlecode.iterm2.plist
running "setting fonts"
defaults write com.googlecode.iterm2 "Normal Font" -string "Hack-Regular 12";
defaults write com.googlecode.iterm2 "Non Ascii Font" -string "RobotoMonoForPowerline-Regular 12";
ok
running "reading iterm settings"
defaults read -app iTerm > /dev/null 2>&1;
ok


###############################################################################
# Kill affected applications                                                  #
###############################################################################
bot "OK. Note that some of these changes require a logout/restart to take effect."


bot "Woot! All done. Kill this terminal and launch iTerm"
