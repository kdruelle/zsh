

zmodload zsh/complist   # load compeltion list

autoload _setxkbmap     # load setxkbmap autocompletion

### SETTING UP ZSH COMPLETION STUFF ###

zstyle ':completion:*:(rm|cp|mv|emacs):*' ignore-line yes   # remove suggestion if already in selection
zstyle ':completion:*' ignore-parents parent pwd»           # avoid stupid ./../currend_dir

zstyle ":completion:*" menu select                          # select menu completion

zstyle ':completion:*:*' list-colors ${(s.:.)LS_COLORS}     # ls colors for files/dirs completion

zstyle ":completion:*" group-name ""                        # group completion

zstyle ":completion:*:warnings" format "Nope !"             # custom error

#zstyle ":completion:::::" completer _complete _approximate  # approx completion after regular one
#zstyle ":completion:*:approximate:*" max-errors "(( ($#BUFFER)/3 ))" # allow one error each 3 characters

zle -C complete-file complete-word _generic
zstyle ':completion:complete-file::::' completer _files

zstyle ':completion:*' file-sort modification               # newest files at first

zstyle ":completion:*:descriptions" format "%B%d%b"         # completion group in bold

compdef _setxkbmap setxkbmap                                # activate setxkbmap autocompletion


### HOMEMADE FUNCTIONS COMPLETION ###




_kbd() { _alternative "1:layouts:(('us:qwerty keyboard layout' 'fr:azerty keyboard layout'))" "2:capslock rebinds:(('caps-ctrl:capslock as control' 'caps-esc:capslock as escape' 'caps-super:capslock as super'))" }
compdef _kbd kbd



