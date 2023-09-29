import ops

type NoliXREFED* = object
    code*: uint64
    xref*: uint64

var debugging* = false
var verbose* = false

proc debug_print*(toprint: varargs[string]) =
    if debugging: echo toprint

proc verbose_print*(toprint: varargs[string]) =
    if verbose: echo toprint

proc preprocess_bytecode*(bytecode: seq[uint64]): seq[NoliXREFED] =
    var ops: seq[NoliXREFED]
    var next = false
    var curr: uint64 = 0
    
    for i in 0..<bytecode.len():
        ops.add(NoliXREFED())
        ops[i].code = bytecode[i]

    for i in 0..<bytecode.len():
        var op = bytecode[i]
        if op == ord(NOLI_OPCODES.FUNC):
            next = true
            curr = cast[uint64](i)
        if op == ord(NOLI_OPCODES.END) and next:
            next = false
            ops[curr].xref = cast[uint64](i)
            if debugging: echo "XREF: ", curr, " -> ", i
        elif op == ord(NOLI_OPCODES.END) and not next:
            echo "'END' opcode encountered without 'FUNC' at address: ", i
    return ops