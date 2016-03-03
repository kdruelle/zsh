
RM_BACKUP_DIR="$HOME/.backup"



DEF_C="$(tput sgr0)"

C_BLACK="$(tput setaf 0)"
C_RED="$(tput setaf 1)"
C_GREEN="$(tput setaf 2)"
C_YELLOW="$(tput setaf 3)"
C_BLUE="$(tput setaf 4)"
C_PURPLE="$(tput setaf 5)"
C_CYAN="$(tput setaf 6)"
C_WHITE="$(tput setaf 7)"
C_GREY="$(tput setaf 8)"


function _backup-ts()                    # timestamps operations (`ts` to get current, `ts <timestamp>` to know how long ago, `ts <timestamp1> <timestamp2>` timestamp diff)
{
    local -i delta;
    local -i ts1=$(echo $1 | grep -Eo "[0-9]+" | cut -d\  -f1);
    local -i ts2=$(echo $2 | grep -Eo "[0-9]+" | cut -d\  -f1);
    local sign;

    if [ $# = 0 ]; then
        date +%s;
    elif [ $# = 1 ]; then
        delta=$(( $(date +%s) - $ts1 ));
        if [ $delta -lt 0 ]; then
            delta=$(( -delta ));
            sign="in the future";
        else
            sign="ago";
        fi
        if [ $delta -gt 30758400 ]; then echo -n "$(( delta / 30758400 ))y "; delta=$(( delta % 30758400 )); fi
        if [ $delta -gt 86400 ]; then echo -n "$(( delta / 86400 ))d "; delta=$(( delta % 86400 )); fi
        if [ $delta -gt 3600 ]; then echo -n "$(( delta / 3600 ))h "; delta=$(( delta % 3600 )); fi
        if [ $delta -gt 60 ]; then echo -n "$(( delta / 60 ))m "; delta=$(( delta % 60 )); fi
        echo "${delta}s $sign";
    elif [ $# = 2 ]; then
        delta=$(( $ts2 - $ts1 ));
        if [ $delta -lt 0 ]; then
            delta=$(( -delta ));
        fi
        if [ $delta -gt 30758400 ]; then echo -n "$(( delta / 30758400 ))y "; delta=$(( delta % 30758400 )); fi
        if [ $delta -gt 86400 ]; then echo -n "$(( delta / 86400 ))d "; delta=$(( delta % 86400 )); fi
        if [ $delta -gt 3600 ]; then echo -n "$(( delta / 3600 ))h "; delta=$(( delta % 3600 )); fi
        if [ $delta -gt 60 ]; then echo -n "$(( delta / 60 ))m "; delta=$(( delta % 60 )); fi
        echo "${delta}s";
    fi
}



function rm()                    # safe rm with timestamped backup
{
    if [ $# -gt 0 ]; then
        local backup;
        local idir;
        local rm_params;
        local i;
        idir="";
        rm_params="";
        backup="$RM_BACKUP_DIR/$(date +%s)";
        for i in "$@"; do
            if [ ${i:0:1} = "-" ]; then # if $i is an args list, save them
                rm_params+="$i";
            elif [ -f "$i" ] || [ -d "$i" ] || [ -L "$i" ] || [ -p "$i" ]; then # $i exist ?
                [ ! ${i:0:1} = "/" ] && i="$PWD/$i"; # if path is not absolute, make it absolute
                i="${i:A}";                        # simplify the path
                idir="$(dirname $i)";
                command mkdir -p "$backup/$idir";
                mv "$i" "$backup$i";
            else                # $i is not a param list nor a file/dir
                echo "'$i' not found" 1>&2;
            fi
        done
    fi
}

function save()                    # backup the files
{
    if [ $# -gt 0 ]; then
        local backup;
        local idir;
        local rm_params;
        local i;
        idir="";
        rm_params="";
        backup="$RM_BACKUP_DIR/$(date +%s)";
        command mkdir -p "$backup";
        for i in "$@"; do
            if [ ${i:0:1} = "-" ]; then # if $i is an args list, save them
                rm_params+="$i";
            elif [ -f "$i" ] || [ -d "$i" ] || [ -L "$i" ] || [ -p "$i" ]; then # $i exist ?
                [ ! ${i:0:1} = "/" ] && i="$PWD/$i"; # if path is not absolute, make it absolute
                i="${i:A}";                        # simplify the path
                idir="$(dirname $i)";
                command mkdir -p "$backup/$idir";
                if [ -d "$i" ]; then
                    cp -R "$i" "$backup$i";
                else
                    cp "$i" "$backup$i";
                fi
            else                # $i is not a param list nor a file/dir
                echo "'$i' not found" 1>&2;
            fi
        done
    fi
}

CLEAR_LINE="$(tput sgr0; tput el1; tput cub 2)"
function back()                    # list all backuped files
{
    local files;
    local peek;
    local backs;
    local to_restore="";
    local peeks_nbr=$(( (LINES) / 3 ));
    local b;
    local -i i;
    local key;

    [ -d $RM_BACKUP_DIR ] || return
    back=( $(command ls -t1 $RM_BACKUP_DIR/) );
    i=1;
    while [ $i -le $#back ] && [ -z "$to_restore" ]; do
        b=$back[i];
        files=( $(find $RM_BACKUP_DIR/$b -type f) )
        if [ ! $#files -eq 0 ]; then
            peek=""
            for f in $files; do peek+="$(basename $f), "; if [ $#peek -ge $COLUMNS ]; then break; fi; done
            peek=${peek:0:(-2)}; # remove the last ', '
            [ $#peek -gt $COLUMNS ] && peek="$(echo $peek | head -c $(( COLUMNS - 3 )) )..." # truncate and add '...' at the end if the peek is too large
            echo "$C_RED#$i$DEF_C: $C_GREEN$(_backup-ts $b)$DEF_C: $C_BLUE$(echo $files | wc -w)$DEF_C file(s) ($C_CYAN$(du -sh $RM_BACKUP_DIR/$b | cut -f1)$DEF_C)"
            echo "$peek";
            echo;
        fi
        if [ $(( i % $peeks_nbr == 0 || i == $#back )) -eq 1 ]; then
            key="";
            echo -n "> $C_GREEN";
            read -sk1 key;
            case "$(echo -n $key | cat -e)" in
                ("^[")
                    echo -n "$CLEAR_LINE";
                    read -sk2 key; # handle 3 characters arrow key press as next
                    i=$(( i + 1 ));;
                ("$"|" ")            # hangle enter and space as next
                    echo -n "$CLEAR_LINE";
                    i=$(( i + 1 ));;
                (*)                # handle everything else as a first character of backup number
                    echo -n $key; # print the silently read key on the prompt
                    read to_restore;
                    to_restore="$key$to_restore";;
            esac
            echo -n "$DEF_C"
        else
            i=$(( i + 1 ));
        fi
    done
    if [ ! -z "$back[to_restore]" ]; then
        files=( $(find $RM_BACKUP_DIR/$back[to_restore] -type f) )
        if [ ! -z "$files" ]; then
            for f in $files; do echo $f; done | command sed -r -e "s|$RM_BACKUP_DIR/$back[to_restore]||g" -e "s|/home/$USER|~|g"
                read -q "?Restore ? (Y/n): " && cp --backup=t -R ${RM_BACKUP_DIR/$back[to_restore]/*(:A)} / # create file.~1~ if file already exists
            echo;
        else
            echo "No such back"
        fi
    else
        echo "No such back"
    fi
}

# real rm
function rrm()
{
    if [ "$1" != "$HOME" -a "$1" != "/" ]; then
        command rm $@;
    fi
}


