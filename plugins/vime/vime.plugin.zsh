


if [ ! -f ~/.vimenc ];then
    echo "source ~/.vimrc"    > ~/.vimenc
    echo "set nobackup"      >> ~/.vimenc
    echo "set noswapfile"    >> ~/.vimenc
    echo "set nowritebackup" >> ~/.vimenc
    echo "set cm=blowfish"   >> ~/.vimenc
fi


function vime () {
    if [ -f $1 ]; then
        vim -u ~/.vimenc "$1"
    else
        vim -u ~/.vimenc -x "$1"
    fi
}



