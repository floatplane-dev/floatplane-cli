#!/bin/bash

set -e
set -o pipefail

# Set delimiter such that we can use spaces in options.
# https://stackoverflow.com/questions/9084257/bash-array-with-spaces-in-elements
IFS=""

echo "SETUP"
echo "----------"
echo "What do you wish to set up?"
options=("server 🗿" "project 🌱")
select option in ${options[@]}
do
  if [[ "${options[*]}" =~ "${option}" ]]; then
    break
  else
    echo "Please enter a number from the list."
  fi
done
echo "----------"
if [ "$option" == "server 🗿" ];
then
  ./setup-server.sh
fi
if [ "$option" == "project 🌱" ];
then
  ./setup-project.sh
fi