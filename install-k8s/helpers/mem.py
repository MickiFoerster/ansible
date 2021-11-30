#!/usr/bin/python3

import sys

if len(sys.argv) == 1:
    sys.stderr.write("error: First argument is minimal memory size in kB.\n")
    sys.exit(1)

memsize_kb = int(sys.argv[1])

with open("/proc/meminfo", "r") as f:
    for line in f.readlines():
        words = line.split()
        keyname = words[0]
        memtotal = int(words[1])
        unit = words[2]
        break;

if memtotal > memsize_kb and unit == 'kB':
    sys.exit(0)

sys.stderr.write("error: Host should have at least {}kb of memory\n".format(memsize_kb))
sys.exit(1)
