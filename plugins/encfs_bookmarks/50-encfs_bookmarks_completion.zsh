
(( $+functions[_encfs_bookmark-add] )) ||
_encfs_bookmark-add(){
    local curcontext=$curcontext state line ret=1
    declare -A opt_args
    _arguments -w -C -S -s \
        '1:: :_guard "([^-]?#|)" bookmark name'\
        '2:Bookmark Source:_path_files -/' \
        '3:Bookmark Target:_path_files -/'

    case $state in
        help)
            _values 'name' 
    esac

}

(( $+functions[_encfs_bookmark-delete] )) ||
_encfs_bookmark-delete(){
    local curcontext=$curcontext state line ret=1
    declare -A opt_args
    _arguments -w -C -S -s \
        '(-)*:: :->delete'
    case $state in
        delete)
            _values 'bookmarks' $(_list_encfs_umounted_bookmarks)
            ;;
    esac
}

(( $+functions[_encfs_bookmark-mount] )) ||
_encfs_bookmark-mount(){
    local curcontext=$curcontext state line ret=1
    declare -A opt_args
    _arguments -w -C -S -s \
        '(-)*:: :->mount'
    case $state in
        mount)
            _values 'bookmarks' $(_list_encfs_umounted_bookmarks)
            ;;
    esac
}

(( $+functions[_encfs_bookmark-umount] )) ||
_encfs_bookmark-umount(){
    local curcontext=$curcontext state line ret=1
    declare -A opt_args
    _arguments -w -C -S -s \
        '(-)*:: :->umount'
    case $state in
        umount)
            _values 'bookmarks' $(_list_encfs_mounted_bookmarks)
            ;;
    esac
}

_encfs_bookmark_commands(){
    local -a main_commands
    main_commands=(
        add:'add new bookmark'
        delete:'delete existing bookmark'
        mount:'mount existing bookmark'
        umount:'umount existing bookmark'
    )
    integer ret=1
    _describe -t main-commands 'commands' main_commands && ret=0
    return ret
}

_encfs_bookmark_arg_list=(
    '(-): :->command' \
    '(-)*:: :->option-or-argument'
)

_ebookmark(){ 
    local curcontext=$curcontext state line
    declare -A opt_args
    _arguments $_encfs_bookmark_arg_list
    case $state in
        command)
            _encfs_bookmark_commands #&& ret=0
            ;;
        option-or-argument)
            if (( $+functions[_encfs_bookmark-$words[1]] )); then
                _call_function ret _encfs_bookmark-$words[1]
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

compdef _ebookmark ebookmark


