findInFile() {
    : <<_comment_
        Function to be placed in bash profile
        Allows user to specify what contents of a file they are looking for
        in what file types and in what NOT file types
        Iterate over the number of scripts arugments
_comment_
  while [[ "$#" -gt 0 ]]
  do
    case $1 in
      -ft|--fileTypes)
        local fileTypes=$2
        ;;
      -et|--excludeTypes)
        local excludeTypes=$2
        ;;
      *) # Catch the case where user does not specify 
         # these arguments
        local searchTerm=$1
        ;;
    esac
    shift
  done

  echo "fileTypes: $fileTypes"
  echo "excludeTypes: $excludeTypes"
  echo "searchTerm: $searchTerm"

  # TODO: Should probably clean up with case statement
  # TODO: I am using this \? in the include and exclude as a hack
  # to catch the case where only one file type is provided. 
  if [ -n "$fileTypes" ] && [ -n "$excludeTypes" ]
  then
    #searchString="grep -r --include=\*{$fileTypes} --exclude=\*{$excludeTypes} "$searchTerm" ."
    searchString="grep -r --include=\*{$fileTypes,.\?} --exclude=\*{$excludeTypes,.\?} "$searchTerm" ."

  elif [ -n "$fileTypes" ]
    then
      #searchString="grep -r --include=\*{$fileTypes} "$searchTerm" ."
      searchString="grep -r --include=\*{$fileTypes,.\?} "$searchTerm" ."
  elif [ -n "$excludeTypes" ]
    then
      #searchString="grep -r --exclude=\*{$excludeTypes} "$searchTerm" ."
      searchString="grep -r --exclude=\*{$excludeTypes,.\?} "$searchTerm" ."
  else
      searchString="grep -r "$searchTerm" ."
  fi

  #searchString="grep -r --include=\*{$fileTypes} "$searchTerm" ."
  echo "searchString: $searchString"
  eval $searchString

  # TODO: Allow the user to type a number to then programmatically jump to that
  # file in the text editor of their choice

}

cd /Users/amcelhinney/repos/ds_case_study_version2/tests
findInFile "random" # should return 2 results, works
findInFile -ft .R,.py "random" # should return 2 results, works
findInFile -ft .C,.R "random" # should return 0 results,  works
findInFile -ft .py "random" # should return 2 results, works
findInFile -ft .C "random" # should return 0 results, works
findInFile -et .py "random" # should return 0 results, works
findInFile -et .R "random" # should return 2 results, works
findInFile -et .R -ft .py "random" # should return 2 results, works
findInFile -et .R,.C -ft .py,.java "random" # should return 2 results, works



# This is the code that was submitted on Code Review
# https://codereview.stackexchange.com/questions/210845/bash-function-to-find-contents-of-a-file-with-a-certain-extension?noredirect=1#comment407612_210845
findInFile() {
    :<<_comment_
        Function to be placed in bash profile
        Allows user to specify what contents of a file they are looking for
        in what file types and in what NOT file types
        Iterate over the number of scripts arugments
_comment_
    declare -a select
    while [[ "$#" -gt 0 ]]
    do
        if [[ $1 =~ ^(-ft|--fileTypes|-et|--excludeTypes)$ ]]
        then
            local type="$2"
            [[ "$type" == *,* ]] && type="{$type}"
            if [[ $1 == *-f* ]]
            then 
                select+=( "--include=*$type" )
            else
                select+=( "--exclude=*$type" )
            fi
            shift 2
        else
            break
        fi
    done
    set -x
    grep -r ${select[@]} "$@" .
    { set +x; } 2>/dev/null
}