
__fasd_installed(){
    if [ ! $(echo "$PATH" | grep -q "$HOME/.bin") ]; then
        export PATH="$PATH:$HOME/.bin"
    fi
    [ "$(type fasd)" = "fasd not found" ] || return 0 && return 1
}


fasd-install(){
    if [ ! -d "$HOME/.bin" ]; then
        mkdir -p "$HOME/.bin"
    fi
    curl https://raw.githubusercontent.com/clvv/fasd/1.0.1/fasd > "$HOME/.bin/fasd"
    chmod +x "$HOME/.bin/fasd"
}

__fasd_init(){
    eval "$(fasd --init auto)"
    alias c='fasd_cd -d -i'
}


__fasd_installed && __fasd_init

