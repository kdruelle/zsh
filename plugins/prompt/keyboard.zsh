

bindkey -e


typeset -Ag key              # associative array with more explicit names

key[up]=$terminfo[kcuu1]
key[down]=$terminfo[kcud1]
key[left]=$terminfo[kcub1]
key[right]=$terminfo[kcuf1]

key[C-up]="^[[1;5A"
key[C-down]="^[[1;5B"
key[C-left]="^[[1;5D"
key[C-right]="^[[1;5C"

key[M-up]="^[[1;3A"
key[M-down]="^[[1;3B"
key[M-left]="^[[1;3D"
key[M-right]="^[[1;3C"

key[S-up]=$terminfo[kri]
key[S-down]=$terminfo[kind]
key[S-left]=$terminfo[kLFT]
key[S-right]=$terminfo[kRIT]

key[tab]=$terminfo[kRIT]
key[S-tab]=$terminfo[cbt]

key[C-space]="^@"

key[enter]=$terminfo[cr]
key[M-enter]="^[^J"

case "$OS" in
    (*cygwin*)     key[C-enter]="^^";;
    (*)            key[C-enter]="^J";;
esac

key[F1]=$terminfo[kf1]
key[F2]=$terminfo[kf2]
key[F3]=$terminfo[kf3]
key[F4]=$terminfo[kf4]
key[F5]=$terminfo[kf5]
key[F6]=$terminfo[kf6]
key[F7]=$terminfo[kf7]
key[F8]=$terminfo[kf8]
key[F9]=$terminfo[kf9]
key[F10]=$terminfo[kf10]
key[F11]=$terminfo[kf11]
key[F12]=$terminfo[kf12]

bindkey $key[left] backward-char
bindkey $key[right] forward-char

bindkey $key[M-right] move-text-right
bindkey $key[M-left] move-text-left

bindkey "^X^E" edit-command-line # edit line with $EDITOR

bindkey "^Z" ctrlz            # ctrl z zsh

bindkey "^D" delete-char

bindkey "^X^X" exchange-point-and-mark

bindkey "^X^K" show-kill-ring

bindkey "\`\`" sub-function
bindkey "\'\'" simple-quote
bindkey "\"\"" double-quote

bindkey $key[C-left] backward-word
bindkey $key[C-right] forward-word

bindkey "^[k" kill-word
bindkey "^W" kill-region         # emacs-like kill

bindkey "^Y" yank                # paste
bindkey "^[y" yank-pop            # rotate yank array

bindkey $key[S-tab] reverse-menu-complete # shift tab for backward completion

bindkey "^[=" save-line



bindkey $key[S-right] select-right # emacs like shift selection
bindkey $key[S-left] select-left

bindkey $key[C-enter] clear-and-accept

bindkey $key[F1] run-help
bindkey $key[F5] clear-screen



bindkey -s ";;" "~"

