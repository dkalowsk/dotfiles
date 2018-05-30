#
# Add in local path directories
#
[ -d "${HOME}/bin" ] && export PATH="${HOME}/bin:${PATH}"
[ -d "/Applications/Araxis Merge.app/Contents/Utilities" ] && export PATH="${PATH}:/Applications/Araxis Merge.app/Contents/Utilities"
[ -d "/opt/usr/bin" ] && export PATH="/opt/usr/bin:${PATH}"

#
# Simple prompt: show user, host, path
# set the terminal line
#
export PS1="\\u@\\h \\w\\$ "
if [ -L "~/.bash_prompt" ]; then
  [ "$PS1" ] && source ~/.bash_prompt
  PROMPT_COMMAND="history -a; prompt_function"
fi

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
alias telnet=nc

#
# For git repos, enable a quick return to the root directory
#
alias gr='[ ! -z `git rev-parse --show-cdup` ] && cd `git rev-parse --show-cdup || pwd`'

#
# Enable grep for color
# Do not use the GREG_OPTIONS as they are deprecated
#
alias ggrep="grep --color=auto -rnw './' -e"
alias grep="grep --color=auto --exclude=tags --exclude=TAGS"

#
# Enable less to output raw characters
#
alias less="less -R"

#
# Force AG to use consistent colors on all platforms
#
alias ag="ag --color-path '33;36' --color-line-number '33;35' --color"


#
# Add the stgit-completion.bash for tab completion in stgit (from the STgit repo)
#
if [ -f ~/.stgit-completion.bash ]; then
    . ~/.stgit-completion.bash
fi

#
# Add the Android build tool paths
#
if [ -d "$HOME/development/android/toolchains" ]; then
	export ANDROID_TOOLCHAIN_ROOT="${HOME}/development/android/toolchains"
	export ANDROID_ARMV7="${ANDROID_TOOLCHAIN_ROOT}/android-16_arm_gnustl/bin"
	export ANDROID_X86="${ANDROID_TOOLCHAIN_ROOT}/android-16_x86_gnustl/bin"
	export ANDROIDGLES3_ARMV8="${ANDROID_TOOLCHAIN_ROOT}/android-21_arm64_gnustl/bin"
	export PATH=${PATH}:${ANDROID_ARMV7}:${ANDROIDGLES3_ARMV8}:${ANDROID_X86}
fi

#
# Add for NERDtree and sed/awk scripts to work properly
#
export LC_ALL=en_US.utf-8
export LANG="$LC_ALL"
export EDITOR='vim'

#
# Only do the following for Windows Subsystem Linux installs
#
#if grep -qE "(Microsoft|WSL)" /proc/version &> /dev/null ; then
if [[ $(uname -r) =~ Microsoft$ ]]; then
    export DISPLAY=localhost:0.0
fi

#vim () {
    ## stolen shamelessly from Spencer Krum
    ## https://github.com/nibalizer/bash-tricks/blob/master/bash_tricks.sh
    #last_command=$(history | tail -n 2 | head -n 1)
    #if [[ $last_command =~ 'git grep' ]] && [[ "$*" =~ :[0-9]+:$ ]]; then
        #line_number=$(echo $* | awk -F: '{print $(NF-1)}')
        #${EDITOR} +${line_number} ${*%:${line_number}:}
    #else
        #${EDITOR} "$@"
    #fi
#}

# private customizations
[ -f "${HOME}/.bashrc-private" ] && source ${HOME}/.bashrc-private

[ -f ${HOME}/.fzf.bash ] && source ${HOME}/.fzf.bash
[ -f ${HOME}/.git-completion.bash ] && source ${HOME}/.git-completion.bash
