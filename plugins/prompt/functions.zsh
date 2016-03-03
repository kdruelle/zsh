
function update_pwd_datas()		# update the numbers of files and dirs in .
{
	local v
	v=$(ls -pA1)
	NB_FILES=$(echo "$v" | grep -v /$ | wc -l | tr -d ' ')
	NB_DIRS=$(echo "$v" | grep /$ | wc -l | tr -d ' ')
}

function update_pwd_save()		# update the $PWD_FILE
{
	[[ $PWD != "$HOME" ]] && echo $PWD > $PWD_FILE
}

function chpwd()				# chpwd hook
{
	check_git_repo
	set_git_branch
	update_pwd_datas
	setprompt					# update the prompt
}

function preexec()              # pre execution hook
{
    [ -z $UPDATE_TERM_TITLE ] || printf "\e]2;%s : %s\a" "${PWD/~/~}" "$1" # set 'pwd + cmd' set term title
}

function precmd()               # pre promt hook
{
    [ -z $UPDATE_TERM_TITLE ] || printf "\e]2;%s\a" "${PWD/~/~}" # set pwd as term title
    set_git_char
}

function setprompt()			# set a special predefined prompt or update the prompt according to the prompt vars
{
	case $1 in
		("superlite") _PS1=("" "" "" "" "" "" "" "" "" "" "X" "");;
		("lite") _PS1=("X" "X" "X" "" "" "" "" "" "" "" "X" "X");;
		("nogit") _PS1=("X" "X" "X" "X" "" "X" "X" "" "X" "X" "X" "X");;
		("classic") _PS1=("X" "X" "X" "X" "X" "" "X" "X" "X" "X" "X" "X");;
		("complete") _PS1=("X" "X" "X" "X" "X" "X" "X" "X" "X" "X" "X" "X");;
	esac
	PS1=''																								# simple quotes for post evaluation
	[ ! -z $_PS1[$_ssh] ] 			&& 	PS1+='$ID_C$GET_SSH'												# 'ssh:' if in ssh
	[ ! -z $_PS1[$_user] ] 			&&	PS1+='$ID_C%n'														# username
	if [ ! -z $_PS1[$_user] ] && [ ! -z $_PS1[$_machine] ]; then
		PS1+='${SEP_C}@'
	fi
	[ ! -z $_PS1[$_machine] ]		&& 	PS1+='$ID_C%m'												# @machine
	if [ ! -z $_PS1[$_wd] ] || ( [ ! -z $GIT_BRANCH ] && [ ! -z $_PS1[$_git_branch] ]) || [ ! -z $_PS1[$_dir_infos] ]; then 					# print separators if there is infos inside
		PS1+='${SEP_C}['
	fi
	[ ! -z $_PS1[$_wd] ] 			&& 	PS1+='$PWD_C%~' 													# current short path
	if ( [ ! -z $_PS1[$_git_branch] ] && [ ! -z $GIT_BRANCH ] ) && [ ! -z $_PS1[$_wd] ]; then
		PS1+="${SEP_C}:";
	fi
	[ ! -z $_PS1[$_git_branch] ] 	&& 	PS1+='${GB_C}$GIT_BRANCH' 											# get current branch
	if ([ ! -z $_PS1[$_wd] ] || ( [ ! -z $GIT_BRANCH ] && [ ! -z $_PS1[$_git_branch] ])) && [ ! -z $_PS1[$_dir_infos] ]; then
		PS1+="${SEP_C}|";
	fi
	[ ! -z $_PS1[$_dir_infos] ] 	&& 	PS1+='$NBF_C$NB_FILES${SEP_C}/$NBD_C$NB_DIRS' 				# nb of files and dirs in .
	if [ ! -z $_PS1[$_wd] ] || ( [ ! -z $GIT_BRANCH ] && [ ! -z $_PS1[$_git_branch] ]) || [ ! -z $_PS1[$_dir_infos] ]; then 					# print separators if there is infos inside
		PS1+="${SEP_C}]%f%k"
	fi
	if ([ ! -z $_PS1[$_wd] ] || [ ! -z $_PS1[$_dir_infos] ]) || [ ! -z $_PS1[$_return_status] ] || [ ! -z $_PS1[$_git_status] ] || [ ! -z $_PS1[$_jobs] ] || [ ! -z $_PS1[$_shlvl] ] || [ ! -z $_PS1[$_user_level] ]; then
		PS1+="%f%k "
	fi
	[ ! -z $_PS1[$_return_status] ] && 	PS1+='%(0?.%F{82}o.%F{196}x)' 										# return status of last command (green O or red X)
-	[ ! -z $_PS1[$_git_status] ] 	&& 	PS1+='$GET_GIT'														# git status (red + -> dirty, orange + -> changes added, green + -> changes commited, green = -> changed pushed)
	[ ! -z $_PS1[$_jobs] ] 			&& 	PS1+='%(1j.%(10j.%F{208}+.%F{226}%j).%F{210}%j)' 					# number of running/sleeping bg jobs
	[ ! -z $_PS1[$_shlvl] ] 		&& 	PS1+='%F{205}$GET_SHLVL'						 					# static shlvl
	[ ! -z $_PS1[$_user_level] ] 	&& 	PS1+='%(0!.%F{196}#.%F{26}\$)'					 					# static user level
	[ ! -z $_PS1[$_end_char] ] 		&& 	PS1+='${SEP_C}>'
	[ ! -z "$PS1" ] 				&& 	PS1+="%f%k "
}

_setprompt() { _arguments "1:prompt:(('complete:prompt with all the options' 'classic:classic prompt' 'lite:lite prompt' 'superlite:super lite prompt' 'nogit:default prompt without the git infos'))" }
compdef _setprompt setprompt

function pimpprompt()			# pimp the PS1 variables one by one
{
	local response;
	_PS1=("" "" "" "" "" "" "" "" "" "" "" "");
	echo "Do you want your prompt to:"
	for i in $(seq "$#_PS1"); do
		_PS1[$i]="X";
		setprompt;
		print "$_PS1_DOC[$i] like this ?\n$(print -P "$PS1")"
		read -q "response?(Y/n): ";
		if [ $response != "y" ]; then
		   	_PS1[$i]="";
			setprompt;
		fi
		echo;
		echo;
	done
}


function periodic()				# every $PERIOD secs - triggered by promt print
{
	check_git_repo
	set_git_branch
	update_pwd_datas
}

function title()				# set the title of the term, or toggle the title updating if no args
{
	if [ "$#" -ne "0" ]; then
		print -Pn "\e]2;$@\a"
		UPDATE_TERM_TITLE=""
	else
		if [ -z "$UPDATE_TERM_TITLE" ]; then
			UPDATE_TERM_TITLE="X"
		else
			print -Pn "\e]2;\a"
			UPDATE_TERM_TITLE=""
		fi
	fi
}

function loadconf()				# load a visual config
{
	case "$1" in
		(lite)					# faster, lighter
			UPDATE_TERM_TITLE="";
			UPDATE_CLOCK="";
			setprompt lite;
			;;
		(static)				# nicer, cooler, but without clock update nor title update
			UPDATE_TERM_TITLE="";
			UPDATE_CLOCK="";
			setprompt complete;
			;;
		(complete|*)			# nicer, cooler
			UPDATE_TERM_TITLE="X";
			UPDATE_CLOCK="X";
			setprompt complete;
			;;
	esac
}

_loadconf() { _arguments "1:visual configuration:(('complete:complete configuration' 'static:complete configuration without the dynamic title and clock updates' 'lite:smaller configuration'))" }
compdef _loadconf loadconf



# check if pwd is a git repo
function check_git_repo()		
{
	git rev-parse > /dev/null 2>&1 && REPO=1 || REPO=0
}

function set_git_branch()
{
	if [ $REPO -eq 1 ]; then		# if in git repo, get git infos
		GIT_BRANCH="$(git branch | grep \* | cut -d\  -f2-)";
	else
		GIT_BRANCH="";
	fi
}

function set_git_char()			# set the $GET_GIT_CHAR variable for the prompt
{
	if [ $REPO -eq 1 ];		# if in git repo, get git infos
	then
		local STATUS
		STATUS=$(git status 2> /dev/null)
		if [[ $STATUS =~ "Changes not staged" ]];
		then GET_GIT="%F{196}+"	# if git diff, wip
		else
			if [[ $STATUS =~ "Changes to be committed" ]];
			then GET_GIT="%F{214}+" # changes added
			else
				if [[ $STATUS =~ "is ahead" ]];
				then GET_GIT="%F{46}+" # changes commited
				else GET_GIT="%F{46}=" # changes pushed
				fi
			fi
		fi
	else
		GET_GIT="%F{240}o"		# not in git repo
	fi
}


