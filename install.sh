#!/bin/bash

set -e

lib_path=/usr/local/lib/fp
bin_path=/usr/local/bin/fp
user=$(id -un)

echo '---'
echo 'installing Floatplane CLI ...'
echo '---'
echo "user: $user"
echo '---'

(
  set -x
  sudo rm -rf $lib_path
  sudo rm -rf $bin_path
  sudo mkdir $lib_path
  sudo chown $user:staff $lib_path
  cp -r ./lib/ $lib_path
  sudo ln -s $lib_path/bin/fp $bin_path
)

echo '---'
echo 'done!'
echo '---'