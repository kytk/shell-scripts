#!/bin/bash

# A script to sort a certain number of files into the directories

# Usage
#sort_constant.sh <basename> <constant_number>

# 17 Oct 2021 K. Nemoto

#set -x

#Check if the files are specified
if [ $# -lt 2 ]
then
  echo "Please specify basename of directories, and number of files you want to sort!"
  echo "Usage: $0 <basename> <constant_number>"
  echo "Example: If you want to sort every 50 files into the directories beginning with FOO"
  echo "$0 FOO 50"
  exit 1
fi


# basename of directories
bname=$1

# number of files
nfile=$(echo "$(ls *.nii* | wc -w)")

# constant number 
constant=$2

# quotient of division of $nfile over $constant
quotient=$(echo "$nfile / $constant" | bc)

# remainder
remainder=$(echo "$nfile % $constant" | bc)

# number of directories to be generated
ndir=$(echo "$quotient + 1" | bc)

# mkdir
for i in $(seq -w $ndir)
do
  mkdir ${bname}_${i}
done

# make a list of "mv" repeated $nfiles times
touch mvlist
for f in $(seq $nfile)
do
  echo "mv" >> mvlist
done

# make a list of files
ls *.nii* > filelist

# make a list of directories files will be sorted into
for f in $(ls -F | grep / | sed 's@/@@')
do
  touch dirlist_${f}
  for i in $(seq $constant)
  do
    echo "$f" >> dirlist_${f} 
  done
done

cat dirlist_* | head -n $nfile > dlist

# generate a shell script
paste mvlist filelist dlist > sorting.sh

# remove temporary files
rm mvlist filelist dirlist* dlist

# execute the generated script
source sorting.sh

