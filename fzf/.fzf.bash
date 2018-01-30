# Setup fzf
# ---------
if [[ ! "$PATH" == *${HOME}/.fzf/bin* ]]; then
  export PATH="$PATH:${HOME}/.fzf/bin"
fi

# Auto-completion & key-bindings
# ---------------
if [ "$OSTYPE" == "darwin"* ]; then
	if [ -e $(brew --prefix)/opt/fzf/shell/completion.bash ]; then
		source $(brew --prefix)/opt/fzf/shell/key-bindings.bash
		source $(brew --prefix)/opt/fzf/shell/completion.bash
	fi
fi
if [ "${OSTYPE}" == "linux"* ]; then
	[ -f ${HOME}/.fzf/shell/completion.bash ] && source "${HOME}/.fzf/shell/completion.bash" 2> /dev/null
	[ -f ${HOME}/.fzf/shell/key-bindings.bash ] && source "${HOME}/.fzf/shell/key-bindings.bash"
fi

if [[ -x "$(command -v fzf)" ]] && [[ -x "$(command -v ag)" ]]; then
  export FZF_DEFAULT_COMMAND='ag --nocolor -g ""'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_DEFAULT_OPTS='
  --color fg:242,bg:236,hl:65,fg+:15,bg+:239,hl+:108
  --color info:108,prompt:109,spinner:108,pointer:168,marker:168
  '
fi


