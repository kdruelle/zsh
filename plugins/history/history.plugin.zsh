HISTFILE=~/.zshrc_history
SAVEHIST=65536
HISTSIZE=65536


setopt inc_append_history
setopt share_history
setopt hist_ignore_dups         # ignore dups in history
setopt hist_expire_dups_first   # remove all dubs in history when full

function up-line-or-search-prefix () # smart up search (search in history anything matching before the cursor)
{
    local CURSOR_before_search=$CURSOR
    zle up-line-or-search "$LBUFFER"
    CURSOR=$CURSOR_before_search
}; zle -N up-line-or-search-prefix

function down-line-or-search-prefix () # same with down
{
    local CURSOR_before_search=$CURSOR
    zle down-line-or-search "$LBUFFER"
    CURSOR=$CURSOR_before_search
}; zle -N down-line-or-search-prefix


key[up]=$terminfo[kcuu1]
key[down]=$terminfo[kcud1]
key[C-up]="^[[1;5A"
key[C-down]="^[[1;5B"

bindkey $key[up] up-line-or-history # up/down scroll through history
bindkey $key[down] down-line-or-history

bindkey $key[C-up] up-line-or-search-prefix # ctrl + arrow = smart completion
bindkey $key[C-down] down-line-or-search-prefix



