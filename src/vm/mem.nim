import err
import ../util

type NoliMEM* = object
    exec*: seq[uint64]
    
    heap*: seq[uint64]
    heap_size*: uint64
    
    registers*: seq[uint64]
    reigsters_size*: uint64

    stack*: seq[uint64]
    sp*: uint64

proc pushstack(mem: var NoliMEM, value: uint64): NoliError =
    if verbose: echo "Pushing ", value, " to the stack"
    mem.stack.add(value)
    mem.sp += 1
    if verbose: echo "Stack: ", mem.stack
    return make_error(NoliErrorType.NONE, "")

proc popstack(mem: var NoliMEM): (uint64, NoliError) =
    if mem.sp - 1 < 0:
        return (0, make_error(NoliErrorType.STACK_UNDERFLOW, "Attempted to pop from empty stack"))
    
    mem.sp -= 1

    var top = mem.stack.pop()
    if verbose: echo "Popped ", top, " from stack"
    if verbose: echo "SP: ", mem.sp
    if verbose: echo "Stack: ", mem.stack

    return (top, make_error(NoliErrorType.NONE, ""))