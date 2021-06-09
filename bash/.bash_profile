completion_prefix=""

if [[ "$OSTYPE" == "darwin"* ]]; then
  completion_prefix=$(brew --prefix)
fi

if [ -f "${completion_prefix}/etc/bash_completion" ]; then
. "${completion_prefix}/etc/bash_completion"
fi

if [ -z "${SSH_AUTH_SOCK}" ]; then
  if command_exists keychain; then
    if [ "Linux" == "$(uname)" ]; then
      eval "$(keychain --eval --agents ssh id_rsa id_ed25519)"
    elif [ "Darwin" == "$(uname)" ]; then
      eval "$(keychain --eval --agents ssh --inherit any id_rsa)"
    fi
  else
    echo "SSH Agent not started, install keychain"
  fi
fi

[ -f "${HOME}/.bashrc" ] && . ${HOME}/.bashrc

#
# check if the term supports color
#
color_support=no
case "${TERM}" in
  xterm-color|*-256color) color_support=yes;;
esac

echo "DRK color_support=${color_support}"

if [ ${color_support} = yes ]; then
  export PS1="\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "
  if [ -L "${HOME}/.bash_prompt" ]; then
    source "${HOME}/.bash_prompt"
    prompt_function
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
        eval "$(dircolors -b "${color_path}")"
        alias ls='ls --color=auto'
    fi
  fi
fi

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
