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

_git-flow ()
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
                'init:Initialize a new git repo with support for the branching model.'
                'feature:Manage your feature branches.'
                'release:Manage your release branches.'
                'hotfix:Manage your hotfix branches.'
                'support:Manage your support branches.'
                'version:Shows version information.'
                'config:Manage your git-flow configuration.'
                'log:Show log deviating from base branch.'
            )
            _describe -t commands 'git flow' subcommands
        ;;

        (options)
            case $line[1] in

                (init)
                    _arguments \
                        -f'[Force setting of gitflow branches, even if already configured]' \
                        --showcommands'[Show git commands while executing them]' \
                        {'--delete','-d'}'[Use default branch naming conventions]' \
                        --local'[utiliser le fichier de configuration du dépôt]' \
                        --global'[utiliser les fichier de configuration global]' \
                        --system'[utiliser le fichier de configuration du système]' \
                        --file'[utiliser le fichier de configuration spécifié]:config file:_path_files'
                    ;;

                    (version)
                    ;;

                    (hotfix)
                        __git-flow-hotfix
                    ;;

                    (release)
                        __git-flow-release
                    ;;

                    (feature)
                        __git-flow-feature
                    ;;
            esac
        ;;
    esac
}

__git-flow-release ()
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
                'start:Start a new release branch.'
                'finish:Finish a release branch.'
                'list:List all your release branches. (Alias to `git flow release`)'
                'publish:Publish release branch to remote.'
                'track:Checkout remote release branch.'
            )
            _describe -t commands 'git flow release' subcommands
            _arguments \
                -v'[Verbose (more) output]'
        ;;

        (options)
            case $line[1] in

                (start)
                    _arguments \
                        --showcommands'[Show git commands while executing them]' \
                        {'--fetch','-F'}'[Fetch from origin before performing finish]'\
                        {'--verbose','-v'}'[Verbose (more) output]'
                        ':version:__git_flow_version_list'
                ;;

                (finish)
                    _arguments \
                        --showcommands'[Show git commands while executing them]' \
                        {'--fetch','-F'}'[Fetch from origin before performing finish]'\
                        {'--sign','-s'}'[Sign the release tag cryptographically]'\
                        {'--signingkey','-u'}'[Use the given GPG-key for the digital signature (implies -s)]'\
                        {'--message','-m'}'[Use the given tag message]'\
                        {'--mesagefile','-f'}'[...]:message file:_path_files' \
                        {'--push','-p'}'[Push to $ORIGIN after performing finish]' \
                        {'--keep','-k'}'[Keep branch after performing finish]' \
                        --keepremote'[Keep the remote branch]' \
                        --keeplocal'[Keep the local branch]' \
                        {'--force_delete','-d'}'[Force delete release branch after finish]' \
                        {'--notag','-n'}"[Don't tag this release]" \
                        {'--nobackmerge','-b'}"[Don't back-merge master, or tag if applicable, in develop]" \
                        {'--squash','-S'}'[Squash release during merge]' \
                        ':version:__git_flow_version_list'
                ;;

                (publish)
                    _arguments \
                        --showcommands'[Show git commands while executing them]' \
                        ':version:__git_flow_version_list'
                ;;

                (track)
                    _arguments \
                        --showcommands'[Show git commands while executing them]' \
                        ':version:__git_flow_version_list'
                ;;

                *)
                    _arguments \
                        -v'[Verbose (more) output]'
                ;;
            esac
        ;;
    esac
}

__git-flow-hotfix ()
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
                'start:Start a new hotfix branch.'
                'finish:Finish a hotfix branch.'
                'track:Checkout remote feature branch.'
                'list:List all your hotfix branches. (Alias to `git flow hotfix`)'
            )
            _describe -t commands 'git flow hotfix' subcommands
            _arguments \
                -v'[Verbose (more) output]'
        ;;

        (options)
            case $line[1] in

                (start)
                    _arguments \
                        --showcommands'[Show git commands while executing them]' \
                        {'--fetch','-F'}'[Fetch from origin before performing finish]'\
                        ':hotfix:__git_flow_version_list'\
                        ':branch-name:__git_branch_names'
                ;;

                (finish)
                    _arguments \
                        --showcommands'[Show git commands while executing them]' \
                        {'--fetch','-F'}'[Fetch from origin before performing finish]'\
                        {'--sign','-s'}'[Sign the release tag cryptographically]'\
                        {'--signingkey','-u'}'[Use the given GPG-key for the digital signature (implies -s)]'\
                        {'--message','-m'}'[Use the given tag message]'\
                        {'--mesagefile','-f'}'[...]:message file:_path_files' \
                        {'--push','-p'}'[Push to $ORIGIN after performing finish]' \
                        {'--keep','-k'}'[Keep branch after performing finish]' \
                        --keepremote'[Keep the remote branch]' \
                        --keeplocal'[Keep the local branch]' \
                        {'--force_delete','-d'}'[Force delete release branch after finish]' \
                        {'--notag','-n'}"[Don't tag this release]" \
                        {'--nobackmerge','-b'}"[Don't back-merge master, or tag if applicable, in develop]" \
                        ':hotfix:__git_flow_hotfix_list'
                ;;
                
                (track)
                    _arguments \
                        --showcommands'[Show git commands while executing them]' \
                        ':hotfix:__git_flow_remote_hotfix_list'\
                ;;

                *)
                    _arguments \
                        -v'[Verbose (more) output]'
                ;;
            esac
        ;;
    esac
}

__git-flow-feature ()
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
                'start:Start a new feature branch.'
                'finish:Finish a feature branch.'
                'list:List all your feature branches. (Alias to `git flow feature`)'
                'publish:Publish feature branch to remote.'
                'track:Checkout remote feature branch.'
                'diff:Show all changes.'
                'rebase:Rebase from integration branch.'
                'checkout:Checkout local feature branch.'
                'pull:Pull changes from remote.'
                'delete:Delete a feature branch.'
            )
            _describe -t commands 'git flow feature' subcommands
            _arguments \
                -v'[Verbose (more) output]'
        ;;

        (options)
            case $line[1] in

                (start)
                    _arguments \
                        --showcommands'[Show git commands while executing them]' \
                        {'--fetch','-F'}'[Fetch from origin before performing finish]'\
                        ':feature:__git_flow_feature_list'\
                        ':branch-name:__git_branch_names'
                ;;

                (finish)
                    _arguments \
                        --showcommands'[Show git commands while executing them]' \
                        {'--fetch','-F'}'[Fetch from origin before performing finish]'\
                        {'--rebase','-r'}'[Rebase before merging]' \
                        {'--preserve-merges','-p'}'[Preserve merges while rebasing]' \
                        {'--keep','-k'}'[Keep branch after performing finish]' \
                        --keepremote'[Keep the remote branch]' \
                        --keeplocal'[Keep the local branch]' \
                        {'--force_delete','-D'}'[Force delete feature branch after finish]' \
                        {'--squash','-S'}'[Squash feature during merge]' \
                        --no-ff'[Never fast-forward during the merge]' \
                        ':feature:__git_flow_feature_list'
                ;;

                (publish)
                    _arguments \
                        --showcommands'[Show git commands while executing them]' \
                        ':feature:__git_flow_feature_list'\
                ;;

                (track)
                    _arguments \
                        --showcommands'[Show git commands while executing them]' \
                        ':feature:__git_flow_remote_feature_list'\
                ;;

                (diff)
                    _arguments \
                        --showcommands'[Show git commands while executing them]' \
                        ':branch:__git_branch_names'\
                ;;

                (rebase)
                    _arguments \
                        --showcommands'[Show git commands while executing them]' \
                        {'--interactive','-i'}'[Do an interactive rebase]' \
                        {'--preserve-merges','-p'}'[Preserve merges]' \
                        ':branch:__git_branch_names'
                ;;

                (checkout)
                    _arguments \
                        --showcommands'[Show git commands while executing them]' \
                        ':branch:__git_flow_feature_list'\
                ;;

                (pull)
                    _arguments \
                        --showcommands'[Show git commands while executing them]' \
                        ':remote:__git_remotes'\
                        ':branch:__git_branch_names'
                ;;

                *)
                    _arguments \
                        -v'[Verbose (more) output]'
                ;;
            esac
        ;;
    esac
}

__git_flow_version_list ()
{
    local expl
    declare -a versions

    versions=(${${(f)"$(_call_program versions git flow release list 2> /dev/null | tr -d ' |*')"}})
    __git_command_successful || return

    _wanted versions expl 'version' compadd $versions
}

__git_flow_feature_list ()
{
    local expl
    declare -a features

    features=(${${(f)"$(_call_program features git flow feature list 2> /dev/null | tr -d ' |*')"}})
    __git_command_successful || return

    _wanted features expl 'feature' compadd $features
}

__git_flow_remote_feature_list ()
{
    local expl
    declare -a features

    features=(${${(f)"$(_call_program rfeatures git branch -r | grep -E "feature/[-A-Za-z0-9]+" | sed -r 's#\s*origin/feature/([-A-Za-z0-9]+).*#\1#g' 2> /dev/null)"}})
    __git_command_successful || return

    _wanted features expl 'feature' compadd $features
}

__git_remotes () {
    local expl gitdir remotes

    gitdir=$(_call_program gitdir git rev-parse --git-dir 2>/dev/null)
    __git_command_successful || return

    remotes=(${${(f)"$(_call_program remotes git config --get-regexp '"^remote\..*\.url$"')"}//#(#b)remote.(*).url */$match[1]})
    __git_command_successful || return

    # TODO: Should combine the two instead of either or.
    if (( $#remotes > 0 )); then
        _wanted remotes expl remote compadd $* - $remotes
    else
        _wanted remotes expl remote _files $* - -W "($gitdir/remotes)" -g "$gitdir/remotes/*"
    fi
}

__git_flow_hotfix_list ()
{
    local expl
    declare -a hotfixes

    hotfixes=(${${(f)"$(_call_program hotfixes git flow hotfix list 2> /dev/null | tr -d ' |*')"}})
    __git_command_successful || return

    _wanted hotfixes expl 'hotfix' compadd $hotfixes
}

__git_flow_remote_hotfix_list ()
{
    local expl
    declare -a hotfixes

    hotfixes=(${${(f)"$(_call_program rhotfixes git branch -r | grep -E "hotfix/[-A-Za-z0-9\.]+" | sed -r 's#\s*origin/hotfix/([-A-Za-z0-9\.]+).*#\1#g' 2> /dev/null)"}})
    __git_command_successful || return

    _wanted hotfixes expl 'hotfix' compadd $hotfixes
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


zstyle ':completion:*:*:git:*' user-commands \
    flow:'provide high-level repository operations' \

