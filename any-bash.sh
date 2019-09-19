
if [ "$ANY_ALIAS_CD" = true ]; then
   alias acd='any cd'
fi

# any will try the default behavior for these commands before trying its expansion.
ANY_TEST_DEFAULT_BEHAVIOR_FIST="^(cd|ls|cat|less|more)$"


function any (){
    for arg__ in $@; do :; done #only portable way
    target_pattern=$arg__

    command_=$1

    if [[ "$ANY_DEBUG" == true ]]; then
	echo "command:" $command_
    fi
    
    if [[ "$command_" =~ $ANY_TEST_DEFAULT_BEHAVIOR_FIST ]]; then
	if [[ "$ANY_DEBUG" == true ]]; then
	    echo "matching! - trying:" ${@:1}
	fi

	#test_def_beh=$(eval ${@:1}) #2> /dev/null
	#echo "def behavior" $test_def_beh

	eval ${@:1} 2> /dev/null
	
	if [[ $? -eq 0 ]]; then
	    if [[ "$ANY_DEBUG" == true ]]; then
		echo "default behavior ok"
	    fi
	    return 0
	else
	    if [[ "$ANY_DEBUG" == true ]]; then
		echo "rerouting behavior"
	    fi
	fi
    fi
    

    # https://stackoverflow.com/q/23356779/1714661
    array=()
    while IFS=  read -r -d $'\0'; do
	array+=("$REPLY")
    done < <(find . -maxdepth 1 -name "*$target_pattern*" -print0)

    array_length=${#array[@]}


    case $array_length in
	0)
	    echo -e "no expansion."
	    ;;
	1)
	    target_file=${array[0]}
	    echo -e "expanded to: \e[34m${@:1:$#-1} $target_file\033[0m"    
	    eval ${@:1:$#-1} $target_file 
	    ;;
	*)
	    echo -e "multiple matches:"
	    echo -e "${array[*]}"
	    select option_ in "${array[@]}" #aa bb
	    do
		target_file=$option_
		echo -e "expanded to: \e[34m${@:1:$#-1} $target_file\033[0m"
		eval ${@:1:$#-1} $target_file
		break;		
	    done
    esac
}
