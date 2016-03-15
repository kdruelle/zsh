



gitinfo () {
    local branch
    local h
    local dir
    local rd
    [ $# -eq 1 ] && dir=$1  || dir=.
    printf "%s                                    : %s %s (%s)    \x1b[33m%s\x1b[0m, \x1b[32m%s\x1b[0m, \x1b[31m%s\x1b[0m\n\n" "repo"    "branch" "        " " hash " "  M" "  +" "  -"
    for d in $dir/*(/)
    do
        rd=$(readlink -f $d)
        if [ -d "$rd/.git" ]
        then
            branch="$(git --git-dir=$rd/.git --work-tree=$rd branch | grep \* | cut -d\  -f2-)"
            h=$(echo $branch | md5sum | cut -d\  -f1 | head -c 2)
            h=$(( 40 + (16#$h % 80) * 2 ))
            changed="$(git --git-dir=$rd/.git --work-tree=$rd diff --shortstat | grep -Eo '([0-9]+) files? changed.' | grep -Eo            '[0-9]+')"
            added="$(git --git-dir=$rd/.git --work-tree=$rd diff --shortstat | grep -Eo '([0-9]+) insertion' | grep -Eo '[0-9]+')"
            deleted="$(git --git-dir=$rd/.git --work-tree=$rd diff --shortstat | grep -Eo '([0-9]+) deletion' | grep -Eo '[0-9]+')"
            printf "%-40s: \x1b[38;5;%dm%-30s\x1b[0m%s (%.6s) \x1b[33m%3d\x1b[0m, \x1b[32m%3d\x1b[0m, \x1b[31m%3d\x1b[0m\n" "$(basename $rd)" "$h" "$branch" " " "$(git --git-dir=$rd/.git rev-parse HEAD)" "$changed" "$added" "$deleted"
        fi
    done
}



