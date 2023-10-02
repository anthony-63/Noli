import extra
import err
import strformat
import system
import ../util
import mem
import native
import ../ops

template `?`(arg: untyped): untyped = check_error(arg)

proc next(pu: var NoliPU): (uint64, NoliError) =
    pu.ip += 1
   
    if int(pu.ip) >= len(pu.scopes[0].exec):
        return (0, make_error(NoliErrorType.FAILED_TO_ACCESS_EXEC, fmt"Failed to get next opcode at addr {pu.ip}")) 
    
    if verbose: echo fmt"Next: {pu.scopes[0].exec[pu.ip]}"
    return (pu.scopes[0].exec[pu.ip], no_error())

proc moveheap(pu: var NoliPU) =
    pu.scopes[pu.scope_idx].setheap(
        ?(pu.next()), 
        ?(pu.next())
    )
    pu.interrupt = NoliInterrupts.NONE

proc movereg(pu: var NoliPU) =
    pu.scopes[pu.scope_idx].setreg(
        ?(pu.next()),
        ?(pu.next())
    )
    pu.interrupt = NoliInterrupts.NONE

proc push(pu: var NoliPU) =
    pu.scopes[pu.scope_idx].pushstack(
        ?(pu.next())
    )
    pu.interrupt = NoliInterrupts.NONE

proc pushreg(pu: var NoliPU) =
    pu.scopes[pu.scope_idx].pushstack(
        ?(pu.scopes[pu.scope_idx].getreg(?(pu.next())))
    )
    pu.interrupt = NoliInterrupts.NONE

proc pop(pu: var NoliPU) =
    pu.scopes[pu.scope_idx].setreg(
        ?(pu.scopes[pu.scope_idx].popstack()),
        ?(pu.next())
    )
    pu.interrupt = NoliInterrupts.NONE

proc ppush(pu: var NoliPU) =
    pu.pushpstack(?(pu.next()))
    pu.interrupt = NoliInterrupts.NONE

proc ppushreg(pu: var NoliPU) =
    pu.pushpstack(?(pu.scopes[pu.scope_idx].getreg(?(pu.next()))))
    pu.interrupt = NoliInterrupts.NONE

proc ppop(pu: var NoliPU) =
    pu.scopes[pu.scope_idx].setreg(?(pu.poppstack()), ?(pu.next()))
    pu.interrupt = NoliInterrupts.NONE

proc moveheaptoreg(pu: var NoliPU) =
    pu.scopes[pu.scope_idx].setreg(?(pu.next()), ?(pu.next()))
    pu.interrupt = NoliInterrupts.NONE

proc moveregtoheap(pu: var NoliPU) =
    pu.scopes[pu.scope_idx].setheap(?(pu.next()), ?(pu.next()))
    pu.interrupt = NoliInterrupts.NONE

proc moveregtoreg(pu: var NoliPU) =
    pu.scopes[pu.scope_idx].setreg(?(pu.scopes[pu.scope_idx].getreg(?(pu.next()))), ?(pu.next()))
    pu.interrupt = NoliInterrupts.NONE

proc moveheaptoheap(pu: var NoliPU) =
    pu.scopes[pu.scope_idx].setheap(?(pu.scopes[pu.scope_idx].getheap(?(pu.next()))), ?(pu.next()))
    pu.interrupt = NoliInterrupts.NONE

proc moveregtoref(pu: var NoliPU) =
    pu.scopes[pu.scope_idx].setheap(?(pu.scopes[pu.scope_idx].getreg(?(pu.next()))), ?(pu.scopes[pu.scope_idx].popstack()))
    pu.interrupt = NoliInterrupts.NONE

proc ret(pu: var NoliPU) =
    discard pu.scopes.pop()
    pu.scope_idx -= 1
    pu.call_ptr -= 1
    pu.ip = pu.call_stack.pop()
    pu.interrupt = NoliInterrupts.NONE

proc add(pu: var NoliPU) =
    var r1 = ?(pu.scopes[pu.scope_idx].getreg(?(pu.next())))
    var r2 = ?(pu.scopes[pu.scope_idx].getreg(?(pu.next())))
    pu.scopes[pu.scope_idx].pushstack(r1 + r2)
    pu.interrupt = NoliInterrupts.NONE

proc sub(pu: var NoliPU) =
    var r1 = ?(pu.scopes[pu.scope_idx].getreg(?(pu.next())))
    var r2 = ?(pu.scopes[pu.scope_idx].getreg(?(pu.next())))
    pu.scopes[pu.scope_idx].pushstack(r1 - r2)
    pu.interrupt = NoliInterrupts.NONE

proc mul(pu: var NoliPU) =
    var r1 = ?(pu.scopes[pu.scope_idx].getreg(?(pu.next())))
    var r2 = ?(pu.scopes[pu.scope_idx].getreg(?(pu.next())))
    pu.scopes[pu.scope_idx].pushstack(r1 * r2)
    pu.interrupt = NoliInterrupts.NONE

proc div_noli(pu: var NoliPU) =
    var r1 = ?(pu.scopes[pu.scope_idx].getreg(?(pu.next())))
    var r2 = ?(pu.scopes[pu.scope_idx].getreg(?(pu.next())))
    pu.scopes[pu.scope_idx].pushstack(uint64(int(r1) / int(r2)))
    pu.interrupt = NoliInterrupts.NONE

proc fdiv(pu: var NoliPU) =
    pu.interrupt = NoliInterrupts.NONE

proc inc(pu: var NoliPU) =
    var reg = ?(pu.next())
    pu.scopes[pu.scope_idx].setreg(?(pu.scopes[pu.scope_idx].getreg(reg)) + 1, reg)
    pu.interrupt = NoliInterrupts.NONE

proc dec(pu: var NoliPU) =
    var reg = ?(pu.next())
    pu.scopes[pu.scope_idx].setreg(?(pu.scopes[pu.scope_idx].getreg(reg)) - 1, reg)
    pu.interrupt = NoliInterrupts.NONE

proc bitwiseor(pu: var NoliPU) =
    var r1 = ?(pu.scopes[pu.scope_idx].getreg(?(pu.next())))
    var r2 = ?(pu.scopes[pu.scope_idx].getreg(?(pu.next())))
    pu.scopes[pu.scope_idx].pushstack(uint64(r1 or r2))
    pu.interrupt = NoliInterrupts.NONE

proc bitwiseand(pu: var NoliPU) =
    var r1 = ?(pu.scopes[pu.scope_idx].getreg(?(pu.next())))
    var r2 = ?(pu.scopes[pu.scope_idx].getreg(?(pu.next())))
    pu.scopes[pu.scope_idx].pushstack(uint64(r1 and r2))
    pu.interrupt = NoliInterrupts.NONE

proc bitwisexor(pu: var NoliPU) =
    var r1 = ?(pu.scopes[pu.scope_idx].getreg(?(pu.next())))
    var r2 = ?(pu.scopes[pu.scope_idx].getreg(?(pu.next())))
    pu.scopes[pu.scope_idx].pushstack(uint64(r1 xor r2))
    pu.interrupt = NoliInterrupts.NONE

proc bitwisenot(pu: var NoliPU) =
    var r1 = ?(pu.scopes[pu.scope_idx].getreg(?(pu.next())))
    pu.scopes[pu.scope_idx].pushstack(uint64(not r1))
    pu.interrupt = NoliInterrupts.NONE

proc logicalor(pu: var NoliPU) =
    var r1 = ?(pu.scopes[pu.scope_idx].getreg(?(pu.next())))
    var r2 = ?(pu.scopes[pu.scope_idx].getreg(?(pu.next())))
    pu.scopes[pu.scope_idx].pushstack(uint64(bool(r1) or bool(r2)))
    pu.interrupt = NoliInterrupts.NONE

proc logicaland(pu: var NoliPU) =
    var r1 = ?(pu.scopes[pu.scope_idx].getreg(?(pu.next())))
    var r2 = ?(pu.scopes[pu.scope_idx].getreg(?(pu.next())))
    pu.scopes[pu.scope_idx].pushstack(uint64(bool(r1) and bool(r2)))
    pu.interrupt = NoliInterrupts.NONE

proc logicalnot(pu: var NoliPU) =
    var r1 = ?(pu.scopes[pu.scope_idx].getreg(?(pu.next())))
    pu.scopes[pu.scope_idx].pushstack(uint64(not bool(r1)))
    pu.interrupt = NoliInterrupts.NONE

proc eq(pu: var NoliPU) =
    var r1 = ?(pu.scopes[pu.scope_idx].getreg(?(pu.next())))
    var r2 = ?(pu.scopes[pu.scope_idx].getreg(?(pu.next())))
    pu.scopes[pu.scope_idx].pushstack(uint64(r1 == r2))
    pu.interrupt = NoliInterrupts.NONE

proc neq(pu: var NoliPU) =
    var r1 = ?(pu.scopes[pu.scope_idx].getreg(?(pu.next())))
    var r2 = ?(pu.scopes[pu.scope_idx].getreg(?(pu.next())))
    pu.scopes[pu.scope_idx].pushstack(uint64(r1 != r2))
    pu.interrupt = NoliInterrupts.NONE

proc gt(pu: var NoliPU) =
    var r1 = ?(pu.scopes[pu.scope_idx].getreg(?(pu.next())))
    var r2 = ?(pu.scopes[pu.scope_idx].getreg(?(pu.next())))
    pu.scopes[pu.scope_idx].pushstack(uint64(r1 > r2))
    pu.interrupt = NoliInterrupts.NONE

proc lt(pu: var NoliPU) =
    var r1 = ?(pu.scopes[pu.scope_idx].getreg(?(pu.next())))
    var r2 = ?(pu.scopes[pu.scope_idx].getreg(?(pu.next())))
    pu.scopes[pu.scope_idx].pushstack(uint64(r1 < r2))

proc gteq(pu: var NoliPU) =
    var r1 = ?(pu.scopes[pu.scope_idx].getreg(?(pu.next())))
    var r2 = ?(pu.scopes[pu.scope_idx].getreg(?(pu.next())))
    pu.scopes[pu.scope_idx].pushstack(uint64(r1 >= r2))
    pu.interrupt = NoliInterrupts.NONE

proc lteg(pu: var NoliPU) =
    var r1 = ?(pu.scopes[pu.scope_idx].getreg(?(pu.next())))
    var r2 = ?(pu.scopes[pu.scope_idx].getreg(?(pu.next())))
    pu.scopes[pu.scope_idx].pushstack(uint64(r1 <= r2))
    pu.interrupt = NoliInterrupts.NONE

proc call(pu: var NoliPU) =
    pu.calling_func = true
    pu.scope_idx += 1
    var jump = ?(pu.next())
    if verbose: echo fmt"Calling function at index: {pu.ip}"
    pu.call_stack.add(pu.ip)
    pu.ip = jump
    pu.call_ptr += 1
    pu.scopes.add(NoliMEM())
    if verbose: echo fmt"Call stack: {pu.call_stack}"
    pu.interrupt = NoliInterrupts.NONE

proc func_noli(pu: var NoliPU) =
    if not pu.calling_func:
        var dist = pu.xref_table[pu.ip] - pu.ip
        pu.ip += dist
        if verbose: echo fmt"Skipping function: {pu.ip - dist} with size {dist}"
    else:
        pu.calling_func = false
    pu.interrupt = NoliInterrupts.NONE

proc end_noli(pu: var NoliPU) =
    pu.interrupt = NoliInterrupts.NONE

proc native_opcode(pu: var NoliPU) =
    var func_idx = ?(pu.scopes[pu.scope_idx].popstack())
    if verbose: echo fmt"Calling native function index: {func_idx}"
    NOLI_VM_NATIVE_CALL_TABLE[func_idx](pu)
    pu.interrupt = NoliInterrupts.NONE

proc jmpeq(pu: var NoliPU) =
    var address = ?(pu.next())
    var cond = bool(?(pu.scopes[pu.scope_idx].popstack()))
    if cond:
        pu.ip = address
        pu.interrupt = NoliInterrupts.DONT_INC
    else: pu.interrupt = NoliInterrupts.NONE

proc jmpneq(pu: var NoliPU) =
    var address = ?(pu.next())
    var cond = bool(?(pu.scopes[pu.scope_idx].popstack()))
    if not cond:
        pu.ip = address
        pu.interrupt = NoliInterrupts.DONT_INC
    else: pu.interrupt = NoliInterrupts.NONE

proc jmp(pu: var NoliPU) =
    var address = ?(pu.next())
    pu.ip = address
    pu.interrupt = NoliInterrupts.DONT_INC

proc jmpstack(pu: var NoliPU) =
    var address = ?(pu.scopes[pu.scope_idx].popstack())
    pu.ip = address
    pu.interrupt = NoliInterrupts.DONT_INC

proc puship(pu: var NoliPU) =
    pu.scopes[pu.scope_idx].pushstack(pu.ip)

proc noop(pu: var NoliPU) =
    discard

type CallTableEntry = proc(pu: var NoliPU)

const NOLI_VM_CALL_TABLE*: seq[CallTableEntry] = @[
    CallTableEntry moveheap,
    movereg,
    push,
    pushreg,
    pop,
    ppush,
    ppushreg,
    ppop,
    moveheaptoreg,
    moveregtoheap,
    moveregtoreg,
    moveheaptoheap,
    moveregtoref,
    ret,
    add,
    sub,
    mul,
    div_noli,
    fdiv,
    inc,
    dec,
    bitwiseor,
    bitwiseand,
    bitwisexor,
    bitwisenot,
    logicalor,
    logicaland,
    logicalnot,
    eq,
    neq,
    gt,
    lt,
    gteq,
    lteg,
    call,
    func_noli,
    end_noli,
    native_opcode,
    jmpeq,
    jmpneq,
    jmp,
    jmpstack,
    puship,
    noop,
]