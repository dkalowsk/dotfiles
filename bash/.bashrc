
# Simple function to check if a command exists
command_exists() {
  type "$1" &> /dev/null ;
}

if command_exists keychain; then
  if [ "Linux" == "$(uname)" ]; then
    eval `keychain --eval --agents ssh id_rsa`
  elif [ "Darwin" == "$(uname)" ]; then
    eval `keychain --eval --agents ssh --inherit any id_rsa`
  fi
else
  echo "SSH Agent not started, install keychain"
fi


#
# Append to history file, don't over write it
# And limit the size it can grow to
#
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000

#
# Add in local path directories
path_additions=(
  "${HOME}/bin"
  "${HOME}/.local/bin"
  "${HOME}/Library/Python/3.6/bin"
  "${HOME}/Library/Python/3.7/bin"
  "${HOME}/.yarn/bin"
  "/opt/usr/bin"
  "/opt/bin"
  "/usr/local/sbin"
  # These are Darwin specific but it doesn't matter
  # as the directory won't exist, so they won't do anything
  "/Applications/Araxis Merge.app/Contents/Utilities"
  "/Applications/010 Editor.app/Contents/CmdLine"
)

for entry in "${path_additions[@]}"
do
  # Does the directory exist and is it already in the PATH variable
  # if yes and no, then add it
  # else, just skip the entry.
  #echo -n "Checking ${entry}... "
  if [ -d "${entry}" ] && [[ "${PATH}" != *"${entry}"* ]]; then
    #echo "added"
    export PATH="${PATH}:$entry"
  #else
  #  echo "skipped"
  fi
done

export ZEPHYR_TOOLCHAIN_VARIANT=zephyr
export ZEPHYR_SDK_INSTALL_DIR=/opt/zephyr-sdk-0.11.2

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
color_support=no
case "${TERM}" in
  xterm-color|*-256color) color_support=yes;;
esac
#
# add color ls output
#
if [ ${color_support} = yes ]; then
  export PS1="\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "
  if [ -L "~/.bash_prompt" ]; then
    [ "$PS1" ] && source ${HOME}/.bash_prompt && prompt_function
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
        # use ${HOME}/.dircolors if user has specified one
        [ -r "${HOME}/.dircolors" ] && color_path="${HOME}/.dircolors" || color_path=""
        eval "$(dircolors -b ${color_path})"
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
if [ "Darwin" == "$(uname)" ]; then
  alias top="top -o cpu"
fi
[ -x "/usr/local/bin/python3" ] && alias python=/usr/local/bin/python3

#
# For git repos, enable a quick return to the root directory
#
alias gr='[ ! -z `git rev-parse --show-cdup` ] && cd `git rev-parse --show-cdup || pwd`'

#
# Enable grep for color
# Do not use the GREG_OPTIONS as they are deprecated
#
alias ggrep='grep ${GGREP_FLAGS}'
alias grep='grep ${GREP_FLAGS}'

#
# Enable less to output raw characters
#
export LESS="-RXF"
export LESSOPEN='|~/.lessfilter %s'


#
# Add the stgit-completion.bash for tab completion in stgit (from the STgit repo)
#
[ -f "${HOME}/.stgit-completion.bash" ] && source "${HOME}/.stgit-completion.bash"

#
# Add the Android build tool paths
#
if [ -d "$HOME/development/android/android-ndk-r20" ]; then
  export NDK_HOME="${HOME}/development/android/android-ndk-r20"
  if [[ "$OSTYPE" == "linux-gnu" ]]; then
    export NDK_BIN="${NDK_HOME}/toolchains/llvm/prebuilt/linux-x86_64/bin"
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    export NDK_BIN="${NDK_HOME}/toolchains/llvm/prebuilt/darwin-x86_64/bin"
  elif [[ "$OSTYPE" == "msys" ]]; then
    export NDK_BIN="${NDK_HOME}/toolchains/llvm/prebuilt/linux-x86_64/bin"
  fi
  export PATH="${PATH}:${NDK_HOME}:${NDK_BIN}"
fi

#
# Add for NERDtree and sed/awk scripts to work properly
#
#export LC_ALL=en_US.utf-8
export LANG="en_US.UTF-8"

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

source_additions=(
  "${HOME}/.bashrc-private"
  "${HOME}/.fzf.bash"
  "${HOME}/.git-completion.bash"
)

for entry in "${source_additions[@]}"; do
  #echo -n "Sourcing ${entry}... "
  if [ -f "${entry}" ]; then
    #echo "done"
    source "${entry}"
  #else
  #  echo "skipped"
  fi
done
