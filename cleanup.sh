#!/usr/bin/env bash
#
# Originally inspired heavily from:
# https://github.com/JDevlieghere/dotfiles/blob/master/bootstrap.sh
# for the different sections.
#
# Many edits later, it's become it's own beast of a mistake
#

DOTFILES="~/dotfiles"
PLATFORM="$(uname)"

info () {
  printf "\033[00;34m$@\033[0m\n"
}

{

  info "Starting to restore pre-usage state... "

# Remove any downloaded files
  rm -Rf ${HOME}/Downloads/*.*

# Remove any cached preferences
  [ -d ${HOME}/Library/Cookies ] && rm -Rf ${HOME}/Library/Cookies
  [ -d ${HOME}/Library/Mail ] && rm -Rf ${HOME}/Library/Mail
  [ -d ${HOME}/Library/Saved\ Application\ State ] && rm -Rf ${HOME}/Library/Saved\ Application\ State
  [ -d ${HOME}/Library/Application\ Support/Microsoft/Office ] && rm -Rf ${HOME}/Library/Application\ Support/Microsoft/Office/*
  [ -d ${HOME}/.Trash ] && rm -Rf ${HOME}/.Trash/*

# Remove any git stuff
  [ -f ${HOME}/.git-completion.bash ] && rm -Rf ${HOME}/.git-completion.bash
  [ -f ${HOME}/.git-prompt.sh ] && rm -Rf ${HOME}/.git-prompt.sh

# Remove any ssh details
  [ -d ${HOME}/.ssh ] && rm -Rf ${HOME}/.ssh/*

# Remove any ctag files
  [ -d ${HOME}/.vimtags ] && rm -Rf ${HOME}/.vimtags

# Remove fzf
  [ -d ${HOME}/.fzf ] && rm -Rf ${HOME}/.fzf
  [ -f ${HOME}/.fzf.zsh ] && rm -Rf ${HOME}/.fzf.zsh

# Remove any vim files
  [ -d ${HOME}/.vim ] && rm -Rf ${HOME}/.vim
  [ -d ${HOME}/.VIM_UNDO_FILES ] && rm -Rf ${HOME}/.VIM_UNDO_FILES


# Finally clean up localy made directories by bootstrap process
# Warning this does not ensure any changes have been merged upstream
  [ -d ${HOME}/bin ] && rm -Rf ${HOME}/bin
  [ -d ${HOME}/dotfiles ] && rm -Rf ${HOME}/dotfiles

# clean up bash stuff
  [ -f ${HOME}/.bash_history ] && rm -Rf ${HOME}/.bash_history
  [ -d ${HOME}/.bash_sessions ] && rm -Rf ${HOME}/.bash_sessions

  info "Restoration is complete."

}

# vim: tabstop=2 shiftwidth=2 expandtab
