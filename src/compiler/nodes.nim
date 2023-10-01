type
    NoliNodeKind* = enum
        Program,
        NumericLit,
        Identifier,
        BinaryExpr,
        NullLit,
    NoliNode* = ref object
        case kind*: NoliNodeKind
        of Program:
            body*: seq[NoliNode]
        of BinaryExpr:
            left*: NoliNode
            right*: NoliNode
            op*: string
        of Identifier:
            symbol*: string
        of NumericLit:
            value*: float
        of NullLit: discard