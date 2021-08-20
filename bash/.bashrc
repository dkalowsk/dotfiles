
# Simple function to check if a command exists
command_exists() {
  type "$1" &> /dev/null ;
}

if command_exists keychain; then
  if [ "Linux" == "$(uname)" ]; then
    eval `keychain --eval --agents ssh id_rsa id_ed25519 id_rsa_cadence`
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
  "${HOME}/.gem/bin"
  "${HOME}/.local/bin"
  "${HOME}/Library/Python/3.6/bin"
  "${HOME}/Library/Python/3.7/bin"
  "${HOME}/.yarn/bin"
  "/opt/usr/bin"
  "/opt/bin"
  "/usr/local/sbin"
  "${HOME}/.gem/ruby/2.7.0/bin"
  # These are Darwin specific but it doesn't matter
  # as the directory won't exist, so they won't do anything
  "/Applications/Araxis Merge.app/Contents/Utilities"
  "/Applications/010 Editor.app/Contents/CmdLine"
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
# Enable color output
#
if [ ${color_support} = yes ]; then
  export PS1="\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "
  if [ -L "${HOME}/.bash_prompt" ]; then
    if [ "$PS1" ]; then
      source "${HOME}/.bash_prompt"
      prompt_function
      PROMPT_COMMAND="history -a; prompt_function"
    else
      PROMPT_COMMAND="history -a"
    fi
  fi

  LS_OPTIONS=

  #
  # Setup alias for ls
  if command_exists exa ; then
    alias tree="exa --tree"
    alias ls="exa --group-directories-first"
    alias ll="exa --long --git --group-directories-first"
  else
    if [ "Darwin" == "$(uname)" ]; then
      #export LSCOLORS="GxGxBxDxCxEgEdxbxgxcxd"
      #export LSCOLORS="ExFxBxDxCxegedabagacad"
      # Value from: https://github.com/seebi/dircolors-solarized/issues/10#issuecomment-381545995
      export LSCOLORS="exfxfeaeBxxehehbadacea"
      export CLICOLOR=true
      export CLICOLOR=1
      LS_OPTIONS="-GFh"
    elif [ "Linux" == "$(uname)" ]; then
      if [ -x /usr/bin/dircolors ]; then
          # use ${HOME}/.dircolors if user has specified one
          [ -r "${HOME}/.dircolors" ] && color_path="${HOME}/.dircolors" || color_path=""
          eval "$(dircolors -b ${color_path})"
          LS_OPTIONS="--color=auto"
      fi
    fi
    alias ls="ls ${LS_OPTIONS}"
    alias ll="ls ${LS_OPTIONS} -Al"
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
[ -x "/usr/bin/python3" ] && alias python=/usr/bin/python3

#
# For git repos, enable a quick return to the root directory
#
alias gr='[ ! -z `git rev-parse --show-cdup` ] && cd `git rev-parse --show-cdup || pwd`'


#
# Enable less to output raw characters
#
export LESS="-RXF"
export LESSOPEN='|~/.lessfilter %s'

#
# Add the Android build tool paths
#
if [ -d "$HOME/development/android/android-ndk" ]; then
  export NDK_HOME="${HOME}/development/android/android-ndk"
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
#export LANG="en_US.UTF-8"

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

if command -v ag >/dev/null; then
    alias ag="ag --ignore '*tags'"
fi

# Clean out all docker pieces older than a week old
DOCKER_IMAGE_TIMEOUT="168h"
alias docker-clean=' \
  docker container prune --filter "until=${DOCKER_IMAGE_TIMEOUT}" ; \
  docker image prune --all --filter "until=${DOCKER_IMAGE_TIMEOUT}" ; \
  docker network prune --filter "until=${DOCKER_IMAGE_TIMEOUT}" ; \
  docker volume prune --filter "until=${DOCKER_IMAGE_TIMEOUT}" '

# Alias for rg (ripgrep) to do paging
if command -v rg >/dev/null; then
    export RIPGREP_CONFIG_PATH=~/.config/ripgrep/ripgrep.rc
    export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob "!.git/*"'
    function rg {
        command rg --smart-case --pretty "$@" | command less --no-init --RAW-CONTROL-CHARS --quit-if-one-screen
    }
    function rgg {
        command rg --smart-case "$@"
    }
else
  #
  # Enable grep for color
  # Do not use the GREG_OPTIONS as they are deprecated
  #
  alias ggrep="grep ${GGREP_FLAGS}"
  alias grep="grep ${GREP_FLAGS}"
fi

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
  "${HOME}/.stgit-completion.bash"
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

# GIT heart FZF
# -------------

is_in_git_repo() {
  command git rev-parse HEAD > /dev/null 2>&1
}


fzf-down() {
  command fzf --height 50% "$@" --border
}

# F for files
# B for branches
# T for tags
# R for remotes
# H for commit hashes

# For choosing modified/untracked files
_gf() {
    is_in_git_repo || return
    command git -c color.status=always status --short |
    fzf-down -m --ansi --nth 2..,.. \
      --preview '(git diff --color=always -- {-1} | sed 1,4d; cat {-1}) | head -500' |
    cut -c4- | sed 's/.* -> //'
}

# For choosing branches
_gb() {
  is_in_git_repo || return
  command git branch -a --color=always | grep -v '/HEAD\s' | sort |
  fzf-down --ansi --multi --tac --preview-window right:70% \
    --preview 'git log --oneline --graph --date=short --color=always --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1) | head -'$LINES |
  sed 's/^..//' | cut -d' ' -f1 |
  sed 's#^remotes/##'
}

# For choosing tags
_gt() {
  is_in_git_repo || return
  command git tag --sort -version:refname |
  fzf-down --multi --preview-window right:70% \
    --preview 'git show --color=always {} | head -'$LINES
}

# For choosing commit hashes
_gh() {
  is_in_git_repo || return
  command git log --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" --graph --color=always |
  fzf-down --ansi --no-sort --reverse --multi --bind 'ctrl-s:toggle-sort' \
    --header 'Press CTRL-S to toggle sort' \
    --preview 'grep -o "[a-f0-9]\{7,\}" <<< {} | xargs git show --color=always | head -'$LINES |
  grep -o "[a-f0-9]\{7,\}"
}

# For choosing remotes
_gr() {
  is_in_git_repo || return
  command git remote -v | awk '{print $1 "\t" $2}' | uniq |
  fzf-down --tac \
    --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" {1} | head -200' |
  cut -d$'\t' -f1
}

bind '"\er": redraw-current-line'
bind '"\C-g\C-f": "$(_gf)\e\C-e\er"'
bind '"\C-g\C-b": "$(_gb)\e\C-e\er"'
bind '"\C-g\C-t": "$(_gt)\e\C-e\er"'
bind '"\C-g\C-h": "$(_gh)\e\C-e\er"'
bind '"\C-g\C-r": "$(_gr)\e\C-e\er"'
