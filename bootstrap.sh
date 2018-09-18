#!/usr/bin/env bash
#
# Originally inspired heavily from:
# https://github.com/JDevlieghere/dotfiles/blob/master/bootstrap.sh
# for the different sections.
#
# Many edits later, it's become it's own beast of a mistake
#

DOTFILES="~/dotfiles"
PLATFORM="$(uname)"

info () {
  printf "\033[00;34m$@\033[0m\n"
}


doStow() {
  if hash stow 2>/dev/null; then
    stow ${1}
  else
    #
    # This is bash on windows, and there is no stow, so let's fake it... grrr...
    #
    if [ -d "${1}" ]; then
      shopt -s dotglob
      for F in ${1}/*; do
        if [ ! -f ${F} ]; then
          ln -s ${F} ${HOME}/${F##*/}
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

_installStow() {
  if [ ${PLATFORM} == "Darwin" ]; then
    if hash brew 2>/dev/null; then
      brew install stow
      return 0
    fi
  fi

  if [ ${PLATFORM} == "Linux" ]; then
    if hash apt-get 2>/dev/null; then
      if (($EUID != 0)); then
        sudo apt-get -y install stow
      else
        apt-get -y install stow
      fi
      return 0
    fi

    if hash dnf 2>/dev/null; then
      if (($EUID != 0)); then
        sudo dnf -y install stow
      else
        dnf -y install stow
      fi
      return 0
    fi
  fi

  return 1
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
}

doFonts() {
  info "Installing Fonts"

  if [ ${PLATFORM} == "Darwin" ]; then
    fonts_dir=~/Library/Fonts
  elif [ ${PLATFORM} == "Linux" ]; then
    fonts_dir=~/.local/share/fonts
  fi

  mkdir -p "${fonts_dir}"

  #
  # install the power line fonts
  # the install script already handles macOS vs linux installs
  #
  if [ ! -d "fonts" ]; then
    git clone https://github.com/powerline/fonts.git --depth=1
  fi

  if [ ! -f "codeface-fonts.zip" ]; then
    curl -OL https://github.com/chrissimpkins/codeface/releases/download/font-collection/codeface-fonts.zip
  fi

  if [ -f "codeface-fonts.zip" ]; then
    # this will expand out to a directory called "fonts" which will
    # in turn add the extra fonts to the already existing fonts directory
    # generated from the code check out
    unzip "codeface-fonts.zip"
  fi

  #
  # install only if the git command was successful
  #
  if [ -d "fonts" ]; then
    cd fonts
    # We can exploit this already provided script to install the additional
    # font pieces we need as it
    ./install.sh
    # clean-up a bit
    cd ..
    rm -rf fonts
  fi

  rm -Rf codeface-fonts.zip
}

doPipInstall() {
  pip_version=${1}

  ${pip_version} install jedi --user
  ${pip_version} install meson --user
  ${pip_version} install parso --user
  ${pip_version} install voltron --user
  ${pip_version} install powerline-status --user
}

doPython2() {
  # Check if pip is installed
  if ! type -P "pip2"; then
    #if not do the following:
    curl https://bootstrap.pypa.io/get-pip.py | python2
  fi

  doPipInstall "pip2"
}

doPython3() {

  # Check if pip is installed
  if ! type -P "pip3"; then
    #if not do the following:
    curl https://bootstrap.pypa.io/get-pip.py | python3
  fi

  doPipInstall "pip3"
}

doMacOSConfig() {
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

  # this may or may not work
  xcode-select --install > /dev/null 2>&1

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
  curl https://noahfrederick.com/get/Peppermint.1.2.terminal.zip
  unzip Peppermint.1.2.terminal.zip
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
}

doLinuxConfig() {

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
      cd universal_ctags
      ./autogen.sh
      ./configure --prefix=$HOME
      make && make install
      cd ..
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
  info "Configuring"

  local update=false

  if [ "$#" -eq 1 ]; then
    update=true
  fi

  mkdir -p ${HOME}/bin

  if [ ${PLATFORM} == "Darwin" ]; then
    echo "Configuring macOS"
    doMacOSConfig
  elif [ ${PLATFORM} == "Linux" ]; then
    echo "Configuring Linux"
    doLinuxConfig
  fi

  if [ ! -d "${HOME}/.fzf" ]; then
    info "Installing fzf"
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ${HOME}/.fzf/install --bin --no-update-rc --completion --key-bindings
  fi

  if [[ ${update} == true ]]; then
    if [ -d "${HOME}/.fzf" ]; then
      cd ${HOME}/.fzf
      git pull --prune
    fi
    #
    # Since we're doing an update, just blow away the old version of these
    # files as we'll be able to replace them in a moment.
    #
    # This is a destructive process meaning we can't roll back.
    #
    rm ${HOME}/.git-prompt.sh
    rm ${HOME}/.git-completion.bash
    rm ${HOME}/.tigrc.vim
    rm ${HOME}/bin/git-quick-stats
    rm ${HOME}/bin/diff-so-fancy
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
    curl -OL https://raw.githubusercontent.com/so-fancy/diff-so-fancy/master/third_party/build_fatpack/diff-so-fancy -o ${HOME}/bin/diff-so-fancy
    chmod +x ${HOME}/bin/diff-so-fancy
  fi
}

doAll() {
  doUpdate
  doBrew
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
  echo "   -b, --brew             Install and update Homebrew"
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
      -b|--brew)
        doBrew
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
