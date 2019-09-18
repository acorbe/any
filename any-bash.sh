

function any (){
    for arg__ in $@; do :; done #only portable way
    target_pattern=$arg__
    #echo "target pattern" $target_pattern, "pwd" $(pwd)    
    #target_file=`(find . -maxdepth 1 -name *$target_pattern* | tail -n 1)`

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
