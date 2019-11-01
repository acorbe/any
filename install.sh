#!/usr/bin/env bash


ANY_FOLDER=`pwd`

echo "Appending source any-bash.sh to your .bashrc"
echo "Any root folder: " $ANY_FOLDER


cat <<EOF >> ~/.bashrc 
## adding any
export ANY_ALIAS_CD=true
source $ANY_FOLDER/any-bash.sh 
EOF
