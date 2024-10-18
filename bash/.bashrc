#!/usr/bin/env bash
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
# Add the Android build tool paths
#
NDK_HOME=
NDK_BIN=
if [ -d "$HOME/development/android/android-ndk" ]; then
  NDK_HOME="${HOME}/development/android/android-ndk"
  if [[ "$OSTYPE" == "linux-gnu" ]]; then
    NDK_BIN="${NDK_HOME}/toolchains/llvm/prebuilt/linux-x86_64/bin"
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    NDK_BIN="${NDK_HOME}/toolchains/llvm/prebuilt/darwin-x86_64/bin"
  elif [[ "$OSTYPE" == "msys" ]]; then
    NDK_BIN="${NDK_HOME}/toolchains/llvm/prebuilt/linux-x86_64/bin"
  fi
fi

#
# Add in local path directories
#
path_additions=(
  "${HOME}/bin"
  "${HOME}/.cargo/bin"
  "${HOME}/.gem/bin"
  "${HOME}/.local/bin"
  "${HOME}/Library/Python/3.9/bin"
  "${HOME}/Library/Python/3.10/bin"
  "${HOME}/.yarn/bin"
  "${HOME}/go/bin"
  "/opt/usr/bin"
  "/opt/bin"
  "/usr/local/sbin"
  # These are Darwin specific but it doesn't matter
  # as the directory won't exist, so they won't do anything
  "/Applications/Araxis Merge.app/Contents/Utilities"
  "/Applications/010 Editor.app/Contents/CmdLine"
  # Android specific additions
  "${NDK_HOME}"
  "${NDK_BIN}"
)
if [[ "$OSTYPE" == "darwin"* ]]; then
  path_additions+=("$(eval "$(/bin/brew shellenv)")")
fi

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

if command_exists rbenv ; then
  eval "$(rbenv init -)"
fi

GGREP_FLAGS="-rnw './' -e"
GREP_FLAGS="--exclude=tags --exclude=TAGS"

#
# Enable less to output raw characters
#
export LESS="-RXF"
export LESSOPEN='|~/.lessfilter %s'


# Alias for rg (ripgrep) to do paging
if command_exists rg ; then
    export RIPGREP_CONFIG_PATH=~/.config/ripgrep/ripgrep.rc
    export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob "!.git/*"'
    function rg {
        command rg --smart-case --pretty "$@" | command less --no-init --RAW-CONTROL-CHARS --quit-if-one-screen
    }
    function rgg {
        command rg --smart-case "$@"
    }
fi

if command_exists batcat ; then
    alias bat="batcat --color-always --style=numbers"
    alias fzf="fzf --preview 'batcat --color-always --style=numbers --line-range=:500 {}'"
fi

# Thanks to jvillalovos for this
# now combine to form frg for search
function frg {
    declare -a fzf_args
    declare bat_cmd
    bat_cmd="command batcat --color=always {1} --theme='Dracula' --highlight-line {2}"

    fzf_args+=(--ansi)
    fzf_args+=(--color 'hl:-1:underline,hl+:-1:underline:reverse')
    fzf_args+=(--delimiter ':')
    fzf_args+=(--preview "${bat_cmd}")
    fzf_args+=(--preview-window 'up,60%,border-bottom,+{2}+3/3,~3')

    result=$(command rg --sort path --smart-case --color=always --line-number --no-heading "$@" | command fzf "${fzf_args[@]}")

    file="${result%%:*}"
    linenumber=$(echo "${result}" | cut -d: -f2)
    if [ -n "$file" ]; then
        ${EDITOR} +"${linenumber}" "$file"
    fi
}
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
  "${HOME}/.dan_profile"
  "${HOME}/.bashrc-private"
  "${HOME}/.fzf.bash"
  "${HOME}/.git-completion.bash"
  "${HOME}/.stgit-completion.bash"
  "/usr/share/virtualenvwrapper/virtualenvwrapper.sh"
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

##
##
# Command aliases
##
##

function ccd {
    if [ -n "{$1:-}" ]; then
        mkdir -p "$1" && cd "$1"
    else
        echo "ERROR: missing name of new directory"
    fi
}

alias ll='ls --color=auto -Al'
alias ffind='find . -iname'

if [ "Darwin" == "$(uname)" ]; then
  alias telnet=nc
  alias top="top -o cpu"
fi

[ "$TERM" = "xterm-kitty" ] && alias ssh='kitty +kitten ssh'

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

if command_exists ag ; then
    alias ag="ag --ignore '*tags'"
fi
