import nodes
import tables
import ../ops
import ../util

type NoliGenerator = object
    variables: Table[string, (string, uint64)]
    variable_index: uint64
    string_address_index: uint64

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
                generator.variables[node.ident] = (node.var_type, generator.variable_index)
                if verbose: echo "Declared variable: ", generator.variables[node.ident]
                bytecode.add(ord(NOLI_OPCODES.MOVEREG))
                bytecode.add(uint64(int(node.var_value.num_value)))
                bytecode.add(generator.variable_index)
                generator.variable_index += 1
            of "string":
                generator.variables[node.ident] = (node.var_type, generator.variable_index)
                if verbose: echo "Declared variable: ", repr(generator.variables[node.ident])
                bytecode.add(ord(NOLI_OPCODES.MOVEREG))
                bytecode.add(generator.string_address_index)
                bytecode.add(generator.variable_index)
                bytecode.add(ord(NOLI_OPCODES.MOVEHEAP))
                bytecode.add(uint64(node.var_value.str_value.len))
                bytecode.add(generator.string_address_index)
                generator.string_address_index += 1
                for c in node.var_value.str_value:
                    bytecode.add(ord(NOLI_OPCODES.MOVEHEAP))
                    bytecode.add(uint64(ord(c)))
                    bytecode.add(generator.string_address_index)
                    generator.string_address_index += 1
                generator.variable_index += 1
            else:
                echo "Unknown variable type: ", node.var_type
                quit 1
        of NoliNodeKind.NativeCall:
            case node.native_name:
            of "print":
                for arg in node.native_args:
                    if arg.kind != Identifier:
                        echo "Noli only supports printing string variables currently"
                        quit 1
                    if not generator.variables.hasKey(arg.symbol):
                        echo "Undefined variable: ", arg.symbol
                        quit 1
                    var (var_type, var_val) = generator.variables[arg.symbol]
                    if var_type != "string":
                        echo "Can only print string variables currently"
                        quit 1
                    bytecode.add(ord(NOLI_OPCODES.PUSHREG))
                    bytecode.add(var_val)
        
                bytecode.add(ord(NOLI_OPCODES.PUSH))
                bytecode.add(0)
                bytecode.add(ord(NOLI_OPCODES.NATIVE))
            else: 
                echo "Invalid native name: ", node.native_name
                quit 1
        else: discard
    return bytecode