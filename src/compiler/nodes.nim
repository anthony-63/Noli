type
    NoliNodeKind* = enum
        Program,
        NumericLit,
        Identifier,
        BinaryExpr,
        VariableDecl,
        StringLit,
        NullLit,
        NativeCall,
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
        of VariableDecl:
            ident*: string
            var_value*: NoliNode
            var_type*: string
        of NumericLit:
            num_value*: float
        of StringLit:
            str_value*: string
        of NullLit: discard
        of NativeCall:
            name*: string
            args*: seq[NoliNode]