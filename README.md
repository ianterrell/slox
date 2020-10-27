# slox

Following along with [Crafting Interpreters](https://craftinginterpreters.com), in Swift.

## Building & Running

- `swift run slox` to run REPL
- `swift run slox path/to/script.lox` to run script
- `swift run slox path/to/script.lox --print` to output Graphviz of AST
- `swift run genslox` to regenerate code

# To Do

To make this language more my own, I'd like to change a few things about Lox.

## Language Improvements

- [ ] Remove nil
- [ ] Remove semicolons
- [ ] Remove parentheses from conditionals; require block statement
- [ ] Add +=, -=, /=, *= operators

## Refactors

- [ ] Rewrite `Parser` `match()` calls with pattern matching; look at `if`-chains!
- [ ] Distinguish statement-starting tokens from other tokens?
