
# if 0 params, acts like 'cd -', else, act like the regular '-'
function -()
{
    [[ $# -eq 0 ]] && cd - || builtin - "$@"
}

# percent of the home taken by this dir/file
function pc()
{
    local subdir
    local dir 

    if [ "$#" -eq 0 ]; then
        subdir=.
        dir=$HOME
        else if [ "$#" -eq 1 ]; then
            subdir=$1
            dir=$HOME
            else if [ "$#" -eq 2 ]; then
                subdir=$1
                dir=$2
            else
                echo "Usage: pc <dir/file a>? <dir b>? to get the % of the usage of b by a"
                return 1
            fi
        fi
    fi
    echo "$(($(du -sx $subdir | cut -f1) * 100 / $(du -sx $dir | cut -f1)))" "%" 
}


# find arg1 in all files from arg2 or .
function ft()
{
    command find ${2:=.} -type f -exec grep --color=always -InH -e "$1" {} +; # I (ignore binary) n (line number) H (print fn each line)
}

# faster find allowing easier parameters in disorder
function ff()
{
    local p
    local name=""
    local type="" 
    local additional=""
    local hidden=" -not -regex .*/\..*" # hide hidden files by default
    local root="."
    for p in "$@"; do
        if $(echo $p | grep -Eq "^n?[herwxbcdflps]$"); then # is it a type ?
            if $(echo $p | grep -q "n"); then # handle command negation
                neg=" -not"
                p=${p/n/}       # remove the 'n' from p, to get the real type
            else
                neg=""
            fi
            case $p in
                (h) [ -z $neg ] && hidden="" || hidden=" -not -regex .*/\..*";;
                (e) additional+="$neg -empty";;
                (r) additional+="$neg -readable";;
                (w) additional+="$neg -writable";;
                (x) additional+="$neg -executable";;
                (*) type+=$([ -z "$type" ] && echo "$neg -type $p" || echo " -or $neg -type $p");;
            esac
            else if [ -d $p ];i= then # is it a path ?
                root=$p
            else    # then its a name !
                name+="$([ -z "$name" ] && echo " -name $p" || echo " -or -name $p")";
            fi
        fi
    done
    if [ -t ]; then     # disable colors if piped
        find -O3 $(echo $root $name $additional $hidden $([ ! -z "$type" ] && echo "(") $type $([ ! -z "$type" ] && echo ")") | sed 's/ +/ /g') 2>/dev/null | grep --color=always "^\|[^/]*$" # re split all to spearate parameters and colorize filename
    else
        find -O3 $(echo $root $name $additional $hidden $type | sed 's/ +/ /g') 2>/dev/null
    fi
}

_ff() { _alternative "args:type:(( 'h:search in hidden files' 'e:search for empty files' 'r:search for files with the reading right' 'w:search for files with the writing right' 'x:search for files with the execution right' 'b:search for block files' 'c:search for character files' 'd:search for directories' 'f:search for regular files' 'l:search for symlinks' 'p:search for fifo files' 'nh:exclude hidden files' 'ne:exclude empty files' 'nr:exclude files with the reading right' 'nw:exclude files with the writing right' 'nx:exclude files with the execution right' 'nb:exclude block files' 'nc:exclude character files' 'nd:exclude directories' 'nf:exclude regular files' 'nl:exclude symlinks symlinks' 'np:exclude fifo files' 'ns:exclude socket files'))" "*:root:_files" }
compdef _ff ff



function tmp()                    # starts a new shubshell in /tmp
{
    env STARTUP_CMD="cd /tmp" zsh;
}

# create a backup file of . or the specified dir/file
function mkback()
{
    local toback;
    local backfile;

    if [ -e "$1" ] && [ "$1" != "." ] ; then
        toback="$1";
        backfile="$(basename ${1:A})";
    else
        toback=".";
        backfile="$(basename $(pwd))";
    fi
    backfile+="-$(date +%s).back.tar.gz";
    printf "Backing up %s in %s\n" "$toback" "$backfile";
    tar -cf - "$toback"  | pv -F " %b %r - %e  %t" -s "$(du -sb | cut -d"    " -f1 )" | gzip --best > "$backfile";
}





