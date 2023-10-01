import strformat

import ../util
import extra
import exec
import mem

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
        pu.xref_table.add(b.xref)
    
    if verbose: echo "Exec memory: ", pu.scopes[0].exec
        
    while int(pu.ip) < pu.scopes[0].exec.len():
        if verbose: echo fmt"Executing {pu.scopes[0].exec[pu.ip]} at address {pu.ip}"
        NOLI_VM_CALL_TABLE[pu.scopes[0].exec[pu.ip]](pu)
        if pu.interrupt == NoliInterrupts.NONE:
            pu.ip += 1
        elif pu.interrupt == NoliInterrupts.DONT_INC: discard
    pu.halt()