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

proc parse_primary_expr(parser: var NoliParser): NoliNode =
    var t = parser.tokens[0].kind
    case t:
    of Identifier: return NoliNode(kind: NoliNodeKind.Identifier, symbol: parser.eat().value)
    of Number: return NoliNode(kind: NoliNodeKind.NumericLit, value: parseFloat(parser.eat().value))
    of Null:
        discard parser.eat()
        return NoliNode(kind: NoliNodeKind.NullLit)
    of OpenParen:
        discard parser.eat()
        var val = parser.parse_expr()
        discard parser.expect(NoliTokenType.CloseParen, "Expected closing paren")
        return val
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

proc generate_ast*(tokens: seq[NoliToken]): NoliNode =
    var program = NoliNode(kind: Program, body: @[])

    var parser = NoliParser(tokens: tokens.toDeque)

    while parser.tokens[0].kind != NoliTokenType.Eof:
        program.body.add(parser.parse_stmt())

    return program

