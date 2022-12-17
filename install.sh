#!/bin/bash

set -e

path=/usr/local/lib/fp/

rm -rf $path
mkdir $path
cp -r lib/ $path
ln -s $path/bin/fp /usr/local/bin/fp