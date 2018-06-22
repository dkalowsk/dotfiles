completion_prefix=""

if [ "$OSTYPE" == "darwin17" ]; then
  completion_prefix=$(brew --prefix)
fi

if [ -f "${completion_prefix}/etc/bash_completion" ]; then
. "${completion_prefix}/etc/bash_completion"
fi

[ -f "${HOME}/.bashrc" ] && . ${HOME}/.bashrc
