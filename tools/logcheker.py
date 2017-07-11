#!/usr/bin/env python3
import sys


def main():
    HR, IR = set(), set()
    for line in open(sys.argv[1]):
        l = line.strip().split(',')
        if l[0] == '825':       # register definition
            num, startbit = int(l[2]), int(l[3])
            if l[-2] == 'false':
                HR.add((num, startbit))
            else:
                IR.add((num, startbit))
        elif l[0] == '826':     # alarm
            num, startbit, ishr = int(l[2]), int(l[3]), l[-1] == 'false'
            tok = ishr and 'HR' or 'IR'
            s = ishr and HR or IR
            fmt = '{} ({}:{}) with alarm has no definition'
            if (num, startbit) not in s:
                print(fmt.format(tok, num, startbit))
        elif l[0] == '827':     # measurement
            num, startbit, ishr = int(l[2]), int(l[3]), l[-1] == 'false'
            tok = ishr and 'HR' or 'IR'
            s = ishr and HR or IR
            fmt = '{} ({}:{}) with measurement has no definition'
            if (num, startbit) not in s:
                print(fmt.format(tok, num, startbit))
        elif l[0] == '828':     # event
            num, startbit, ishr = int(l[2]), int(l[3]), l[-1] == 'false'
            tok = ishr and 'HR' or 'IR'
            s = ishr and HR or IR
            fmt = '{} ({}:{}) with event has no definition'
            if (num, startbit) not in s:
                print(fmt.format(tok, num, startbit))
        elif l[0] == '831':     # status
            num, startbit, ishr = int(l[2]), int(l[3]), l[-1] == 'false'
            tok = ishr and 'HR' or 'IR'
            s = ishr and HR or IR
            fmt = '{} ({}:{}) with status has no definition'
            if (num, startbit) not in s:
                print(fmt.format(tok, num, startbit))


if __name__ == '__main__':
    main()
