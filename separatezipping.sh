#!/bin/bash

ls -F | grep / | sed 's@/@@' | while read line; do zip -r ${line}.zip $line; done 
