


# timestamps operations (`ts` to get current, `ts <timestamp>` to know how long ago, `ts <timestamp1> <timestamp2>` timestamp diff)
function ts()
{
    local -i delta;
    local -i ts1=$(echo $1 | grep -Eo "[0-9]+" | cut -d\  -f1);
    local -i ts2=$(echo $2 | grep -Eo "[0-9]+" | cut -d\  -f1);
    local sign;

    if [ $# = 0 ]; then
        date +%s;
    elif [ $# = 1 ]; then
        delta=$(( $(date +%s) - $ts1 ));
        if [ $delta -lt 0 ]; then
            delta=$(( -delta ));
            sign="in the future";
        else
            sign="ago";
        fi
        if [ $delta -gt 30758400 ]; then echo -n "$(( delta / 30758400 ))y "; delta=$(( delta % 30758400 )); fi
        if [ $delta -gt 86400 ]; then echo -n "$(( delta / 86400 ))d "; delta=$(( delta % 86400 )); fi
        if [ $delta -gt 3600 ]; then echo -n "$(( delta / 3600 ))h "; delta=$(( delta % 3600 )); fi
        if [ $delta -gt 60 ]; then echo -n "$(( delta / 60 ))m "; delta=$(( delta % 60 )); fi
        echo "${delta}s $sign";
    elif [ $# = 2 ]; then
        delta=$(( $ts2 - $ts1 ));
        if [ $delta -lt 0 ]; then
            delta=$(( -delta ));
        fi
        if [ $delta -gt 30758400 ]; then echo -n "$(( delta / 30758400 ))y "; delta=$(( delta % 30758400 )); fi
        if [ $delta -gt 86400 ]; then echo -n "$(( delta / 86400 ))d "; delta=$(( delta % 86400 )); fi
        if [ $delta -gt 3600 ]; then echo -n "$(( delta / 3600 ))h "; delta=$(( delta % 3600 )); fi
        if [ $delta -gt 60 ]; then echo -n "$(( delta / 60 ))m "; delta=$(( delta % 60 )); fi
        echo "${delta}s";
    fi
}


