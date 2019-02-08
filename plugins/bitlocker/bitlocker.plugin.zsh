__dislocker_installed(){
    [ "$(type dislocker)" = "dislocker not found" ] || return 0 && return 1
}


fzf-install(){
    brew install osxfuse
    brew install dislocker
}

function _mount_usage() {
    echo "bitlocker <partition>"
    echo "Unlocks and mounts a bitlocker partition"
}




function _bitlocker_mount() {
    BITLOCKER_PARTITION="${1}"
    if [ -z "${BITLOCKER_PARTITION}" ]
    then
        echo "Please provide partiton"
        exit 1
    fi
    # Make sure the partition exists
    if [ ! -e "${BITLOCKER_PARTITION}" ]
    then
        echo "File '${BITLOCKER_PARTITION}' does not exist"
        exit 1
    fi
    # Make sure it is indeed a block device
    if [ ! -b "${BITLOCKER_PARTITION}" ]
    then
        echo "File '${BITLOCKER_PARTITION}' is not a block device"
        exit 1
    fi

    # Make sure runnign as rootw
    if [[ ${EUID} > 0 ]]
    then
        SUDO="sudo"
    fi
    BITLOCKER_NAME="bitlocker.$(basename ${BITLOCKER_PARTITION})"
    BITLOCKER_FILE="/tmp/${BITLOCKER_NAME}"
    BITLOCKER_MOUNT="/Volumes/${BITLOCKER_NAME}"

    read -s -p "Enter Password: " BITLOCKER_PASSWORD

    echo "Unlocking ${BITLOCKER_PARTITION} to ${BITLOCKER_FILE}"
    ${SUDO} dislocker -v -V "${BITLOCKER_PARTITION}" -u"${BITLOCKER_PASSWORD}" "${BITLOCKER_FILE}"
    if [[ ${?} != 0 ]]
    then
        echo "Dislocker operation failed"
        exit 1
    fi

    echo "Mounting unlocked image to ${BITLOCKER_MOUNT}"
    ${SUDO} hdiutil attach "${BITLOCKER_FILE}/dislocker-file" -imagekey diskimage-class=CRawDiskImage -mountpoint "${BITLOCKER_MOUNT}"
    if [[ ${?} != 0 ]]
    then
        echo "Mounting the unlocked image failed"
        exit 1
    fi

    echo "Bitlocker partition ${BITLOCKER_PARTITION} successfully mounted at ${BITLOCKER_MOUNT}"
}

function _bitlocker_umount() {
    BITLOCKER_PARTITION="${1}"

    if [ -z "${BITLOCKER_PARTITION}" ]
    then
        echo "Please provide partiton"
        exit 1
    fi
    # Make sure the partition exists
    if [ ! -e "${BITLOCKER_PARTITION}" ]
    then
        echo "File '${BITLOCKER_PARTITION}' does not exist"
        exit 1
    fi
    # Make sure it is indeed a block device
    if [ ! -b "${BITLOCKER_PARTITION}" ]
    then
        echo "File '${BITLOCKER_PARTITION}' is not a block device"
        exit 1
    fi
    # Make sure running as root
    if [[ ${EUID} > 0 ]]
    then
        SUDO="sudo"
    fi

    BITLOCKER_NAME="bitlocker.$(basename ${BITLOCKER_PARTITION})"
    BITLOCKER_FILE="/tmp/${BITLOCKER_NAME}"
    BITLOCKER_MOUNT="/Volumes/${BITLOCKER_NAME}"

    echo "Unmounting the unlocked image from ${BITLOCKER_MOUNT}"
    ${SUDO} hdiutil detach "${BITLOCKER_MOUNT}"

    echo "Unmounting the bitlocker file from ${BITLOCKER_FILE}"
    ${SUDO} hdiutil detach "${BITLOCKER_FILE}"
}

function bitlocker() {
    case $1 in
        mount)
            shift
            _bitlocker_mount $@
            ;;
        umount)
            shift
            _bitlocker_umount $@
            ;;
    esac
}

#(( $+functions[_bitlocker-mount] )) ||
_bitlocker-mount(){
    local curcontext=$curcontext state line ret=1
    declare -A opt_args
    _arguments -w -C -S -s \
        '(-)*:: :->mount'
    case $state in
        mount)
            _values 'drive' $(diskutil list | egrep "[0-9]:" | awk '{print $7}' | egrep -v "^$" | sed 's/^/\/dev\//')
            ;;
    esac
}

#(( $+functions[_bitlocker-umount] )) ||
_bitlocker-umount(){
    local curcontext=$curcontext state line ret=1
    declare -A opt_args
    _arguments -w -C -S -s \
        '(-)*:: :->umount'
    case $state in
        umount)
            _values 'bookmarks' $(ls /Volumes/ | grep bitlocker. | sed 's/bitlocker\./\/dev\//g')
            ;;
    esac
}

_bitlocker_commands(){
    local -a main_commands
    main_commands=(
        mount:'mount an encrypted disk'
        umount:'umount an encrypted disk'
    )
    integer ret=1
    _describe -t main-commands 'commands' main_commands && ret=0
    return ret
}

_bitlocker_arg_list=(
    '(-): :->command' \
    '(-)*:: :->option-or-argument'
)

_bitlocker(){ 
    local curcontext=$curcontext state line
    declare -A opt_args
    _arguments $_bitlocker_arg_list
    case $state in
        command)
            _bitlocker_commands #&& ret=0
            ;;
        option-or-argument)
            if (( $+functions[_bitlocker-$words[1]] )); then
                _call_function ret _bitlocker-$words[1]
            elif zstyle -T :completion:$curcontext: use-fallback; then
                _files && ret=0
            else
                _message 'unknown sub-command'
            fi
            ;;
        delete)
            _values 'bookmarks' $(_list_encfs_bookmarks)
            ;;
    esac
}

compdef _bitlocker bitlocker


