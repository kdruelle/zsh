


function ago(){
    if [ -e $1 ]; then
        file_timestamp=$(stat -c "%Y" $1)
        curr_timestamp=$(date +"%s")
        time=$(($curr_timestamp - $file_timestamp))
        seconds=$(($time % 60))
        minutes=$((($time / 60) % 60))
        hours=$((($time / 60 / 60) % 60))
        days=$((($time / 60 / 60 / 24)))

        str=""
        if [ $days -gt 0 ]; then
            str="$str $days days"
        fi
        if [ $hours -gt 0 ]; then
            str="$str $hours hours"
        fi
        if [ $minutes -gt 0 ]; then
            str="$str $minutes minutes"
        fi
        if [ $seconds -gt 0 ]; then
            str="$str $seconds seconds"
        fi
        echo $str
    fi
}


