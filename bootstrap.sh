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
    if ! type -P "stow"; then
        if _installStow; then
            info "Installed stow"
        else
            info "This process needs the 'stow' command to work.  Install it first."
            info "On macOS this is done through brew, on linux through apt-get or dnf"
            exit 1
        fi
    fi

    for D in `find . -name "[!.]*" ! -path . -type d -maxdepth 1`; do
        mydir=${D##*/}
        info "Syncing ${mydir}"
        stow ${mydir}
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
    vim -i NONE --cmd "let plugin_install_needed=1" :PlugInstall -c quitall
}

doFonts() {
    info "Installing Fonts"

    if [ "$(uname)" == "Darwin" ]; then
		fonts_dir=~/Library/Fonts
    elif [ "$(uname)" == "Linux" ]; then
       fonts_dir=~/.local/share/fonts
       mkdir -p "${fonts_dir}"
    fi

    #
    # install the power line fonts
    # the install script already handles macOS vs linux installs
    #
	git clone https://github.com/powerline/fonts.git --depth=1

    curl -OL https://github.com/chrissimpkins/codeface/releases/download/font-collection/codeface-fonts.zip
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

    rm -Rf ${codeface}.zip
}

doPipInstall() {
    pip_version=${1}

    ${pip_version} install jedi --user
    ${pip_version} install meson --user
    ${pip_version} install parso --user
    ${pip_version} install voltron --user
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
}

doLinuxConfig() {

    info "Installing from aptgets"
    if (($EUID != 0)); then
        if [[ -t 1 ]]; then
#                sudo apt-get install $(grep -vE "^\s*#" aptgets | tr "\n" " ")
            xargs -a <(awk '! /^ *(#|$)/' "aptgets") -r -- sudo apt-get install -y 
        fi
    fi
}


doConfig() {
    info "Configuring"

    mkdir -p ~/bin

    if [ ${PLATFORM} == "Darwin" ]; then
        echo "Configuring macOS"
        doMacOSConfig
    elif [ ${PLATFORM} == "Linux" ]; then
        echo "Configuring Linux"
        doLinuxConfig
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

# vim: tabstop=4 shiftwidth=4 expandtab
