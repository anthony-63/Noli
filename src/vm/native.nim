import extra
import mem
import err
import ../util
import std/strformat

proc print_native(pu: var NoliPU) =
    var address = check_error(pu.scopes[pu.scope_idx].popstack())
    var size = check_error(pu.scopes[pu.scope_idx].getheap(address))
    if verbose: echo fmt"Printing out string at address {address} with length of {size}"
    var old = verbose
    if verbose: verbose = false

    for i in 0..<size+1:
        stdout.write(char(check_error(pu.scopes[pu.scope_idx].getheap(address + i))))

    if old: verbose = true

proc print_register_native(pu: var NoliPU) =
    var reg = check_error(pu.scopes[pu.scope_idx].popstack())
    if verbose: echo fmt"Printing register r{reg}"
    stdout.write(check_error(pu.scopes[pu.scope_idx].getreg(reg)))

const NOLI_VM_NATIVE_CALL_TABLE*: seq[proc(pu: var NoliPU) {.nimcall.} ] = @[
    print_native,
    print_register_native,
]
