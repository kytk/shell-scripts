#!/bin/bash
# A script to calculate Cohen's d and Hedges's g
# Formula is the following;
# Cohen's d
# d=(m1 - m2)/sqrt(((n1-1)*s1^2 + (n2-1)*s2^2)/(n1+n2-2))
# where
# n: sample size; m: mean; s: standard deviation
#
# Hedges's g
# g=d*(1-3/(4*(n1+n2)-9))
#
# 08 Aug 2019 K. Nemoto

set -x

read -p "Group1 sample size: " n1
read -p "Group1 mean       : " m1
read -p "Group1 sd         : " s1
read -p "Group2 sample size: " n2
read -p "Group2 mean       : " m2
read -p "Group2 sd         : " s2

# Cohen's d
d=$(echo "( $m1 - $m2 ) / sqrt((( $n1 - 1 ) * $s1^2 + ( $n2 - 1 ) * $s2^2 ) / ( $n1 + $n2 - 2 ))" | bc -l)

# Hedges's g
g=$(echo "$d * (1 - 3/(4 * ( $n1 + $n2 ) - 9))" | bc -l)

echo "Cohen's d = $(printf "%.2f\n" $d)"
echo "Hedges's g = $(printf "%.2f\n" $g)"

