#!/bin/bash

#count number of files in a directory under current directory
for dir in $(ls -F | grep / | sed 's:/$::')
do
    echo -e "$dir \t $(find $dir -type f | wc -l)"
done


