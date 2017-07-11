
__fasd_installed(){
    [ "$(type fasd)" = "fasd not found" ] || return 0 && return 1
}


fasd-install(){
    if [[ "$UID" == "0" ]] then;
        curl https://raw.githubusercontent.com/clvv/fasd/1.0.1/fasd > /usr/local/bin/fasd
        chmod +x /usr/local/bin/fasd
    else
        sudo curl https://raw.githubusercontent.com/clvv/fasd/1.0.1/fasd > /usr/local/bin/fasd
        sudo chmod +x /usr/local/bin/fasd
    fi
}

__fasd_init(){
    eval "$(fasd --init auto)"
    alias c='fasd_cd -d -i'
}


__fasd_installed && __fasd_init

