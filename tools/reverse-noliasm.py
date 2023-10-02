OPS = [
    ("MOVEHEAP", 2),
    ("MOVEREG", 2),
    ("PUSH", 1),
    ("PUSHREG", 1),
    ("POP", 1),
    ("PPUSH", 1),
    ("PPUSHREG", 1),
    ("PPOP", 1),
    ("MOVEHEAPTOREG", 2),
    ("MOVEREGTOHEAP", 2),
    ("MOVEREGTOREG", 2),
    ("MOVEHEAPTOHEAP", 2),
    ("MOVEREGTOREF", 2),
    ("RET", 0),
    ("ADD", 2),
    ("SUB", 2),
    ("MUL", 2),
    ("DIV", 2),
    ("FDIV", 2),
    ("INC", 1),
    ("DEC", 1),
    ("BITWISE_OR", 2),
    ("BITWISE_AND", 2),
    ("BITWISE_XOR", 2),
    ("BITWISE_NOT", 1),
    ("LOGICAL_OR", 2),
    ("LOGICAL_AND", 2),
    ("LOGICAL_NOT", 1),
    ("EQ", 2),
    ("NEQ", 2),
    ("GT", 2),
    ("LT", 2),
    ("GTEQ", 2),
    ("LTEQ", 2),
    ("CALL", 1),
    ("FUNC", 0),
    ("END", 0),
    ("NATIVE", 0),
    ("JMPEQ", 1),
    ("JMPNEQ", 1),
    ("JMP", 1),
    ("JMPSTACK", 0),
    ("PUSHIP", 0),
    ("NOOP", 0),
]

import sys
import os
import struct
import numpy as np

bytecode = open(sys.argv[1], "rb")

program = ""

while not bytecode.tell() == os.fstat(bytecode.fileno()).st_size:
    opcode = int(struct.unpack("<Q", bytecode.read(8))[0])
    if opcode > len(OPS):
        print("Invalid opcode: ", opcode)
        exit(-1)
    program += OPS[opcode][0].lower() + " "
    arg_count = OPS[opcode][1]
    for i in range(arg_count):
        arg = int(struct.unpack("<Q", bytecode.read(8))[0])
        program += hex(arg) + " "
    program += "\n"

print(program)