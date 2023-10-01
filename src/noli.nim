
include parseopt
import strformat
import streams

import util

import vm/extra
import vm/pu

import compiler/lexer
import compiler/ast

var toparse = ""
for c in commandLineParams():
    toparse.add(c & " ")

var compile = false
var in_file = ""
var out_file = ""

var parser = initOptParser(toparse)
while true:
    parser.next()
    case parser.kind
    of cmdEnd: break
    of cmdShortOption, cmdLongOption:
        if parser.val == "":
            case parser.key
            of "c": compile = true
            of "r": compile = false
            of "debug": debugging = true
            of "verbose": verbose = true
            of "in":
                echo "Input flag without file passed"
                quit -1
            of "out":
                echo "Output flag without file passed"
                quit -1
            else:
                echo "Invalid flag ", parser.key, " passed"
                quit -1
        else:
            case parser.key
            of "in": in_file = parser.val
            of "out": out_file = parser.val
            else:
                echo "Invalid flag ", parser.key, " passed with value ", parser.val
                quit -1
    of cmdArgument:
        echo "Passed ", parser.key, " which is not needed"
        quit -1

if compile and out_file == "":
    out_file = "a.nolic"

if in_file == "":
    echo "Usage:\n\tnoli -c --in:source.noli --out:output.nolic\n\tnoli -r --in:output.nolic"
    quit 0

if compile == false:
    if not fileExists(in_file):
        echo "Invalid input file provided: ", in_file
    var file = newFileStream(in_file)
    var bytecode: seq[uint64] = @[]
    while true:
        try:
            bytecode.add(file.readUint64())
        except IOError as _:
            break
    var program = preprocess_bytecode(bytecode)
    var pu = NoliPU()
    pu.execute_bytecode(program)
else:
    if not fileExists(in_file):
        echo "Invalid input file provided: ", in_file
    var file = open(in_file)
    defer: file.close()

    var src = file.readAll()
    var tokens = lexer_tokenize(src)
    if verbose: echo fmt"Generated tokens: {tokens}"
    var ast = generate_ast(tokens)
    echo repr(ast)
