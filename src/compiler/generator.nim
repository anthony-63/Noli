import nodes
import tables
import ../ops
import ../util

type NoliGenerator = object
    variables: Table[string, (string, uint64)]
    variable_index: uint64
    string_address_index: uint64

template `<-` (bytecode: seq[untyped], toadd: untyped) = bytecode.add(toadd)
template `<-` (bytecode: seq[untyped], toadd: seq[untyped]) = bytecode.add(toadd)
template `@` (enum_type: untyped): uint64 = ord(enum_type)

proc construct_tmp_ident(idx: uint64): string =
    return ("tmp_" & repr(idx * 0xFF))

proc store_string*(generator: var NoliGenerator, str: string, tmp: bool = true, identifier: string = ""): seq[uint64] =
    var bytecode: seq[uint64] = @[]

    var ident = ""
    if tmp: ident = construct_tmp_ident(generator.variable_index)
    else: ident = identifier

    generator.variables[ident] = ("string", generator.variable_index) 
    if debugging: echo "Declared variable: ", repr(generator.variables[ident]), ", ", ident, ", \"", str, "\""
    bytecode <- @(NOLI_OPCODES.MOVEREG)
    bytecode <- generator.string_address_index
    bytecode <- generator.variable_index
    bytecode <- @(NOLI_OPCODES.MOVEHEAP)
    bytecode <- uint64(str.len)
    bytecode <- generator.string_address_index
    generator.string_address_index += 1
    for c in str:
        bytecode <- @(NOLI_OPCODES.MOVEHEAP)
        bytecode <- uint64(c)
        bytecode <- generator.string_address_index
        generator.string_address_index += 1
    generator.variable_index += 1
    
    return bytecode

proc get_variable(generator: var NoliGenerator, identifier: string): (string, uint64) =
    if not generator.variables.hasKey(identifier):
        echo "Undefined variable: ", identifier
        quit 1
    return generator.variables[identifier]

proc walk_through_binop(tree: NoliNode): uint64 = discard

proc generate_bytecode*(ast: NoliNode): seq[uint64] =
    var bytecode: seq[uint64] = @[]
    var generator = NoliGenerator()
    generator.variable_index = 0xFF
    generator.string_address_index = 0x0000
    
    var outer_node = ast
    
    assert(outer_node.kind == Program)

    for node in outer_node.body:
        case node.kind:
        of NoliNodeKind.VariableDecl:
            case node.var_type:
            of "num":
                if node.var_value.kind != NumericLit:
                    echo "Variable assignment doesnt support Expressions yet."
                    quit 1
                generator.variables[node.ident] = (node.var_type, generator.variable_index)
                if debugging: echo "Declared variable: ", generator.variables[node.ident], ", ", node.ident, ", \"", repr(node.var_value), "\""
                bytecode <- @(NOLI_OPCODES.MOVEREG)
                bytecode <- uint64(int(node.var_value.num_value))
                bytecode <- generator.variable_index
                generator.variable_index += 1
            of "string": bytecode <- generator.store_string(node.var_value.str_value, false, node.ident)
            else:
                echo "Unknown variable type: ", node.var_type
                quit 1
        of NoliNodeKind.NativeCall:
            case node.native_name:
            of "print":
                for arg in node.native_args:
                    if arg.kind != Identifier and arg.kind != StringLit:
                        echo "'print' only supports printing strings, try 'print_number' for printing numbers"
                        quit 1
                    case arg.kind:
                    of Identifier:
                        var (var_type, var_val) = generator.get_variable(arg.symbol)
                        if var_type != "string":
                            echo "'print' only supports strings, try 'print_number' for printing numbers"
                            quit 1
                        bytecode <- @(NOLI_OPCODES.PUSHREG)
                        bytecode <- var_val
                    of StringLit:
                        var nbc = generator.store_string(arg.str_value)
                        bytecode.add(nbc)
                        var ident = construct_tmp_ident(generator.variable_index - 1)
                        var (var_type, var_val) = generator.get_variable(ident)
                        assert(var_type == "string")
                        
                        bytecode <- @(NOLI_OPCODES.PUSHREG)
                        bytecode <- var_val
                    else: discard
        
                bytecode <- @(NOLI_OPCODES.PUSH)
                bytecode <- 0
                bytecode <- @(NOLI_OPCODES.NATIVE)
            of "print_number":
                for arg in node.native_args:
                    if arg.kind != Identifier and arg.kind != NumericLit and arg.kind != BinaryExpr:
                        echo "'number' only supports printing numbers, try 'print' for strings"
                        quit 1
                    case arg.kind:
                    of Identifier:
                        var (var_type, var_val) = generator.get_variable(arg.symbol)
                        if var_type != "num":
                            echo "'print_number' only supports numbers, try 'print' for strings"
                        bytecode <- @(NOLI_OPCODES.PUSH)
                        bytecode <- var_val
                    of NumericLit:
                        bytecode <- @(NOLI_OPCODES.MOVEREG)
                        bytecode <- uint64(int(arg.num_value))
                        bytecode <- 0
                        bytecode <- @(NOLI_OPCODES.PUSH)
                        bytecode <- 0
                    else: 
                        echo "print_number: Kind: ", arg.kind, " not supported"
                        quit 1
                bytecode <- @(NOLI_OPCODES.PUSH)
                bytecode <- 1
                bytecode <- @(NOLI_OPCODES.NATIVE)
            else: 
                echo "Invalid native name: ", node.native_name
                quit 1
        else: discard
    return bytecode