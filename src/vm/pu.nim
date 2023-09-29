import mem
import ../util

type NoliPU* = object
    scopes: seq[NoliMEM]
    
    p_stack: seq[uint64]
    psp: uint64

    xref_table: seq[uint64]

    calling_func: bool
    call_stack: seq[uint64]
    call_ptr: uint64

    ip: uint64

    printing: bool

proc halt*(pu: var NoliPU) = 
    if debugging: echo "Halting!"
    if debugging: echo "Final scopes: ", pu.scopes
    if debugging: echo "Preserved stack: ", pu.p_stack

proc execute_bytecode*(pu: var NoliPU, bytecode: seq[NoliXREFED]) =
    if debugging: echo "Initializing memory scope..."
    pu.scopes.add(NoliMEM())
    
    if debugging: echo "Loading bytecode into exec..."
    for b in bytecode:
        pu.scopes[0].exec.add(b.code)
    
    if debugging: echo "Loading xref_table..."
    for b in bytecode:
        pu.xref_table.add(b.code)
    
    if verbose: echo "Exec memory: ", pu.scopes[0].exec
    
    pu.halt()