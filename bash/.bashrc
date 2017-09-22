#
# Add in local path directories
#
[ -d "${HOME}/bin" ] && export PATH="${HOME}/bin:${PATH}"
[ -d "${HOME}/development/hackhack" ] && export PATH="${HOME}/development/hackhack:${PATH}"
[ -d "/Applications/Araxis Merge.app/Contents/Utilities" ] && export PATH="${PATH}:/Applications/Araxis Merge.app/Contents/Utilities"

#
# Setup the QT home directory
#
[ -d "/usr/local/opt/qt" ] && export QT_HOME="/usr/local/opt/qt"

#
# Simple prompt: show user, host, path
# set the terminal line
#
export PS1="\\u@\\h \\w\\$ "

#
# add color ls output
#
if [ "Darwin" == "$(uname)" ]; then
	#export LSCOLORS="GxGxBxDxCxEgEdxbxgxcxd"
	export LSCOLORS="ExFxBxDxCxegedabagacad"
	export CLICOLOR=true
	export CLICOLOR=1
	alias ls='ls -GFh'
elif [ "Linux" == "$(uname)" ]; then
	if [ -x /usr/bin/dircolors ]; then
	    # use ~/.dircolors if user has specified one
	    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
	    alias ls='ls --color=auto'
	fi
fi

alias ffind='find . -name'

#
# Enable grep for color
# Do not use the GREG_OPTIONS as they are deprecated
#
alias ggrep="grep --color=auto -rnw './' -e"
alias grep="grep --color=auto --exclude=tags --exclude=TAGS"

#
# Add the git bash completion option
#
if [ "Darwin" == "$(uname)" ]; then
	if [ -f $(brew --prefix)/etc/bash_completion  ]; then
	    . $(brew --prefix)/etc/bash_completion
	fi
fi

#
# Add the stgit-completion.bash for tab completion in stgit (from the STgit repo)
#
if [ -f ./.stgit-completion.bash ]; then
    . ~/.stgit-completion.bash
fi

#
# Add the Android build tool paths
#
if [ -d "$HOME/development/android/toolchains" ]; then
	export ANDROID_TOOLCHAIN_ROOT="${HOME}/development/android/toolchains"
	export ANDROID_ARMV7="${ANDROID_TOOLCHAIN_ROOT}/android-14_arm-linux-androideabi-4.9/bin"
	export ANDROID_X86="${ANDROID_TOOLCHAIN_ROOT}/android-14_x86-4.9/bin"
	export ANDROIDGLES3_ARMV7="${ANDROID_TOOLCHAIN_ROOT}/android-21_arm-linux-androideabi-4.9/bin"
	export ANDROIDGLES3_ARMV8="${ANDROID_TOOLCHAIN_ROOT}/android-21_aarch64-linux-android-4.9/bin"
	export ANDROIDGLES3_X86="${ANDROID_TOOLCHAIN_ROOT}/android-21_x86-4.9/bin"
	export ANDROIDGLES3_X64="${ANDROID_TOOLCHAIN_ROOT}/android-21_x86_64-4.9/bin"
	export PATH=${PATH}:${ANDROIDGLES3_ARMV7}:${ANDROIDGLES3_ARMV8}:${ANDROIDGLES3_X86}:${ANDROIDGLES3_X64}
fi

#
# Add for NERDtree and sed/awk scripts to work properly
#
export LC_ALL=en_US.utf-8
export LANG="$LC_ALL"
export EDITOR='vim'

export CCACHE_HOME=/usr/local/bin/ccache

# private customizations
[ -f "~/.bashrc-private" ] && . ~/.bashrc-private
