import nodes
import tokens
import deques
import strutils
import strformat

type NoliParser = object
    tokens: Deque[NoliToken]

proc eat(parser: var NoliParser): NoliToken =
    return parser.tokens.popFirst()

proc expect(parser: var NoliParser, kind: NoliTokenType, err: string): NoliToken =
    var prev = parser.eat()
    if prev.kind != kind:
        echo "Error: ", err, ", ", prev, "- Expected: ", kind
        quit -1
    return prev

proc parse_expr(parser: var NoliParser): NoliNode
proc parse_func_args(parser: var NoliParser): seq[NoliNode]

proc parse_primary_expr(parser: var NoliParser): NoliNode =
    var t = parser.tokens[0].kind
    case t:
    of Identifier: return NoliNode(kind: NoliNodeKind.Identifier, symbol: parser.eat().value)
    of Number: return NoliNode(kind: NoliNodeKind.NumericLit, num_value: parseFloat(parser.eat().value))
    of Null:
        discard parser.eat()
        return NoliNode(kind: NoliNodeKind.NullLit)
    of OpenParen:
        discard parser.eat()
        var val = parser.parse_expr()
        discard parser.expect(NoliTokenType.CloseParen, "Expected closing paren")
        return val
    of Let:
        discard parser.eat()
        var ident = parser.expect(NoliTokentype.Identifier, "Expected identifier for variable declaration")
        var typ = parser.expect(NoliTokentype.Type, "Expected type after identifier variable declaration")
        discard parser.expect(NoliTokenType.Equals, "Expected equals after type for variable declaration")
        var val: NoliNode
        if typ.value == "string":
            val = NoliNode(kind: NoliNodeKind.StringLit, str_value: parser.expect(NoliTokenType.String, "Expected string").value)
        elif typ.value == "num":
            val = parser.parse_expr()
        return NoliNode(kind: NoliNodeKind.VariableDecl, var_type: typ.value, ident: ident.value, var_value: val)
    of Native:
        var name = parser.eat().value
        var args = parser.parse_func_args()
        return NoliNode(kind: NoliNodeKind.NativeCall, args: args, name: name)
    else:
        echo fmt"Unexpected token: {repr(parser.tokens[0])}"
        quit -1
    
proc parse_multiplicitave_expr(parser: var NoliParser): NoliNode =
    var left = parser.parse_primary_expr()

    while parser.tokens[0].value == "/" or parser.tokens[0].value == "*" or parser.tokens[0].value == "%":
        var op = parser.tokens.popFirst().value
        var right = parser.parse_primary_expr()
        left = NoliNode(kind: NoliNodeKind.BinaryExpr, left: left, right: right, op: op)
    return left

proc parse_additive_expr(parser: var NoliParser): NoliNode =
    var left = parser.parse_multiplicitave_expr()

    while parser.tokens[0].value == "+" or parser.tokens[0].value == "-":
        var op = parser.tokens.popFirst().value
        var right = parser.parse_multiplicitave_expr()
        left = NoliNode(kind: NoliNodeKind.BinaryExpr, left: left, right: right, op: op)
    return left

proc parse_expr(parser: var NoliParser): NoliNode =
    return parser.parse_additive_expr()

proc parse_stmt(parser: var NoliParser): NoliNode =
    return parser.parse_expr()

proc parse_func_args(parser: var NoliParser): seq[NoliNode] = # TODO
    var args: seq[NoliNode] = @[]
    args.add(parser.parse_additive_expr())
    while parser.tokens[0].kind == NoliTokenType.Comma:
        args.add(parser.parse_additive_expr())
    return args
proc generate_ast*(tokens: seq[NoliToken]): NoliNode =
    var program = NoliNode(kind: Program, body: @[])

    var parser = NoliParser(tokens: tokens.toDeque)

    while parser.tokens[0].kind != NoliTokenType.Eof:
        program.body.add(parser.parse_stmt())

    return program

