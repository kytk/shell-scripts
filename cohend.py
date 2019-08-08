#!/usr/bin/python3

from math import sqrt

n1 = int(input('Group1 sample size: '))
m1 = float(input('Group1 mean       : '))
s1 = float(input('Group1 sd         : '))
n2 = int(input('Group2 sample size: '))
m2 = float(input('Group2 mean       : '))
s2 = float(input('Group2 sd         : '))

# Cohen's d
d=( m1 - m2 ) / sqrt((( n1 - 1 ) * s1**2 + ( n2 - 1 ) * s2**2 ) / ( n1 + n2 - 2 ))

print("d=" + str(d))

# Hedges's g
g=d * (1 - 3/(4 * ( n1 + n2 ) - 9))

print("g=" + str(g))


d_f='{:.2f}'.format(d)
g_f='{:.2f}'.format(g)

print("Cohen's d=" + d_f)
print("Hedges's g=" + g_f)


