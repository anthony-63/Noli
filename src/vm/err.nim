type NoliErrorType* = enum
    INVALID_OPCODE,
    STACK_UNDERFLOW,
    INVALID_REGISTER,
    INVALID_MEMORY_ADDRESS,
    FAILED_TO_ACCESS_EXEC,
    NONE,
    DO_NOT_SKIP,
    NOT_IMPLEMENTED,

type NoliError* = object
    kind: NoliErrorType
    message: string

proc write*(err: var NoliError) =
    echo "ERROR '", err.kind, "': ", err.message

proc make_error*(kind: NoliErrorType, msg: string): NoliError =
    var err = NoliError()
    err.kind = kind
    err.message = msg
    return err

proc no_error*(): NoliError =
    return make_error(NoliErrorType.NONE, "")

proc check*(err: var NoliError) =
    if err.kind != NoliErrorType.NONE:
        err.write()
        quit ord(err.kind)