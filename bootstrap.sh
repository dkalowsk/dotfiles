#!/usr/bin/env bash
#
# Originally inspired heavily from:
# https://github.com/JDevlieghere/dotfiles/blob/master/bootstrap.sh
# for the different sections.
#
# Many edits later, it's become it's own beast of a mistake
#

DOTFILES="$( cd "$(dirname "$0")" ; pwd -P )"
PLATFORM="$(uname)"


info () {
  printf "\033[00;34m$@\033[0m\n"
}


doStow() {
  if hash stow 2>/dev/null; then
    stow ${1}
  else
    #
    # This is primarily bash on windows, and there is no stow, so let's fake
    # it... and sometimes on completely new systems.  We can't depend upon the
    # previous _installStow function as we may not have compiling tools
    # installed yet.  grrr...
    #
    if [ -d "${1}" ]; then
      shopt -s dotglob
      for F in ${1}/*; do
        if [ ! -f ${F} ]; then
          if ["${F}" == ^. ]; then
            ln -s ${F} ${HOME}/${F##*/}
          else
            ln -s ${F} ${HOME}/${1}/${F##*/}
          fi
        else
          info "File already exists ${F}"
        fi
      done
      shopt -u dotglob
    fi
  fi
}

doUpdate() {
  info "Updating... "
  #
  # Now go clone the latest version of your dotfiles
  #
  git stash --quiet
  git pull --rebase
  git stash pop --quiet
}

doSync() {
  for D in *; do
    if [ ! -d "${D}" ]; then
      continue
    fi

    mydir=${D##*/}
    info "Syncing ${mydir}"
    doStow ${mydir}
  done
}

doBrew() {

  if [ ${PLATFORM} != "Darwin" ]; then
    return
  fi

  #
  # check if the system has brew installed, if so just go update it
  # and the packages
  #
  if hash brew 2>/dev/null; then
    brew update
    brew upgrade
  else
    # Install homebrew
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    #brew tap homebrew/bundle  # this most likely isn't needed anymore
  fi

  if [ -f "Brewfile" ]; then
    brew bundle
  fi
}

doInstall() {
  info "Installing Extras"

  # Now that dotfiles are in place, make sure to run the Vundle installation
  vim -i NONE -c PlugInstall -c PlugClean -c quitall

  doPython3 ${update}
}

doFonts() {
  info "Installing Fonts"

  # Grab the latest Microsoft Cascadia Code font
  curl -O https://github.com/microsoft/cascadia-code/releases/download/v1911.21/Cascadia.ttf
  curl -O https://github.com/microsoft/cascadia-code/releases/download/v1911.21/CascadiaMono.ttf
  curl -O https://github.com/microsoft/cascadia-code/releases/download/v1911.21/CascadiaMonoPL.ttf
  curl -O https://github.com/microsoft/cascadia-code/releases/download/v1911.21/CascadiaPL.ttf

  if [ ${PLATFORM} == "MSYS" ]; then
    info "You will need to manually install the fonts by clicking on them."
    info "I have not setup the PowerShell script to do so yet."
    info "This might help: https://medium.com/@slmeng/how-to-install-powerline-fonts-in-windows-b2eedecace58"

    return

  fi

  if [ ${PLATFORM} == "Darwin" ]; then
    fonts_dir=~/Library/Fonts
  elif [ ${PLATFORM} == "Linux" ]; then
    fonts_dir=~/.local/share/fonts
  fi

  mkdir -p "${fonts_dir}"

  # Copy the fonts to the font dir
  find . -name "*.[ot]tf" -type f -print0 | xargs -0 -n1 -I % cp "%" "${font_dir}/"

  # Now clean up the downloaded font files 
  find . -name "*.[ot]tf" -type f -print0 | xargs -0 -n1 -I % rm "%"

}

doPipInstall() {
  local pip_version=${1}
  local update=false

  if [[ ${2} == true ]]; then
    update="--upgrade"
  fi

  ${pip_version} install jedi --user ${update}
  ${pip_version} install neovim --user ${update}
  ${pip_version} install parso --user ${update}
  ${pip_version} install voltron --user ${update}
  ${pip_version} install powerline-status --user ${update}
}

doPython3() {
  local update=${1}

  # Check if pip is installed
  if ! type -P "pip3"; then
    #if not do the following:
    curl https://bootstrap.pypa.io/get-pip.py | python3
  else
    pip3 install --upgrade pip
  fi

  doPipInstall "pip3" ${update}
}

doMacOSConfig() {
  if [ ${PLATFORM} != "Darwin" ]; then
    return
  fi

  info "Configuring macOS..."
  # Fix Visual Code key repeat issue
  # Pulled from: https://github.com/VSCodeVim/Vim#mac-setup
  defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false

  # Show all File Extensions
  defaults write -g AppleShowAllExtensions -bool true

  # Don't create metadata files on network and USB devices
  defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
  defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

  # Enable ssh login
  #sudo launchctl load -w /System/Library/LaunchDaemons/ssh.plist

  if hash xcode-select 2>/dev/null; then
    # this may or may not work
    xcode-select --install > /dev/null 2>&1
  fi

  #
  # disable the annoying "Try the new Safari" pop-up.  Requires re-logging in
  # to take effect
  #
  defaults write com.apple.coreservices.uiagent CSUIHasSafariBeenLaunched -bool YES
  defaults write com.apple.coreservices.uiagent CSUIRecommendSafariNextNotificationDate -date 2050-01-01T00:00:00Z
  defaults write com.apple.coreservices.uiagent CSUILastOSVersionWhereSafariRecommendationWasMade -float 10.99

  #
  # disable Safari from trying to become the default browser.  Requires
  # re-logging in to take effect.
  #
  defaults write com.apple.Safari DefaultBrowserDateOfLastPrompt -date '2050-01-01T00:00:00Z'
  defaults write com.apple.Safari DefaultBrowserPromptingState -int 2

  #
  # Grab the Peppermint theme for the Terminal
  #
  curl https://noahfrederick.com/get/Peppermint.1.2.terminal.zip --output peppermint.zip --silent
  if [  -f "peppermint.zip" ]; then
    unzip -o peppermint.zip
    rm peppermint.zip
  fi
  # Installation will need to be manual as disabling gatekeeper isn't going to happen here

  # Next several lines were borrowed from:
  # https://github.com/mathiasbynens/dotfiles/blob/master/.macos
  # -------
  # Automatically quit printer app once the print jobs complete
  defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

  # Disable the “Are you sure you want to open this application?” dialog
  defaults write com.apple.LaunchServices LSQuarantine -bool false

  # Set sidebar icon size to medium
  defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 2

  # Save to disk (not to iCloud) by default
  defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
  # Restart automatically if the computer freezes
  sudo systemsetup -setrestartfreeze on
  # Require password immediately after sleep or screen saver begins
  defaults write com.apple.screensaver askForPassword -int 1
  defaults write com.apple.screensaver askForPasswordDelay -int 0

  # Keep folders on top when sorting by name
  defaults write com.apple.finder _FXSortFoldersFirst -bool true
  # Disable the warning when changing a file extension
  defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
  # Show the ~/Library folder
  chflags nohidden ~/Library

  # Automatically hide and show the Dock
  defaults write com.apple.dock autohide -bool true

  # Set the icon size of Dock items to 36 pixels
  defaults write com.apple.dock tilesize -int 36

  # Hot corners
  # Possible values:
  #  0: no-op
  #  2: Mission Control
  #  3: Show application windows
  #  4: Desktop
  #  5: Start screen saver
  #  6: Disable screen saver
  #  7: Dashboard
  # 10: Put display to sleep
  # 11: Launchpad
  # 12: Notification Center
  # Top left screen corner → Mission Control
  defaults write com.apple.dock wvous-tl-corner -int 2
  defaults write com.apple.dock wvous-tl-modifier -int 0
  # Top right screen corner → Start screen saver
  defaults write com.apple.dock wvous-tr-corner -int 5
  defaults write com.apple.dock wvous-tr-modifier -int 0
  # Bottom left screen corner → Desktop
  defaults write com.apple.dock wvous-bl-corner -int 4
  defaults write com.apple.dock wvous-bl-modifier -int 0
  # --- end copy

  info "For full changes to take effect, log out and re-login (or reboot your choice)."

  if hash xcode-select 2>/dev/null; then
    xcode_status=$(xcode-select -p)
    # a value of 2 means CLI not installed
    # a value of 0 means installed + returns the path
    # brew can only be run if Xcode's CLI tools have been installed.
    #
    [ ${xcode_status:=2} -ne 2 ] && doBrew
  fi
}

doLinuxConfig() {
  if [ ${PLATFORM} != "Linux" ]; then
    return
  fi

  info "Configuring Linux..."

  info "Installing from aptgets"
  if (($EUID != 0)); then
    if [[ -t 1 ]]; then
#                sudo apt-get install $(grep -vE "^\s*#" aptgets | tr "\n" " ")
      xargs -a <(awk '! /^ *(#|$)/' "aptgets") -r -- sudo apt-get install -y 
    fi
  fi

  # use universal ctags if possible instead
  if [ ! -f "${HOME}/bin/ctags" ]; then
    info "Installing universal-ctags"
    git clone https://github.com/universal-ctags/ctags.git universal_ctags
    if [ -d universal_ctags ]; then
      pushd universal_ctags > /dev/null
      ./autogen.sh
      ./configure --prefix=$HOME
      make && make install
      popd > /dev/null
      rm -Rf universal_ctags
    fi
  fi

  if [ ! -f "${HOME}/.dircolors" ]; then
    info "Installing solarized dircolors"
    git clone --quiet https://github.com/seebi/dircolors-solarized
    cp dircolors-solarized/dircolors.256dark ~/.dircolors
    eval `dircolors ${HOME}/.dircolors`
    rm -Rf dircolors-solarized
  fi

}


doConfig() {
  info "Running platform configurations"

  local update=false

  if [ "$#" -eq 1 ]; then
    update=true
  fi

  mkdir -p ${HOME}/bin

  doMacOSConfig
  doLinuxConfig

  if [ ! -d "${HOME}/.fzf" ]; then
    info "Installing fzf"
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ${HOME}/.fzf/install --bin --no-update-rc --completion --key-bindings
  fi

  if [[ ${update} == true ]]; then
    if [ -d "${HOME}/.fzf" ]; then
      pushd ${HOME}/.fzf > /dev/null
      git pull --prune && ./install
      popd > /dev/null
    fi
    #
    # Since we're doing an update, just blow away the old version of these
    # files as we'll be able to replace them in a moment.
    #
    # This is a destructive process meaning we can't roll back.
    #
    if [ -f "${HOME}/.git-prompt.sh" ]; then
      rm ${HOME}/.git-prompt.sh
    fi
    if [ -f "${HOME}/.git-completion.bash" ]; then
      rm ${HOME}/.git-completion.bash
    fi
    if [ -f "${HOME}/.tigrc.vim" ]; then
      rm ${HOME}/.tigrc.vim
    fi
    if [ -f "${HOME}/bin/git-quick-stats" ]; then
      rm ${HOME}/bin/git-quick-stats
    fi
    if [ -f "${HOME}/bin/diff-so-fancy" ]; then
      rm ${HOME}/bin/diff-so-fancy
    fi
    if [ -d "${HOME}/.yarn" ]; then
      rm -Rf ${HOME}/.yarn
    fi
  fi

  if [ ! -f ${HOME}/.git-prompt.sh ]; then
    curl -L https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh -o ${HOME}/.git-prompt.sh
  fi

  if [ ! -f ${HOME}/.git-completion.bash ]; then
    curl -L https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -o ${HOME}/.git-completion.bash
  fi

  if [ ! -f ${HOME}/.tigrc.vim ]; then
    curl -L https://raw.githubusercontent.com/jonas/tig/master/contrib/vim.tigrc -o ${HOME}/.tigrc.vim
  fi

  info "Installing git-quick-stats"
  if [ ! -f ${HOME}/bin/git-quick-stats ]; then
    git clone https://github.com/arzzen/git-quick-stats.git ${HOME}/git-quick-stats
  fi
  if [ -d ${HOME}/git-quick-stats ]; then
    pushd ${HOME}/git-quick-stats > /dev/null
    #
    # The makefile is broken and appends bin to any PREFIX, so don't add in
    # the full path
    #
    make install PREFIX=${HOME}
    popd > /dev/null
    rm -Rf ${HOME}/git-quick-stats
  fi

  info "Installing diff-so-fancy"
  if [ ! -f "${HOME}/bin/diff-so-fancy" ]; then
    curl -L https://raw.githubusercontent.com/so-fancy/diff-so-fancy/master/third_party/build_fatpack/diff-so-fancy -o ${HOME}/bin/diff-so-fancy
    chmod +x ${HOME}/bin/diff-so-fancy
  fi

  if ! command -v yarn > /dev/null; then
    curl --compressed -o- -L https://yarnpkg.com/install.sh | bash
  fi
}

doAll() {
  doUpdate
  doSync
  doInstall
  doFonts
  doConfig
}

doHelp() {
  echo "Usage: $(basename "$0") [options]" >&2
  echo
  echo "   -s, --sync             Synchronizes dotfiles to home directory"
  echo "   -i, --install          Install (extra) software"
  echo "   -f, --fonts            Copies font files"
  echo "   -c, --config           Configures your system"
  echo "   -u, --update           Updates the configured files for your system"
  echo "   -a, --all              Does all of the above"
  echo
  exit 1
}

if [ $# -eq 0 ]; then
  doHelp
else
  for i in "$@"
  do
    case $i in
      -s|--sync)
        doSync
        shift
        ;;
      -i|--install)
        doInstall
        shift
        ;;
      -f|--fonts)
        doFonts
        shift
        ;;
      -c|--config)
        doConfig
        shift
        ;;
      -c|--config)
        doConfig "update"
        shift
        ;;
      -a|--all)
        doAll
        shift
        ;;
      *)
        doHelp
        shift
        ;;
    esac
  done
fi

# vim: tabstop=2 shiftwidth=2 expandtab
