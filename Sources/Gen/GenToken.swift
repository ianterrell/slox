class TokenGenerator {
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
    enum Token: CustomStringConvertible {
    \(allCases(indent: 2, caseDef))

      init?(location: String.Index, lexeme: String) {
        switch lexeme {
    \(allKeywords(indent: 4, caseKeywordInit))
        default: return nil
        }
      }

      var name: String {
        switch self {
    \(allCases(indent: 4, caseName))
        }
      }

      var lexeme: String {
        switch self {
    \(allCases(indent: 4, caseLexeme))
        }
      }

      var description: String {
        if lexeme.isEmpty {
          return name
        }
        return "\\(name) \\(lexeme)"
      }
    }
    """
  }

  func literalType(for t: String) -> String? {
    return TokenGenerator.literalTypes[t]
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

  func allKeywords(indent: Int, _ callback: (String) -> String) -> String {
    return enumerate(cases: TokenGenerator.keywordNames, indent: indent, callback: callback)
  }

  func allCases(indent: Int, _ callback: (String) -> String) -> String {
    return enumerate(cases: TokenGenerator.tokenNames, indent: indent, callback: callback)
  }

  func enumerate(cases: [String], indent: Int, callback: (String) -> String) -> String {
    let ws = String(repeating: " ", count: indent)
    let cases = cases.map(callback)
    let indented = cases.map{"\(ws)\($0)"}
    return indented.joined(separator: "\n")
  }
}
