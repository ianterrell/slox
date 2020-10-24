//
// THIS IS A GENERATED FILE DO NOT EDIT
//

public enum Token: CustomStringConvertible {
  case AND(location: String.Index, lexeme: String)
  case BANG(location: String.Index, lexeme: String)
  case BANG_EQUAL(location: String.Index, lexeme: String)
  case CLASS(location: String.Index, lexeme: String)
  case COMMA(location: String.Index, lexeme: String)
  case DOT(location: String.Index, lexeme: String)
  case ELSE(location: String.Index, lexeme: String)
  case EOF(location: String.Index, lexeme: String)
  case EQUAL(location: String.Index, lexeme: String)
  case EQUAL_EQUAL(location: String.Index, lexeme: String)
  case FALSE(location: String.Index, lexeme: String)
  case FOR(location: String.Index, lexeme: String)
  case FUN(location: String.Index, lexeme: String)
  case GREATER(location: String.Index, lexeme: String)
  case GREATER_EQUAL(location: String.Index, lexeme: String)
  case IDENTIFIER(location: String.Index, lexeme: String)
  case IF(location: String.Index, lexeme: String)
  case LEFT_BRACE(location: String.Index, lexeme: String)
  case LEFT_PAREN(location: String.Index, lexeme: String)
  case LESS(location: String.Index, lexeme: String)
  case LESS_EQUAL(location: String.Index, lexeme: String)
  case MINUS(location: String.Index, lexeme: String)
  case NIL(location: String.Index, lexeme: String)
  case NUMBER(location: String.Index, lexeme: String, value: Double)
  case OR(location: String.Index, lexeme: String)
  case PLUS(location: String.Index, lexeme: String)
  case PRINT(location: String.Index, lexeme: String)
  case RETURN(location: String.Index, lexeme: String)
  case RIGHT_BRACE(location: String.Index, lexeme: String)
  case RIGHT_PAREN(location: String.Index, lexeme: String)
  case SEMICOLON(location: String.Index, lexeme: String)
  case SLASH(location: String.Index, lexeme: String)
  case STAR(location: String.Index, lexeme: String)
  case STRING(location: String.Index, lexeme: String, value: String)
  case SUPER(location: String.Index, lexeme: String)
  case THIS(location: String.Index, lexeme: String)
  case TRUE(location: String.Index, lexeme: String)
  case VAR(location: String.Index, lexeme: String)
  case WHILE(location: String.Index, lexeme: String)

  init?(location: String.Index, lexeme: String) {
    switch lexeme {
    case "and": self = .AND(location: location, lexeme: lexeme)
    case "class": self = .CLASS(location: location, lexeme: lexeme)
    case "else": self = .ELSE(location: location, lexeme: lexeme)
    case "false": self = .FALSE(location: location, lexeme: lexeme)
    case "fun": self = .FUN(location: location, lexeme: lexeme)
    case "for": self = .FOR(location: location, lexeme: lexeme)
    case "if": self = .IF(location: location, lexeme: lexeme)
    case "nil": self = .NIL(location: location, lexeme: lexeme)
    case "or": self = .OR(location: location, lexeme: lexeme)
    case "print": self = .PRINT(location: location, lexeme: lexeme)
    case "return": self = .RETURN(location: location, lexeme: lexeme)
    case "super": self = .SUPER(location: location, lexeme: lexeme)
    case "this": self = .THIS(location: location, lexeme: lexeme)
    case "true": self = .TRUE(location: location, lexeme: lexeme)
    case "var": self = .VAR(location: location, lexeme: lexeme)
    case "while": self = .WHILE(location: location, lexeme: lexeme)
    default: return nil
    }
  }

  public var name: String {
    switch self {
    case .AND: return "AND"
    case .BANG: return "BANG"
    case .BANG_EQUAL: return "BANG_EQUAL"
    case .CLASS: return "CLASS"
    case .COMMA: return "COMMA"
    case .DOT: return "DOT"
    case .ELSE: return "ELSE"
    case .EOF: return "EOF"
    case .EQUAL: return "EQUAL"
    case .EQUAL_EQUAL: return "EQUAL_EQUAL"
    case .FALSE: return "FALSE"
    case .FOR: return "FOR"
    case .FUN: return "FUN"
    case .GREATER: return "GREATER"
    case .GREATER_EQUAL: return "GREATER_EQUAL"
    case .IDENTIFIER: return "IDENTIFIER"
    case .IF: return "IF"
    case .LEFT_BRACE: return "LEFT_BRACE"
    case .LEFT_PAREN: return "LEFT_PAREN"
    case .LESS: return "LESS"
    case .LESS_EQUAL: return "LESS_EQUAL"
    case .MINUS: return "MINUS"
    case .NIL: return "NIL"
    case .NUMBER: return "NUMBER"
    case .OR: return "OR"
    case .PLUS: return "PLUS"
    case .PRINT: return "PRINT"
    case .RETURN: return "RETURN"
    case .RIGHT_BRACE: return "RIGHT_BRACE"
    case .RIGHT_PAREN: return "RIGHT_PAREN"
    case .SEMICOLON: return "SEMICOLON"
    case .SLASH: return "SLASH"
    case .STAR: return "STAR"
    case .STRING: return "STRING"
    case .SUPER: return "SUPER"
    case .THIS: return "THIS"
    case .TRUE: return "TRUE"
    case .VAR: return "VAR"
    case .WHILE: return "WHILE"
    }
  }

  public var lexeme: String {
    switch self {
    case .AND(_, let lexeme): return lexeme
    case .BANG(_, let lexeme): return lexeme
    case .BANG_EQUAL(_, let lexeme): return lexeme
    case .CLASS(_, let lexeme): return lexeme
    case .COMMA(_, let lexeme): return lexeme
    case .DOT(_, let lexeme): return lexeme
    case .ELSE(_, let lexeme): return lexeme
    case .EOF(_, let lexeme): return lexeme
    case .EQUAL(_, let lexeme): return lexeme
    case .EQUAL_EQUAL(_, let lexeme): return lexeme
    case .FALSE(_, let lexeme): return lexeme
    case .FOR(_, let lexeme): return lexeme
    case .FUN(_, let lexeme): return lexeme
    case .GREATER(_, let lexeme): return lexeme
    case .GREATER_EQUAL(_, let lexeme): return lexeme
    case .IDENTIFIER(_, let lexeme): return lexeme
    case .IF(_, let lexeme): return lexeme
    case .LEFT_BRACE(_, let lexeme): return lexeme
    case .LEFT_PAREN(_, let lexeme): return lexeme
    case .LESS(_, let lexeme): return lexeme
    case .LESS_EQUAL(_, let lexeme): return lexeme
    case .MINUS(_, let lexeme): return lexeme
    case .NIL(_, let lexeme): return lexeme
    case .NUMBER(_, let lexeme, _): return lexeme
    case .OR(_, let lexeme): return lexeme
    case .PLUS(_, let lexeme): return lexeme
    case .PRINT(_, let lexeme): return lexeme
    case .RETURN(_, let lexeme): return lexeme
    case .RIGHT_BRACE(_, let lexeme): return lexeme
    case .RIGHT_PAREN(_, let lexeme): return lexeme
    case .SEMICOLON(_, let lexeme): return lexeme
    case .SLASH(_, let lexeme): return lexeme
    case .STAR(_, let lexeme): return lexeme
    case .STRING(_, let lexeme, _): return lexeme
    case .SUPER(_, let lexeme): return lexeme
    case .THIS(_, let lexeme): return lexeme
    case .TRUE(_, let lexeme): return lexeme
    case .VAR(_, let lexeme): return lexeme
    case .WHILE(_, let lexeme): return lexeme
    }
  }

  public var description: String {
    if lexeme.isEmpty {
      return name
    }
    return "\(name) \(lexeme)"
  }
}