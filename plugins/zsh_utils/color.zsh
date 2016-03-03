
# remove all? color escape chars
function uc()
{
    if [ $# -eq 0 ]; then
        sed -r "s/\[([0-9]{1,2}(;[0-9]{1,2})?(;[0-9]{1,3})?)?[mGK]//g"
    else
        $@ | sed -r "s/\[([0-9]{1,2}(;[0-9]{1,2})?(;[0-9]{1,3})?)?[mGK]//g"
    fi
}

# display the 256 colors by shades - useful to get pimpy colors
function showcolors()
{
    tput setaf 0;
    for c in {0..15}; do tput setab $c ; printf " % 2d " "$c"; done # 16 colors
    tput sgr0; echo;
    tput setaf 0;
    for s in {16..51}; do   # all the color tints
        for ((i = $s; i < 232; i+=36)); do
            tput setab $i ; printf "% 4d " "$i";
        done
        tput sgr0; echo; tput setaf 0;
    done
    for c in {232..255}; do tput setaf $((255 - c + 232)); tput setab $c ; printf "% 3d" "$c"; done # grey tints
    tput sgr0; echo;
}


function colorcode()        # get the code to set the corresponding fg color
{
    for c in "$@"; do
        tput setaf $c;
        echo -e "\"$(tput setaf $c | cat -v)\""
    done
}

# cmd | colorize <exp1> (f/b)?<color1> <exp2> (f/b)?<color2> ... to colorize expr with color
function colorize()
{
    # ie: cat log.log | colorize WARNING byellow ERROR bred DEBUG green INFO yellow "[0-9]+" 125 "\[[^\]]+\]" 207
    local -i i
    local last
    local params
    local col
    local background;
    i=0
    params=()
    col=""
    if [ $# -eq 0 ]; then
        echo "Usage: colorize <exp1> <color1> <exp2> <color2> ..." 1>&2
        return ;
    fi
    for c in "$@"; do
        if [ "$((i % 2))" -eq 1 ]; then
            case "$c[1]" in
                (b*)
                    background="1";
                    c="${c[2,$#c]}";;
                (f*)
                    background="";
                    c="${c[2,$#c]}";;
            esac
            case $c in
                ("black")   col=0;;
                ("red")     col=1;;
                ("green")   col=2;;
                ("yellow")  col=3;;
                ("blue")    col=4;;
                ("purple")  col=5;;
                ("cyan")    col=6;;
                ("white")   col=7;;
                (*)         col=$c;;
            esac
            if [ $#background -ne 0 ]; then
                col="$(tput setab $col)";
            else
                col="$(tput setaf $col)";
            fi
            params+="-e";
            params+="s/(${last//\//\\/})/$col\1$DEF_C/g"; # replace all / by \/ to don't fuck the regex
        else
            last=$c
        fi
        i+=1;
    done
    if [ "$c" = "$last" ]; then
        echo "Usage: cmd | colorize <exp1> <color1> <exp2> <color2> ..."
        return
    fi
    # sed -r $params
    sed --unbuffered -r $params
}



