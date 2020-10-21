#  This file is part of any which is released under MIT License.
# See file LICENSE or go to
#  https://github.com/acorbe/any/blob/master/LICENSE
# for full license details.
# Any is authored and maintained by Alessandro Corbetta.
# Copyright (c) 2019-2020 Alessandro Corbetta

if [ "$ANY_ALIAS_CD" = true ]; then
   alias ad='any cd'
fi

# any will try the default behavior for these commands before trying its expansion.
ANY_TEST_DEFAULT_BEHAVIOR_FIST="^(cd|ls|cat|less|more)$"

ANY_COMMANDS_FOR_FILE_ONLY_SEARCH="^(cat|less|more)$"
ANY_COMMANDS_FOR_DIR_ONLY_SEARCH="^(cd|cd)$"

ANY_ARCHITECTURE_FOR_FIND_COMMAND=`uname`

#from https://stackoverflow.com/a/17841619/1714661
#join strings by separator
function join_by { local IFS="$1"; shift; echo "$*"; }

function any_find_command_basic () {
    ## results are presented in reverse cronological order
    ## see https://superuser.com/a/608889/164234
    target_pattern=$1
    any_find_type_restrict=$2

    #find which comes with macos has different flags and less opts.
    if [[ "$ANY_ARCHITECTURE_FOR_FIND_COMMAND" == "Darwin" ]]; then
	find . -maxdepth 1 $any_find_type_restrict \
	     -iname "*$target_pattern*"\
	     -print0 -exec echo '{}' +
    else    
	find . -maxdepth 1 \
	     -iname "*$target_pattern*" \
	     $any_find_type_restrict \
             -printf '%Ts\t%p\0' | sort -nrz | cut -f2 -z #| xargs -0 ls
        
    fi
    
}

function any_find_command () {
    ## Any supports a syntax with trailing slashes that are themselves expanded.
    ## Not used on Darwin
    ## In case of expansion, -type d is suppressed
    
    target_pattern=$1
    any_find_type_restrict=$2

    if [[ "$ANY_DEBUG" == true ]]; then
	{
	    echo "[ANY] - Notice - this is the experimental any find call."
	    echo "[ANY] - The received pattern is: ${target_pattern}"
	} >&2
    fi


    #check if it's a path with / in between.
    if [[ "$ANY_DEBUG" == true ]]; then
	>&2 echo "[ANY] - Defining wheter the path contains at least one '/'"
    fi
    
    if [[ "${target_pattern}" =~ "/" ]]; then
	if [[ "$ANY_DEBUG" == true ]]; then
	    >&2 echo "[ANY] - Detected / in path. Any searches in composed paths."
	fi
	IFS='/' path_split=($target_pattern)
	path_len_subelements=${#path_split[@]}
	
	joined_patternized_path=""
	for element in "${path_split[@]:0:$path_len_subelements-1}"
	do
	    if [[ "$ANY_DEBUG" == true ]]; then
		>&2 echo "[ANY] - tokenized path part: $element adding ->" '*'"${element}"'*'
	    fi
	    #local_patternized_path_el="*${element}*"
	    #patternized_path_el+=('*'"${element}"'*')
	    joined_patternized_path="${joined_patternized_path}/"'*'"${element}"'*'
	done
	joined_patternized_path="${joined_patternized_path:1}"
	#joined_patternized_path=$(join_by "/" ${patternized_path_el[@]} )

	if [[ "$ANY_DEBUG" == true ]]; then
	    >&2 echo "[ANY] - updated -maxdepth" $path_len_subelements
	    >&2 echo "[ANY] - updated -ipath" "${joined_patternized_path}"
	    >&2 echo "[ANY] - updated -iname" "*${path_split[$path_len_subelements-1]}*"
	fi	
	
	#find which comes with macos has different flags and less opts.
	if [[ "$ANY_ARCHITECTURE_FOR_FIND_COMMAND" == "Darwin" ]]; then
	    find . -maxdepth 1 $any_find_type_restrict\
		 -iname "*$target_pattern*" \
		 -print0 -exec echo '{}' +
	else
	    if [[ "$ANY_DEBUG" == true ]]; then
		>&2 echo "[ANY] - FIND CALL: find "-maxdepth $path_len_subelements \
		 \( -ipath "${joined_patternized_path}" \) \
		 -iname "*${path_split[$path_len_subelements-1]}*" \
		 -printf '%Ts\t%p\0'
	    fi
	    find . -maxdepth $path_len_subelements \
		 \( -ipath "${joined_patternized_path}" \) \
		 -iname "*${path_split[$path_len_subelements-1]}*" \
		 -printf '%Ts\t%p\0' 2> /dev/null | sort -nrz | cut -f2 -z #| xargs -0 ls
	         #"${any_find_type_restrict}"
	         #2> /dev/null
		 #$any_find_type_restrict \
	fi

    
    else
	
	if [[ "$ANY_DEBUG" == true ]]; then
	    >&2 echo "[ANY] - NO / detected in path. Simple any search."
	fi

	#find which comes with macos has different flags and less opts.
	if [[ "$ANY_ARCHITECTURE_FOR_FIND_COMMAND" == "Darwin" ]]; then
	    find . -maxdepth 1 $any_find_type_restrict\
		 -iname "*$target_pattern*" \
		 -print0 -exec echo '{}' +
	else    
	    find . -maxdepth 1 \
		 $any_find_type_restrict \
		 -iname "*$target_pattern*" \
		 -printf '%Ts\t%p\0' | sort -nrz | cut -f2 -z #| xargs -0 ls            
	fi	

    fi    
}

function color_output_if_possible () {
    case $TERM in
	xterm-*)
	    echo -e "\e[31m$1\033[0m"
	    ;;
	*)
	    echo -e "$1"
	    ;;
    esac    
}

function color_output_if_possible_ignore_beg () {
    case $TERM in
	xterm-*)
	    echo -e "$1 \e[31m$2\033[0m"
	    ;;
	*)
	    echo -e "$1 $2"
	    ;;
    esac    
}

function any (){

    #last argument encodes the keyword/pattern that any will try to match.
    target_pattern=${@: -1} 

    #command that any aims at expanding.
    command_=$1

    if [[ "$ANY_DEBUG" == true ]]; then
	echo "[ANY] - command:" $command_
    fi

    #in case no command is passed, it will display a usage guide.
    if [[ -z "$command_" ]]; then	
	echo "Any: keyword-based navigation, in bash."	
	echo "USAGE:"
	echo "   any <command> [flags...] <keyword>"
	echo "EXAMPLE:"
	echo "   any cd work"
	echo "   will expand to, e.g., cd workspace, if there is only one match, or it will prompt a selection panel."
	echo "Alessandro Corbetta, 2019"
	return 
    fi


    #Before running any, for some standart commands, we check that the
    #behavior without any. Only if it fails the any machinery starts.
    if [[ "$command_" =~ $ANY_TEST_DEFAULT_BEHAVIOR_FIST ]]; then
	if [[ "$ANY_DEBUG" == true ]]; then
	    echo "[ANY] - Testing default behavior: " ${@:1}
	fi

	#Default behavior, with no stderr on display.
	eval ${@:1} 2> /dev/null
	
	if [[ $? -eq 0 ]]; then
	    if [[ "$ANY_DEBUG" == true ]]; then
		echo "[ANY] - default behavior ok"
	    fi
	    return 0
	else
	    if [[ "$ANY_DEBUG" == true ]]; then
		echo "[ANY] - default_behavior failed. Rerouting to any."
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
	    echo "[ANY] - command: $command_ does not match dir-only or file-only searches."
	fi
    fi
    if [[ "$ANY_DEBUG" == true ]]; then
	echo "[ANY] - any_find_type_restrict for command ${command_}:" $any_find_type_restrict
	echo "[ANY] - passing to find function:" "${target_pattern}"
    fi

    if [[ "$ANY_FIND_COMMAND_EXP" == true ]]; then
	ANY_FIND_COMMAND_FOO=any_find_command_experimental
	if [[ "$ANY_DEBUG" == true ]]; then
	    echo "[ANY] - any in experimental foo mode"
	fi

	if [[ "$ANY_DEBUG" == true ]]; then
	    echo "[ANY] -    Duplicated find call for testing {{"
	    duplicated_output=$($ANY_FIND_COMMAND_FOO "${target_pattern}" "$any_find_type_restrict")
	    echo "[ANY] -    Output from duplicated call:" $duplicated_output
	    echo "[ANY] -    }} End duplicated call"
	fi
	
    else
	ANY_FIND_COMMAND_FOO=any_find_command
    fi

    
       
    # https://stackoverflow.com/q/23356779/1714661
    array=()
    while IFS=  read -r -d $'\0'; do
	array+=("${REPLY}")
	# done < <(find . -maxdepth 1 -iname "*$target_pattern*" $any_find_type_restrict -print0 -exec echo '{}' +) #
    done < <($ANY_FIND_COMMAND_FOO "${target_pattern}" "$any_find_type_restrict")

    array_length=${#array[@]}


    case $array_length in
	0)
	    echo -e "no expansion."
	    ;;
	1)
	    target_file=${array[0]}
	    #echo -e "expanded to: \e[34m${@:1:$#-1} ${target_file}\033[0m"
	    color_output_if_possible_ignore_beg "expanded to:" "$target_file"
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
		    #echo -e "\e[31mSelection error. No expansion.\033[0m"
		    color_output_if_possible "Selection error. No expansion."
		    
		else
		    target_file=$option_
		    #echo -e "expanded to: \e[34m${@:1:$#-1} $target_file\033[0m"
		    color_output_if_possible_ignore_beg "expanded to:" "$target_file"
		    #Note that we escape spaces.
		    eval ${@:1:$#-1} "${target_file// /\\ }" 
		fi
		break;		
	    done
    esac
}
