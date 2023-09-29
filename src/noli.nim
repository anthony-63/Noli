include std/parseopt

var toparse = ""

for c in commandLineParams():
    toparse.add(c & " ")

var parser = initOptParser(toparse)

var compile = false
var in_file = ""
var out_file = ""

while true:
    parser.next()
    case parser.kind
    of cmdEnd: break
    of cmdShortOption, cmdLongOption:
        if parser.val == "":
            case parser.key
            of "c": compile = true
            of "r": compile = false
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