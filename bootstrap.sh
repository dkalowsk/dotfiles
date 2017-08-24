#!/usr/bin/env bash

# borrowed heavily from:
# https://github.com/JDevlieghere/dotfiles/blob/master/bootstrap.sh

DOTFILES="~/dotfiles"

info () {
    printf "\033[00;34m$@\033[0m\n"
}

doUpdate() {
    info "Updating... "
    #
    # Now go clone the latest version of your dotfiles
    #
    if [ -d "${DOTFILES}" ]; then
	pushd ${DOTFILES}
        git pull origin master;
	popd
    else
        git clone https://github.com/dkalowsk/dotfiles ${DOTFILES}
    fi
}

doSync() {
    # Now go grab the configuration from our local area
    pushd ${DOTFILES}

    for D in `find . -type d`; do
	info "Syncing ${D}"
	stow ${D}
    done

    popd
}

doBrew() {
    # Install homebrew
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    #brew tap homebrew/bundle  # this most likely isn't needed anymore


    if [ -d "${DOTFILES}" ]; then
        pushd ${DOTFILES}
        brew bundle
        popd
    fi
}

doInstall() {
    info "Installing Extras"

    # Go grab Vundle so we can do everything
    mkdir -p ~/.vim/bundle
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

    # Tmux Plugin Manager
    #git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

    # FZF
    #git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    #~/.fzf/install

    # Now that dotfiles are in place, make sure to run the Vundle installation
    vim +PluginInstall +qall

    # this may or may not work
    xcode-select --install
}

doFonts() {
    info "Installing Fonts"

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
    #if [ "$(uname)" == "Darwin" ]; then
		#fonts=~/Library/Fonts
    #elif [ "$(uname)" == "Linux" ]; then
        #fonts=~/.fonts
        #mkdir -p "$fonts"
    #fi

    find "$DOTFILES/fonts/" -name "*.[o,t]tf" -type f | while read -r file; do
        cp -v "$file" "$fonts"
    done
}

doConfig() {
    info "Configuring"

    if [ "$(uname)" == "Darwin" ]; then
        echo "Configuring macOS"
        ./os/macos.sh
    elif [ "$(uname)" == "Linux" ]; then
        echo "Configuring Linux"
        ./os/linux.sh
    fi
}

doAll() {
    doUpdate
    if [ "$(uname)" == "Darwin" ]; then
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
