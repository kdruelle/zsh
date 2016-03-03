
function open-delims() # open and close quoting chars and put the cursor at the beginning of the quoting
{
    if [ $# -eq 2 ]; then
        BUFFER="$LBUFFER$1$2$RBUFFER"
        CURSOR+=$#1;
    fi
}; zle -N open-delims

function simple-quote() zle open-delims \' \'
zle -N simple-quote

function double-quote() zle open-delims \" \"
zle -N double-quote

function sub-function() zle open-delims "\$(" ")"
zle -N sub-function

function ctrlz()
{
    suspend;
}; zle -N ctrlz



function shift-arrow()            # emacs-like shift selection
{
    ((REGION_ACTIVE)) || zle set-mark-command;
    zle $1;
}; zle -N shift-arrow

function select-left() shift-arrow backward-char; zle -N select-left
function select-right() shift-arrow forward-char; zle -N select-right



