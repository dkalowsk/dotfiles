
# Simple function to check if a command exists
command_exists() {
	type "$1" &> /dev/null ;
}

#
# Append to history file, don't over write it
# And limit the size it can grow to
#
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000

#
# Add in local path directories
[ -d "${HOME}/bin" ] && export PATH="${PATH}:${HOME}/bin"
[ -d "/Applications/Araxis Merge.app/Contents/Utilities" ] && export PATH="${PATH}:/Applications/Araxis Merge.app/Contents/Utilities"
[ -d "/opt/usr/bin" ] && export PATH="${PATH}:/opt/usr/bin"
[ -d "/opt/bin" ] && export PATH="${PATH}:/opt/bin"
[ -d "/usr/local/sbin" ] && export PATH="${PATH}:/usr/local/sbin"
[ -d "${HOME}/Library/Python/3.6/bin" ] && export PATH="${PATH}:${HOME}/Library/Python/3.6/bin"
[ -d "${HOME}/Library/Python/3.7/bin" ] && export PATH="${PATH}:${HOME}/Library/Python/3.7/bin"
[ -d "${HOME}/Library/Python/2.7/bin" ] && export PATH="${PATH}:${HOME}/Library/Python/2.7/bin"
[ -d "${HOME}/.yarn/bin" ] && export PATH="${PATH}:${HOME}/.yarn/bin"
[ -d  "/Applications/010 Editor.app/Contents/CmdLine" ] && export PATH="$PATH:/Applications/010 Editor.app/Contents/CmdLine"

if hash rbenv 2>/dev/null; then
  eval "$(rbenv init -)"
fi
#
# Simple prompt: show user, host, path
# set the terminal line
#

GGREP_FLAGS="-rnw './' -e"
GREP_FLAGS="--exclude=tags --exclude=TAGS"
#
# check if the term supports color
#
case "${TERM}" in
	xterm-color|*-256color) color_support=yes;;
esac
#
# add color ls output
#
if [ ${color_support} = yes ]; then
	export PS1="\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "
	if [ -L "~/.bash_prompt" ]; then
	  [ "$PS1" ] && source ${HOME}/.bash_prompt && prompt_fuction
	  PROMPT_COMMAND="history -a; prompt_function"
	fi

	if [ "Darwin" == "$(uname)" ]; then
		#export LSCOLORS="GxGxBxDxCxEgEdxbxgxcxd"
		#export LSCOLORS="ExFxBxDxCxegedabagacad"
		# Value from: https://github.com/seebi/dircolors-solarized/issues/10#issuecomment-381545995
		export LSCOLORS="exfxfeaeBxxehehbadacea"
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
	GGREP_FLAGS="--color=auto ${GGREP_FLAGS}"
	GREP_FLAGS="--color=auto ${GREP_FLAGS}"

	#
	# Force AG to use consistent colors on all platforms
	#
	alias ag="ag --color-path '33;36' --color-line-number '33;35' --color"

fi

alias ffind='find . -name'
alias telnet=nc
alias top="top -o cpu"

#
# For git repos, enable a quick return to the root directory
#
alias gr='[ ! -z `git rev-parse --show-cdup` ] && cd `git rev-parse --show-cdup || pwd`'

#
# Enable grep for color
# Do not use the GREG_OPTIONS as they are deprecated
#
alias ggrep="grep ${GGREP_FLAGS}"
alias grep="grep ${GREP_FLAGS}"

#
# Enable less to output raw characters
#
alias less="less -R"

#
# Add the stgit-completion.bash for tab completion in stgit (from the STgit repo)
#
[ -f ${HOME}/.stgit-completion.bash ] && source ${HOME}/.stgit-completion.bash

#
# Add the Android build tool paths
#
if [ -d "$HOME/development/android/toolchains" ]; then
	export ANDROID_TOOLCHAIN_ROOT="${HOME}/development/android/toolchains"
	export ANDROID_ARMV7="${ANDROID_TOOLCHAIN_ROOT}/android-19_arm_r18b/bin"
	export ANDROID_X86="${ANDROID_TOOLCHAIN_ROOT}/android-19_x86_r18b/bin"
	export ANDROID_ARM64="${ANDROID_TOOLCHAIN_ROOT}/android-21_arm64_r18b/bin"
	export PATH=${PATH}:${ANDROID_ARMV7}:${ANDROID_ARM64}:${ANDROID_X86}
fi

#
# Add for NERDtree and sed/awk scripts to work properly
#
export LC_ALL=en_US.utf-8
export LANG="$LC_ALL"

if command_exists /opt/bin/nvim ; then
	export EDITOR='/opt/bin/nvim'
	alias vim='/opt/bin/nvim'
	alias nvim='/opt/bin/nvim'
elif command_exists nvim ; then
	export EDITOR='nvim'
	alias vim='nvim'
else
	export EDITOR='vim'
fi

alias ag="ag --ignore '*tags'"

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
