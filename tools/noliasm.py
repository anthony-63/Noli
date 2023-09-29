OPS = [
    "MOVEHEAP",
    "MOVEREG",
    "PUSH",
    "PUSHREG",
    "POP",
    "PPUSH",
    "PPUSHREG",
    "PPOP",
    "MOVEHEAPTOREG",
    "MOVEREGTOHEAP",
    "MOVEREGTOREG",
    "MOVEHEAPTOHEAP",
    "MOVEREGTOREF",
    "RET",
    "ADD",
    "SUB",
    "MUL",
    "DIV",
    "FDIV",
    "INC",
    "DEC",
    "BITWISE_OR",
    "BITWISE_AND",
    "BITWISE_XOR",
    "BITWISE_NOT",
    "LOGICAL_OR",
    "LOGICAL_AND",
    "LOGICAL_NOT",
    "EQ",
    "NEQ",
    "GT",
    "LT",
    "GTEQ",
    "LTEQ",
    "CALL",
    "FUNC",
    "END",
    "NATIVE",
    "JMPEQ",
    "JMPNEQ",
    "JMP",
    "JMPSTACK",
    "PUSHIP",
    "NOOP",
]

import sys
import os
import struct

file_name = sys.argv[1]
output_file = sys.argv[2]

file = open(file_name, "r")
out_file = open(output_file, "wb+")
lines = file.readlines()

i = 0

def hextonum(x):
    return int(x, base=16)

FINAL_PROGRAM = []

for line in lines:
    code = line.strip().upper().split(" ")
    if code[0] == "" or code[0].startswith(";"): continue
    if not code[0] in OPS:
        print("Invalid opcode '", code[0], "' at line: ", i, sep="")
        exit(-1)
    opcode = OPS.index(code[0])
    args = list(map(hextonum, code[1:]))
    out_file.write(struct.pack("<Q", opcode))
    for arg in args:
        out_file.write(struct.pack("<Q", arg))
    print(opcode, args)

    i += 1