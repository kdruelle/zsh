
# Set ENCFS_BOOKMARKS_FILE if it doesn't exist to the default.
# Allows for a user-configured ENCFS_BOOKMARKS_FILE.
if [[ -z $ENCFS_BOOKMARKS_FILE ]] ; then
  export ENCFS_BOOKMARKS_FILE="$HOME/.zsh_encfs_bookmarks"
fi

# Check if $ENCFS_BOOKMARKS_FILE is a symlink.
if [[ -L $ENCFS_BOOKMARKS_FILE ]]; then
  ENCFS_BOOKMARKS_FILE=${ENCFS_BOOKMARKS_FILE:A}
fi

# Create bookmarks_file it if it doesn't exist
if [[ ! -f $ENCFS_BOOKMARKS_FILE ]]; then
  touch $ENCFS_BOOKMARKS_FILE
fi


function _list_encfs_bookmarks_details(){
    old_IFS=$IFS      # save the field separator
    IFS=$'\n'         # new field separator, the end of line
    tab="\033[1mname\033[0m #| \033[1msrc\033[0m #| \033[1mdst\033[0m #| \033[1mmounted\033[0m\n"
    for line in $(cat $ENCFS_BOOKMARKS_FILE | sort -d)
    do
        local markname=$(echo "$line" | cut -d "|" -f 1 | xargs)
        local marksrc=$(echo "$line" | cut -d "|" -f 2 | xargs)
        local markdst=$(echo "$line" | cut -d "|" -f 3 | xargs)
        local mounted="\033[31mno\033[00m"
        df | grep encfs | grep -q $markdst
        if [ $? -eq 0 ]; then
            mounted="\033[32myes\033[00m"
        fi
        tab="$tab$(echo "\033[0m${markname}\033[0m #| \033[0m${marksrc}\033[0m #| \033[0m${markdst}\033[0m #| ${mounted}")\n"
    done
    echo $tab | column -t -s '#'
    IFS=$old_IFS
}

function _list_encfs_mounted_bookmarks(){
    old_IFS=$IFS      # save the field separator
    IFS=$'\n'         # new field separator, the end of line
    for line in $(cat $ENCFS_BOOKMARKS_FILE | sort -d)
    do
        local markname=$(echo "$line" | cut -d "|" -f 1 | xargs)
        local markdst=$(echo "$line" | cut -d "|" -f 3 | xargs)
        df | grep encfs | grep -q $markdst
        if [ $? -eq 0 ]; then
            echo "${markname}"
        fi
    done
    IFS=$old_IFS
}

function _list_encfs_umounted_bookmarks(){
    old_IFS=$IFS      # save the field separator
    IFS=$'\n'         # new field separator, the end of line
    for line in $(cat $ENCFS_BOOKMARKS_FILE | sort -d)
    do
        local markname=$(echo "$line" | cut -d "|" -f 1 | xargs)
        local markdst=$(echo "$line" | cut -d "|" -f 3 | xargs)
        df | grep encfs | grep -q $markdst
        if [ ! $? -eq 0 ]; then
            echo "${markname}"
        fi
    done
    IFS=$old_IFS
}

function _list_encfs_bookmarks(){
    old_IFS=$IFS      # save the field separator
    IFS=$'\n'         # new field separator, the end of line
    for line in $(cat $ENCFS_BOOKMARKS_FILE | sort -d)
    do
        local markname=$(echo "$line" | cut -d "|" -f 1 | xargs)
        echo "${markname}"
    done
    IFS=$old_IFS
}

function _get_encfs_bookmark_source(){
    echo $(cat $ENCFS_BOOKMARKS_FILE | grep -e "[[:space:]]*$1[[:space:]]*" | cut -d "|" -f 2 | xargs)
}

function _get_encfs_bookmark_destination(){
    echo $(cat $ENCFS_BOOKMARKS_FILE | grep -e "[[:space:]]*$1[[:space:]]*" | cut -d "|" -f 3 | xargs)
}

function _add_encfs_bookmark(){
    echo "$1 | ${2:A} | ${3:A}" >> $ENCFS_BOOKMARKS_FILE
}

function _delete_encfs_bookmark(){
    for ebookmark in $@;
    do
        echo "delete $ebookmark from bookmarks"
        local markdst=$(echo "$ebookmark" | cut -d "|" -f 3 | xargs)
        if [ $? -eq 0 ]; then
            echo "$ebookmark is currently mounted, umount first"
            return 1
        fi
        sed -i -r "/^[[:space:]]*${ebookmark}[[:space:]]*\\|/d" $ENCFS_BOOKMARKS_FILE
    done
}

function _mount_encfs_bookmark(){
    for ebookmark in $@;
    do
        echo "mount $ebookmark from bookmarks"
        src=$(_get_encfs_bookmark_source $ebookmark)
        dst=$(_get_encfs_bookmark_destination $ebookmark)
        encfs $src $dst
    done
}

function _umount_encfs_bookmark(){
    for ebookmark in $@;
    do
        echo "umount $ebookmark from bookmarks"
        dst=$(_get_encfs_bookmark_destination $ebookmark)
        fusermount -u $dst
    done
}

function ebookmark() {
    if (( $# == 0 )); then
        _list_encfs_bookmarks_details
        return 0
    fi

    case $1 in
        add)
            shift
            _add_encfs_bookmark $@
            ;;
        delete)
            shift
            _delete_encfs_bookmark $@
            ;;
        mount)
            shift
            _mount_encfs_bookmark $@
            ;;
        umount)
            shift
            _umount_encfs_bookmark $@
            ;;
    esac
}





