



gitinfo () {
    local branch
    local tag
    local h
    local dir
    local rd
    local line
    local output
    [ $# -eq 1 ] && dir=$1  || dir=.
    #output="\e[1mRepo\t\x1b[000000;1mBranch\x1b[0m\t\x1b[1mTag\t( Hash )\t\x1b[33;1m  M\t\x1b[32;1m +\t\x1b[31;1m-\n\n"
    output="Repo\tBranch\tTag\t( Hash )\t  M\t  +\t  -\n\n"
    for d in $dir/*(/)
    do
        rd=$(readlink -f $d)
        if [ -d "$rd/.git" ]
        then
            #line="\e[0m$(basename $rd)"
            line="$(basename $rd)"
            branch="$(git --git-dir=$rd/.git --work-tree=$rd branch | grep \* | cut -d\  -f2-)"
            h=$(echo $branch | md5sum | cut -d\  -f1 | head -c 2)
            h=$(( 40 + (16#$h % 80) * 2 ))
            #line="${line}\t\e[38;5;${h}m${branch}\x1b[0m"
            line="${line}\t$(printf "%03d ${branch}" "$h")"
            tag="$(git --git-dir=$rd/.git --work-tree=$rd describe --tags --exact-match 2> /dev/null)"
            if [ -z $tag ]
            then
                tag="✗"
                #tag="/"
            fi
            #line="${line}\t\x1b[0m${tag}"
            line="${line}\t${tag}"
            line="${line}\t$(printf "(%.6s)" $(git --git-dir=$rd/.git rev-parse HEAD))"
            changed="$(git --git-dir=$rd/.git --work-tree=$rd diff --shortstat | grep -Eo '([0-9]+) files? changed.' | grep -Eo '[0-9]+')"
            added="$(git --git-dir=$rd/.git --work-tree=$rd diff --shortstat | grep -Eo '([0-9]+) insertion' | grep -Eo '[0-9]+')"
            deleted="$(git --git-dir=$rd/.git --work-tree=$rd diff --shortstat | grep -Eo '([0-9]+) deletion' | grep -Eo '[0-9]+')"
            #line="${line}\t$(printf "\x1b[00;33m%3d\t\x1b[00;32m%3d\t\x1b[31m%3d" "$changed" "$added" "deleted")"
            line="${line}\t$(printf "%3d\t%3d\t%3d" "$changed" "$added" "deleted")"
            output="${output}${line}\n"
        fi
    done
    echo ""
    echo $output | column -tes $'\t' | \
        sed '1 s/^\(.*\)/\x1b[1m\1\x1b[0m/g' | \
        sed '1 s/ M/\x1b[33;1m M\x1b[0m/g' | \
        sed '1 s/ +/\x1b[32;1m +\x1b[0m/g' | \
        sed '1 s/ -/\x1b[31;1m -\x1b[0m/g' | \
        sed '1 ! s/^\([a-z0-9_-]\+[ ]\+\)\([0-9]\{3\}\) \([a-z0-9\._\/-]\+[ ]\+\)\([a-z0-9\._✗-]\+[ ]\+\)\(([a-z0-9]\+)[ ]\+\)\([0-9]\{1,3\}[ ]\+\)\([0-9]\{1,3\}[ ]\+\)\([0-9]\{1,3\}\+\)/\1\x1b[38;5;\2m\3\x1b[0m    \4\5\x1b[33m\6\x1b[32m\7\x1b[31m\8\x1b[0m/gI' | \
        sed '1 ! s/✗/\x1b[31;1m✗\x1b[0m/gI'
}

gitswitchall () {

    branch_name=$1
    [ $# -eq 2 ] && dir=$2  || dir=.
    dir=${dir:A}

    for d in $dir/*(/)
    do
        rd=${d:A}
        if [ -d "$rd/.git" ]
        then
            git --git-dir=$rd/.git --work-tree=$rd fetch --all
            branch=$(git --git-dir=$rd/.git --work-tree=$rd branch --all | grep -P "^\*?[ ]+$branch_name" | sed 's/\*//' | xargs)
            if [ -z $branch ]
            then
                remote_branch=$(git --git-dir=$rd/.git --work-tree=$rd branch --all | egrep "$branch_name" | xargs | sed 's/remotes\///')
                if [ -n "$remote_branch" ]
                then
                    echo "remote branch .$remote_branch."
                    git --git-dir=$rd/.git --work-tree=$rd checkout -t $remote_branch
                    continue
                fi
                branch=$(git --git-dir=$rd/.git --work-tree=$rd branch --all | grep -P "^\*?[ ]+$branch_name" | xargs)
            fi

            if [ -z $branch ]
            then
                git --git-dir=$rd/.git --work-tree=$rd checkout master
            else
                git --git-dir=$rd/.git --work-tree=$rd checkout $branch
            fi
        fi
    done

}

