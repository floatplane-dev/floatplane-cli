#!/bin/bash

domain=admin.interflux.com

ask_yes_no() {
    while true; do
    select answer in yes no; do
        case $answer in
        yes) break 2;;
        no)  echo "Please do so now";;
        *)   echo "Invalid choice";;
        esac
    done
    done
}

echo "Have you done all of the below? 🥦"
ask_yes_no

echo "----------"
echo "Done!"
echo "----------"
echo "FINAL STEP:"
echo "👉🏼 Open $domain in your browser. Check whether all is working!"
sleep 1
echo "3"
sleep 1
echo "2"
sleep 1
echo "1"
sleep 1
open https://$domain
echo "----------"