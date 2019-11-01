#  This file is part of any which is released under MIT License.
# See file LICENSE or go to
#  https://github.com/acorbe/any/blob/master/LICENSE
# for full license details.
# Any is authored and maintained by Alessandro Corbetta.
# Copyright (c) 2019 Alessandro Corbetta

if [ "$ANY_ALIAS_CD" = true ]; then
   alias ad='any cd'
fi

# any will try the default behavior for these commands before trying its expansion.
ANY_TEST_DEFAULT_BEHAVIOR_FIST="^(cd|ls|cat|less|more)$"

ANY_COMMANDS_FOR_FILE_ONLY_SEARCH="^(cat|less|more)$"
ANY_COMMANDS_FOR_DIR_ONLY_SEARCH="^(cd|cd)$"

ANY_ARCHITECTURE_FOR_FIND_COMMAND=`uname`

function any_find_command () {
    ## results are presented in reverse cronological order
    ## see https://superuser.com/a/608889/164234
    target_pattern=$1
    any_find_type_restrict=$2

    #find which comes with macos has different flags and less opts.
    if [[ "$ANY_ARCHITECTURE_FOR_FIND_COMMAND" == "Darwin" ]]; then
	find . -maxdepth 1 -iname "*$target_pattern*" -print0 -exec echo '{}' +
    else    
	find . -maxdepth 1 \
	     -iname "*$target_pattern*" \
	     $any_find_type_restrict \
             -printf '%Ts\t%p\0' | sort -nrz | cut -f2 -z #| xargs -0 ls
        #-print0 -exec echo '{}' +\
    fi
    
}

function any (){

    #only portable way to transfer the last element of the array
    for arg__ in $@; do :; done

    #this encodes the keyword/pattern that any will try to match
    target_pattern=$arg__

    command_=$1

    if [[ "$ANY_DEBUG" == true ]]; then
	echo "command:" $command_
    fi

    #in case no command is passed, it will display a usage guide.
    if [[ -z "$command_" ]]; then	
	echo "Any: keyword-based navigation, in bash."
	echo "   Alessandro Corbetta, 2019"
	echo "USAGE:"
	echo "   any <command> [flags...] <keyword>"
	echo "EXAMPLE:"
	echo "   any cd work"
	echo "   will expand to, e.g., cd workspace, if there is only one match, or it will prompt a selection panel."
	return 
    fi


    #Before running any, for some standart commands, we check that the
    #behavior without any. Only if it fails the any machinery starts.
    if [[ "$command_" =~ $ANY_TEST_DEFAULT_BEHAVIOR_FIST ]]; then
	if [[ "$ANY_DEBUG" == true ]]; then
	    echo "cd in ANY_TEST_DEFAULT_BEHAVIOR_FIST. testing:" ${@:1}
	fi

	#Default behavior, with no stderr on display.
	eval ${@:1} 2> /dev/null
	
	if [[ $? -eq 0 ]]; then
	    if [[ "$ANY_DEBUG" == true ]]; then
		echo "default behavior ok"
	    fi
	    return 0
	else
	    if [[ "$ANY_DEBUG" == true ]]; then
		echo "default_behavior failed. Rerouting to any."
	    fi
	fi
    fi

    any_find_type_restrict=""
    if [[ "$command_" =~ $ANY_COMMANDS_FOR_DIR_ONLY_SEARCH ]]; then
	any_find_type_restrict="-type d"
    elif [[ "$command_" =~ $ANY_COMMANDS_FOR_FILE_ONLY_SEARCH ]]
    then
	any_find_type_restrict="-type f"
    else
	if [[ "$ANY_DEBUG" == true ]]; then
	    echo "command: $command_ does not match dir-only or file-only searches."
	fi
    fi
    if [[ "$ANY_DEBUG" == true ]]; then
	echo "any_find_type_restrict: " $any_find_type_restrict
    fi
    

    # https://stackoverflow.com/q/23356779/1714661
    array=()
    while IFS=  read -r -d $'\0'; do
	array+=("${REPLY}")
	# done < <(find . -maxdepth 1 -iname "*$target_pattern*" $any_find_type_restrict -print0 -exec echo '{}' +) #
    done < <(any_find_command "${target_pattern//\//*\/*}" "$any_find_type_restrict")

    array_length=${#array[@]}


    case $array_length in
	0)
	    echo -e "no expansion."
	    ;;
	1)
	    target_file=${array[0]}
	    echo -e "expanded to: \e[34m${@:1:$#-1} ${target_file}\033[0m"
	    #Note that we escape spaces.
	    eval ${@:1:$#-1} "${target_file// /\\ }" 
	    ;;
	*)
	    echo -e "multiple matches:"
	    # echo -e "${array[*]}"
	    select option_ in "${array[@]}" #aa bb
	    do
		if [ -z "$option_" ]
		then
		    echo -e "\e[31mSelection error. No expansion.\033[0m"
		else
		    target_file=$option_
		    echo -e "expanded to: \e[34m${@:1:$#-1} $target_file\033[0m"
		    #Note that we escape spaces.
		    eval ${@:1:$#-1} "${target_file// /\\ }" 
		fi
		break;		
	    done
    esac
}
