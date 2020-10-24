import Libslox

let a = Literal(value: .number(5))
let b = Literal(value: .number(1))
let plus = Binary(left: a, op: .PLUS(location: "".startIndex, lexeme: "+"), right: b)

let printer = DotPrinter()
print(printer.print(plus))
