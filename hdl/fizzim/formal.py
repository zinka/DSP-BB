# Author: Srinivasa Rao Zinka (srinivas . zinka [at] gmail . com)
# Copyright (c) 2020 Srinivasa Rao Zinka
# License: MIT License
"""
Module for incremental code generation using fizzim
"""

import os
import re
import sys

FSM = sys.argv[1]
FSM_bak = FSM+"bak"
if len(sys.argv) > 2:
    USERCODE = sys.argv[2]+'.tmp'
else:
    USERCODE = 'usercode.tmp'

regex = re.compile(r"// verilator lint_on CASEINCOMPLETE")
line_found = False

with open(FSM) as file1:
    with open(FSM_bak, "w+") as file2:
            for line in file1:
                file2.write(line)

with open(FSM) as file1:
    for line in file1:
        if re.match("\/\/ fizzim code generation ends", line):
            line_found = True
            break
    with open(USERCODE, "w+") as file2:
        if line_found:
            for line in file1:
                file2.write(line)

# delete the first and last lines
with open(USERCODE, 'r') as fin:
    data = fin.read().splitlines(True)
with open(USERCODE, 'w') as fout:
    fout.writelines(data[6:-1])