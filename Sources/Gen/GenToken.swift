class TokenGenerator: BaseGenerator {
  struct Token {
    let name: String
    let literalType: String?
    init(name: String, literalType: String? = nil) {
      self.name = name
      self.literalType = literalType
    }
  }

  static let tokenNames = [
    "LEFT_PAREN", "RIGHT_PAREN", "LEFT_BRACE", "RIGHT_BRACE",
    "COMMA", "DOT", "MINUS", "PLUS", "SEMICOLON", "SLASH", "STAR",
    "BANG", "BANG_EQUAL", "EQUAL", "EQUAL_EQUAL",
    "GREATER", "GREATER_EQUAL", "LESS", "LESS_EQUAL",
    "IDENTIFIER", "STRING", "NUMBER",
    "AND", "CLASS", "ELSE", "FALSE", "FUN", "FOR", "IF", "NIL", "OR",
    "PRINT", "RETURN", "SUPER", "THIS", "TRUE", "VAR", "WHILE",
    "EOF",
  ].sorted()

  static let literalTypes = [
    "STRING": "String",
    "NUMBER": "Double",
  ]

  static let keywordNames = [
    "AND", "CLASS", "ELSE", "FALSE", "FUN", "FOR", "IF", "NIL", "OR",
    "PRINT", "RETURN", "SUPER", "THIS", "TRUE", "VAR", "WHILE",
  ]

  func genTokens() -> String {
    return """
    \(generatedCodeWarning)
    
    public enum Token: CustomStringConvertible {
    \(indent(2, allCases(caseDef)))

      init?(location: String.Index, lexeme: String) {
        switch lexeme {
    \(indent(4, allKeywords(caseKeywordInit)))
        default: return nil
        }
      }

      public var name: String {
        switch self {
    \(indent(4, allCases(caseName)))
        }
      }

      public var lexeme: String {
        switch self {
    \(indent(4, allCases(caseLexeme)))
        }
      }

      public var description: String {
        if lexeme.isEmpty {
          return name
        }
        return "\\(name) \\(lexeme)"
      }
    }
    """
  }

  func literalType(for t: String) -> String? {
    return Self.literalTypes[t]
  }

  func caseDef(_ t: String) -> String {
    var output = "case \(t)(location: String.Index, lexeme: String"
    if let literalType = literalType(for: t) {
      output += ", value: \(literalType)"
    }
    output += ")"
    return output
  }

  func caseName(_ t: String) -> String {
    return "case .\(t): return \"\(t)\""
  }

  func caseLexeme(_ t: String) -> String {
    var output = "case .\(t)(_, let lexeme"
    if literalType(for: t) != nil {
      output += ", _"
    }
    output += "): return lexeme"
    return output
  }

  func caseKeywordInit(_ t: String) -> String {
    return "case \"\(t.lowercased())\": self = .\(t)(location: location, lexeme: lexeme)"
  }

  func allKeywords(_ callback: (String) -> String) -> [String] {
    return Self.keywordNames.map(callback)
  }

  func allCases(_ callback: (String) -> String) -> [String] {
    return Self.tokenNames.map(callback)
  }
}
