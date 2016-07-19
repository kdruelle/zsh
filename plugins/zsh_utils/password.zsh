

function genpwd(){

    zparseopts -D -E -- l:=length -length:=length c:=charlist -charlist:=charlist

    if [ -z ${length[2]} ]; then
        length[2]="10"
    fi

    if [ -z ${charlist[2]} ]; then
        charlist[2]="12345!@#$%qwertQWERTasdfgASDFGzxcvbZXCVB"
    fi

    </dev/urandom tr -dc ${charlist[2]} | head -c ${length[2]}; echo ""
}

_genpwd_arg_list=(
    {'(--length)-l','(-l)--length'}'[Length]:Length:'
    {'(--charlist)-c','(-c)--charlist'}'[Char List]:Charlist'
)

_genpwd(){ 
    local curcontext=$curcontext state line
    declare -A opt_args
    _arguments $_genpwd_arg_list
    case $state in
        option-or-argument)
            if (( $+functions[_genpwd-$words[1]] )); then
                _call_function ret _genpwd-$words[1]
            elif zstyle -T :completion:$curcontext: use-fallback; then
                _files && ret=0
            else
                _message 'unknown sub-command'
            fi
            ;;
    esac
}


_bookmark_commands(){
    local -a main_commands
    main_commands=(
        add:'add new bookmark'
        delete:'delete existing bookmark'
    )
    integer ret=1
    _describe -t main-commands 'commands' main_commands && ret=0
    return ret
}



compdef _genpwd genpwd

