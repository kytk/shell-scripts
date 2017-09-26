#!/bin/bash
#Remove unnecessary packages
sudo apt -y autoremove --purge

#Remove unnecessary kernels
sudo purge-old-kernels --keep 1

#Remove apt cache
sudo apt -y clean


