#!/usr/bin/python3

import sys

if len(sys.argv) == 1:
    sys.stderr.write("error: First argument is minimal number of CPUs.\n")
    sys.exit(1)

min_cpus = int(sys.argv[1])

counter = 0
with open("/proc/cpuinfo", "r") as f:
    for line in f.readlines():
        words = line.split()
        if len(words)>0 and words[0] == "processor":
            counter += 1 

if counter >= min_cpus:
    sys.exit(0)

sys.stderr.write("error: Host should have at least {} CPUs.\n".format(min_cpus))
sys.exit(1)
