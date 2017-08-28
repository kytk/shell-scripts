#!/bin/bash
# A script to substitute spaces within file/directory name with underscores.

while true; do
    echo "This script replaces spaces within file/directory name with underscores."
    echo "Do you want to proceed (yes/no)?"

    read answer

    case $answer in
        [Yy]*)
            for i in $(seq $(find . -type d | wc -l))
            do
                find . -maxdepth $i -name '* *' | \
                while read line
                do newline=$(echo $line | sed 's/ /_/g')
                    echo $newline
                    mv "$line" $newline
                done
            done
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

echo "Replace finished!"
exit

