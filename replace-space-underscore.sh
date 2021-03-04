#!/bin/bash
# A script to substitute spaces within file/directory name with underscores.

while true; do
    echo "This script replaces spaces within file/directory name with underscores."
    echo "All files/directories under $PWD will be affected."
    echo "Do you want to proceed (yes/no)?"

    read answer

    case $answer in
        [Yy]*)
	    for i in $(seq $(find . -type d | awk -F/ '{ print NF }' | sort | tail -1))
            do
                find . -maxdepth $i -name '* *' | \
                while read line
                do newline=$(echo $line | sed 's/ /_/g')
                    echo $newline
                    mv "$line" $newline
                done
            done
            echo "Replace finished!"
            break
            ;;
        [Nn]*)
            echo "Abort the script."
            break
            ;;
        *)
            echo "Type yes or no."
            ;;
    esac
done

exit

