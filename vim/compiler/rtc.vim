if exists("current_compiler")
  finish
endif

" Record the old values
let old_makeprg=&makeprg
let old_errorformat=&errorformat

let current_compiler="rtc"
let &makeprg='./runtimecore_scripts/scripts/build.sh -k defaults_macos'
let &errorformat='%f:%l:\ %m'
