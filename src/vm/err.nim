type NoliErrorType* = enum
    INVALID_OPCODE,
    STACK_UNDERFLOW,
    INVALID_REGISTER,
    INVALID_MEMORY_ADDRESS,
    FAILED_TO_ACCESS_EXEC,
    NONE,
    NOT_IMPLEMENTED,

type NoliError* = object
    kind*: NoliErrorType
    message*: string

proc write*(err: NoliError) =
    echo "ERROR '", err.kind, "': ", err.message

proc make_error*(kind: NoliErrorType, msg: string): NoliError =
    var err = NoliError()
    err.kind = kind
    err.message = msg
    return err

proc no_error*(): NoliError =
    return make_error(NoliErrorType.NONE, "")

proc check_error*(val: (uint64, NoliError)): uint64 =
    if val[1].kind != NoliErrorType.NONE:
        val[1].write()
        quit ord(val[1].kind)
    return val[0]