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
    git stash
    git pull --rebase
    git stash pop
}

doSync() {
    if ! type -P "stow"; then
	    if hash brew 2>/dev/null; then
            brew install stow
        else
            info "This process needs the 'stow' command to work.  Install it first."
            info "On macOS this is done through brew, on linux through apt-get"
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

    # this may or may not work
    if [ ${PLATFORM} == "Darwin" ]; then
        xcode-select --install
    fi
}

doFonts() {
    info "Installing Fonts"

    #
    # install the power line fonts
    # the install script already handles macOS vs linux installs
    #
	git clone https://github.com/powerline/fonts.git --depth=1
	#
	# install only if the git command was successful
	#
	if [ -d "fonts" ]; then
		cd fonts
		./install.sh
		# clean-up a bit
		cd ..
		rm -rf fonts
	fi
#    if [ "$(uname)" == "Darwin" ]; then
#		fonts=~/Library/Fonts
#    elif [ "$(uname)" == "Linux" ]; then
#       fonts=~/.fonts
#       mkdir -p "$fonts"
#    fi
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


doConfig() {
    info "Configuring"

    if [ ${PLATFORM} == "Darwin" ]; then
        echo "Configuring macOS"
    elif [ ${PLATFORM} == "Linux" ]; then
        echo "Configuring Linux"
        if (($EUID != 0)); then
            if [[ -t 1 ]]; then
#                sudo apt-get install $(grep -vE "^\s*#" aptgets | tr "\n" " ")
                xargs -a <(awk '! /^ *(#|$)/' "aptgets") -r -- sudo apt-get install -y 
            fi
        fi
    fi
}

doAll() {
    doUpdate
    if [ ${PLATFORM} == "Darwin" ]; then
        # doBrew need to happen before doSync because there is no promise
        # that stow will be available on the system if it is macOS
        doBrew
    fi
    doSync
    doInstall
    doFonts
#    doConfig
}

doHelp() {
    echo "Usage: $(basename "$0") [options]" >&2
    echo
    echo "   -s, --sync             Synchronizes dotfiles to home directory"
    echo "   -i, --install          Install (extra) software"
    echo "   -b, --brew             Install and update Homebrew"
    echo "   -f, --fonts            Copies font files"
#    echo "   -c, --config           Configures your system"
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
#            -c|--config)
#                doConfig
#                shift
#                ;;
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
