#!zsh
#
# Installation
# ------------
#
# To achieve git-flow completion nirvana:
#
#  0. Update your zsh's git-completion module to the newest verion.
#     From here. http://zsh.git.sourceforge.net/git/gitweb.cgi?p=zsh/zsh;a=blob_plain;f=Completion/Unix/Command/_git;hb=HEAD
#
#  1. Install this file. Either:
#
#     a. Place it in your .zshrc:
#
#     b. Or, copy it somewhere (e.g. ~/.git-flow-completion.zsh) and put the following line in
#        your .zshrc:
#
#            source ~/.git-flow-completion.zsh
#
#     c. Or, use this file as a oh-my-zsh plugin.
#

_git-imerge ()
{
    local curcontext="$curcontext" state line
    typeset -A opt_args

    _arguments -C \
        ':command:->command' \
        '*::options:->options'

    case $state in
        (command)

            local -a subcommands
            subcommands=(
                'start:start a new incremental merge (equivalent to "init" followed by "continue")'
                'merge:start a simple merge via incremental merge'
                'rebase:start a simple rebase via incremental merge'
                'drop:drop one or more commits via incremental merge'
                'revert:revert one or more commits via incremental merge'
                'continue:record the merge at branch imerge/NAME and start the next step of the merge (equivalent to "record" followed by "autofill" and then sets up the working copy with the next conflict that has to be resolved manually)'
                'finish:simplify then remove a completed incremental merge (equivalent to "simplify" followed by "remove")'
                'diagram:display a diagram of the current state of a merge'
                'list:list the names of incremental merges that are currently in progress. The active merge is shown with an asterisk next to it'
                'init:initialize a new incremental merge'
                'record:record the merge at branch imerge/NAME'
                'autofill:autofill non-conflicting merges'
                'simplify:simplify a completed incremental merge by discarding unneeded intermediate merges and cleaning up the ancestry of the commits that are retained'
                'remove:irrevocably remove an incremental merge'
                'reparent:change the parents of the HEAD commit'
            )
            _describe -t commands 'git flow' subcommands
        ;;

        (options)
            case $line[1] in

                (start)
                    __git-imerge-branch
                    ;;
                (merge)
                    __git-imerge-branch
                    ;;
                (rebase)
                    __git-imerge-branch
                    ;;
                (drop)
                    __git-imerge-commit-range
                    ;;
                (revert)
                    __git-imerge-commit-range
                    ;;
                (continue)
                    __git-imerge-continue
                    ;;
                (diagram)
                    __git-imerge-diagram
                    ;;
                (init)
                    __git-imerge-branch
                    ;;
                (record)
                    __git-imerge-continue
                    ;;
                (autofill)
                    __git-imerge-continue
                    ;;
                (simplify)
                    __git-imerge-finish
                    ;;
                (remove)
                    __git-imerge-continue
                    ;;
            esac
        ;;
    esac
}

__git-imerge-branche(){
    local curcontext="$curcontext" state line
    typeset -A opt_args

    _arguments -C \
        --name'[name to use for this incremental merge]' \
        --goal'[the goal of the incremental merge]' \
        --branch'[the name of the branch to which the result will be stored]' \
        --manual'[ask the user to complete all merges manually, even when they appear conflict-free. This option disables the usual bisection algorithm and causes the full incremental merge diagram to be completed]' \
        --first-parent'[handle only the first parent commits (this option is currently required if the history is nonlinear)]' \
        ':branch:__git_branch_names'
}

__git-imerge-commit-range(){
    local curcontext="$curcontext" state line
    typeset -A opt_args

    _arguments -C \
        --name'[name to use for this incremental merge]' \
        --goal'[the goal of the incremental merge]' \
        --branch'[the name of the branch to which the result will be stored]' \
        --manual'[ask the user to complete all merges manually, even when they appear conflict-free. This option disables the usual bisection algorithm and causes the full incremental merge diagram to be completed]' \
        --first-parent'[handle only the first parent commits (this option is currently required if the history is nonlinear)]' \
        ': :__git_commit_ranges'
}

__git-imerge-continue(){
    local curcontext="$curcontext" state line
    typeset -A opt_args

    _arguments -C \
        --name'[name to use for this incremental merge]' \
        {'(--edit)-e','(-e)--edit'}'[commit staged changes with the --edit option]' \
        --no-edit'[commit staged changes with the --no-edit option]'
}

__git-imerge-finish(){
    local curcontext="$curcontext" state line
    typeset -A opt_args

    _arguments -C \
        --name'[name to use for this incremental merge]' \
        --goal'[the goal of the incremental merge]' \
        --branch'[the name of the branch to which the result will be stored]' \
        --force'[allow the target branch to be updated in a non-fast-forward manner]'
}

__git-imerge-diagram(){
    local curcontext="$curcontext" state line
    typeset -A opt_args

    _arguments -C \
        --name'[name to use for this incremental merge]' \
        --commits'[show the merges that have been made so far]' \
        --frontier'[show the current merge frontier]' \
        --html'[generate HTML diagram showing the current merge frontier]' \
        --color'[draw diagram with colors]' \
        --no-color'[draw diagram without colors]'
}

__git_branch_names () {
    local expl
    declare -a branch_names

    branch_names=(${${(f)"$(_call_program branchrefs git for-each-ref --format='"%(refname)"' refs/heads 2>/dev/null)"}#refs/heads/})
    __git_command_successful || return

    _wanted branch-names expl branch-name compadd $* - $branch_names
}

__git_command_successful () {
    if (( ${#pipestatus:#0} > 0 )); then
        _message 'not a git repository'
        return 1
    fi
    return 0
}


