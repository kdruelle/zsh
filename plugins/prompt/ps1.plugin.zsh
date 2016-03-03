
local plugin_path=$(dirname ${0:A})

_TERM="$TERM"
TERM="xterm-256color" && [[ $(tput colors) == 256 ]] || echo "can't use xterm-256color :/" # check if xterm-256 color is available, or if we are in a dumb shell
setopt prompt_subst                # compute PS1 at each prompt print

WORDCHARS="*?_-.[]~=/&;!#$%^(){}<>|"


SEP_C="%F{242}"                  # color separator 
ID_C="%F{33}"                    # id color
PWD_C="%F{201}"                  # pwd color
NBF_C="%F{46}"                   # files number color
NBD_C="%F{26}"                   # dir number color
TIM_C="%U%B%F{220}"              # time color
GB_C="%F{208}"                   # git branch color

GET_SHLVL="$([[ $SHLVL -gt 9 ]] && echo "+" || echo $SHLVL)" # get the shell level (0-9 or + if > 9)

GET_SSH="$([[ $(echo $SSH_TTY$SSH_CLIENT$SSH_CONNECTION) != '' ]] && echo ssh$SEP_C:)" # 'ssh:' before username if logged in ssh

PERIOD=5              # period used to hook periodic function (in sec)

_PS1=()
_PS1_DOC=()

_ssh=1                 ;_PS1_DOC+="be prefixed if connected in ssh"
_user=2                ;_PS1_DOC+="print the username"
_machine=3             ;_PS1_DOC+="print the machine name"
_wd=4                  ;_PS1_DOC+="print the current working directory"
_git_branch=5          ;_PS1_DOC+="print the current git branch if any"
_dir_infos=6           ;_PS1_DOC+="print the nb of files and dirs in '.'"
_return_status=7       ;_PS1_DOC+="print the return status of the last command (true/false)"
_git_status=8          ;_PS1_DOC+="print the status of git with a colored char (clean/dirty/...)"
_jobs=9                ;_PS1_DOC+="print the number of background jobs"
_shlvl=10              ;_PS1_DOC+="print the current sh level (shell depth)"
_user_level=11         ;_PS1_DOC+="print the current user level (root or not)"
_end_char=12           ;_PS1_DOC+="print a nice '>' at the end"


source $plugin_path/functions.zsh
source $plugin_path/zle.zsh
source $plugin_path/keyboard.zsh


check_git_repo
set_git_branch
update_pwd_datas
set_git_char
loadconf static
title
rehash                            # hash commands in path

setprompt classic


