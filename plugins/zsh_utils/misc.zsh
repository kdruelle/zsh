

# list all aliases
function show-aliases()
{
    local -i pad;

    for k in "${(@k)aliases}"; do
        [ $#k -gt $pad ] && pad=$#k;
    done
    (( pad+=2 ));
    for k in "${(@k)aliases}"; do
        printf "$C_BLUE%-${pad}s$C_GREY->$DEF_C  \"$C_GREEN%s$DEF_C\"\n" "$k" "$aliases[$k]";
    done
}

# simple calculator
function calc()
{
    echo $(($@));
}

# decimal to hexa
function d2h()
{
    printf "0x%x\n" "$1"
}

# hexa to decimal
function h2d()
{
    echo $((16#$1));
}


function kbd()
{
    case $1 in
        (caps-ctrl)
            setxkbmap -option ctrl:nocaps;; # caps lock is a ctrl key
        (caps-esc)
            setxkbmap -option caps:escape;; # caps lock is an alt key
        (caps-super)
            setxkbmap -option caps:super;; # caps lock is a super key
        (us)
            setxkbmap us;;
        (fr)
            setxkbmap fr;;
    esac
}


# prints weather info
function window()
{
    curl -s "http://www.wunderground.com/q/zmw:00000.37.07156" | grep "og:title" | cut -d\" -f4 | sed 's/&deg;/ degrees/';
}


# work simulation
function work()
{
    clear;
    text="$(cat $(find ~ -type f -name "*.cpp" 2>/dev/null | head -n25) | sed ':a;$!N;$!ba;s/\/\*[^​*]*\*\([^/*​][^*]*\*\|\*\)*\///g')"
    arr=($(echo $text))
    i=0
    cat /dev/zero | head -c $COLUMNS | tr '\0' '='
    while true
    do
        read -sk;
        echo -n ${text[$i]};
        i=$(( i + 1 ))
    done
    echo
}

