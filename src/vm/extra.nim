import mem
import ../util
import std/strformat
import err

type NoliInterrupts* = enum
    NONE,
    DONT_INC,

type NoliPU* = object
    scopes*: seq[NoliMEM]
    scope_idx*: uint64

    p_stack*: seq[uint64]
    psp*: uint64

    xref_table*: seq[uint64]

    calling_func*: bool
    call_stack*: seq[uint64]
    call_ptr*: uint64

    ip*: uint64
    printing*: bool

    interrupt*: NoliInterrupts

proc pushpstack*(pu: var NoliPU, value: uint64) =
    if verbose: echo fmt"Pushing {value} to the stack"
    pu.p_stack.add(value)
    pu.psp += 1
    if verbose: echo fmt"Stack: {pu.p_stack}"

proc poppstack*(pu: var NoliPU): (uint64, NoliError) =
    if pu.psp - 1 < 0:
        return (0, make_error(NoliErrorType.STACK_UNDERFLOW, "Attempted to pop from empty persistant stack"))
    
    pu.psp -= 1

    var top = pu.p_stack.pop()
    if verbose: echo fmt"Poppe {top} from persistant stack"
    if verbose: echo fmt"PSP: {pu.psp}"
    if verbose: echo fmt"Persistant Stack: {pu.p_stack}"

    return (top, no_error())