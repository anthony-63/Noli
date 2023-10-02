import tokens
import deques
import strformat
import strutils
import tables

proc isalpha(c: char): bool =
    return fmt"{c}".toUpper() != fmt"{c}".toLower()

proc isint(c: char): bool =
    return c in ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0']

proc isskippable(c: char): bool =
    return c in ['\n', ' ', '\t', '\r']

proc lexer_tokenize*(src_string: string): seq[NoliToken] = 
    var toks: seq[NoliToken] = @[]
    var src = src_string.toDeque

    while src.len() > 0:
        if src[0] == '(':
            toks.add(NoliToken(kind: NoliTokenType.OpenParen, value: fmt"{src.popFirst()}"))
        elif src[0] == ')':
            toks.add(NoliToken(kind: NoliTokenType.CloseParen, value: fmt"{src.popFirst()}"))
        elif src[0] in ['+', '-', '*', '/', '%']:
            toks.add(NoliToken(kind: NoliTokenType.BinOp, value: fmt"{src.popFirst()}"))
        elif src[0] == '=':
            toks.add(NoliToken(kind: NoliTokenType.Equals, value: fmt"{src.popFirst()}"))
        elif src[0] == '"':
            discard src.popFirst()
            var str = ""
            while src.len() > 0 and src[0] != '"':
                str = str & fmt"{src.popFirst()}"
            discard src.popFirst()
            toks.add(NoliToken(kind: NoliTokenType.String, value: str))
        elif src[0] == ',':
            toks.add(NoliToken(kind: NoliTokenType.Comma, value: fmt"{src.popFirst()}"))
        else:
            # build num token
            if isint(src[0]):
                var num = ""
                while src.len() > 0 and isint(src[0]):
                    num = num & fmt"{src.popFirst()}"
                toks.add(NoliToken(kind: NoliTokenType.Number, value: num))
            
            elif isalpha(src[0]):
                var ident = ""
                while src.len() > 0 and (isalpha(src[0]) or isint(src[0])):
                    ident = ident & fmt"{src.popFirst()}"

                if NOLI_KEYWORDS.hasKey(ident):
                    toks.add(NoliToken(kind: NOLI_KEYWORDS[ident], value: ident))
                elif NOLI_NATIVE_FUNCTIONS.hasKey(ident):
                    toks.add(NoliToken(kind: NOLI_NATIVE_FUNCTIONS[ident], value: ident))
                else:
                    toks.add(NoliToken(kind: NoliTokenType.Identifier, value: ident))
            elif isskippable(src[0]):
                discard src.popFirst()
            else:
                echo "Unrecognized character found: ", src[0]
                quit -1
    
    toks.add(NoliToken(kind: NoliTokenType.Eof, value: "EndOfFile"))
    
    return toks