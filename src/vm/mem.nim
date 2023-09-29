import err
import ../util
import std/strformat

type NoliMEM* = object
    exec*: seq[uint64]
    
    heap*: seq[uint64]
    heap_size*: uint64
    
    registers*: seq[uint64]
    registers_size*: uint64

    stack*: seq[uint64]
    sp*: uint64

proc pushstack*(mem: var NoliMEM, value: uint64) =
    if verbose: echo fmt"Pushing {value} to the stack"
    mem.stack.add(value)
    mem.sp += 1
    if verbose: echo fmt"Stack: {mem.stack}"

proc popstack*(mem: var NoliMEM): (uint64, NoliError) =
    if mem.sp - 1 < 0:
        return (0, make_error(NoliErrorType.STACK_UNDERFLOW, "Attempted to pop from empty stack"))
    
    mem.sp -= 1

    var top = mem.stack.pop()
    if verbose: echo fmt"Popped {top} from stack"
    if verbose: echo fmt"SP: {mem.sp}"
    if verbose: echo fmt"Stack: {mem.stack}"

    return (top, no_error())

proc getreg*(mem: var NoliMEM, reg: uint64): (uint64, NoliError) =
    if reg > mem.registers_size:
        return (0, make_error(NoliErrorType.INVALID_REGISTER, fmt"Attempted to access register: {reg}"))
    if verbose: echo fmt"Accessing register: {reg}"
    return (mem.registers[reg], no_error())

proc setreg*(mem: var NoliMEM, value: uint64, reg: uint64) =
    if reg + 1 > mem.registers_size:
        mem.registers_size = reg
        if verbose: echo fmt"Resizing register page to: {mem.registers_size}"
        setLen(mem.registers, mem.registers_size + 1)
    
    mem.registers[reg] = value
    if verbose: echo fmt"Set r{reg} to value '{value}'"

proc setheap*(mem: var NoliMEM, value: uint64, address: uint64) =
    if address + 1 > mem.heap_size:
        mem.heap_size = address
        if verbose: echo fmt"Resizing heap to: {mem.heap_size}"
        setLen(mem.heap, mem.heap_size + 1)
    
    mem.heap[address] = value
    if verbose: echo fmt"Set address {address} to value '{value}'"
    if verbose: echo fmt"Heap: {mem.heap}"

proc getheap*(mem: var NoliMEM, address: uint64): (uint64, NoliError) =
    if address > mem.heap_size:
        return (0, make_error(NoliErrorType.INVALID_MEMORY_ADDRESS, fmt"Attempted to access heap address {address} which is out of bounds of heap size {mem.heap_size}"))

    if verbose: echo fmt"Accessing heap address: {address}"
    return (mem.heap[address], no_error())