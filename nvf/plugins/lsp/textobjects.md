# Textobjects

## nvim-treesitter-textobjects

### Select (o, x)

| Key    | Textobject         | Description                          |
|--------|--------------------|--------------------------------------|
| `if`   | @function.inner    | Function body                        |
| `af`   | @function.outer    | Whole function including signature   |
| `ic`   | @class.inner       | Class body                           |
| `ac`   | @class.outer       | Whole class                          |
| `ia`   | @parameter.inner   | Parameter without comma              |
| `aa`   | @parameter.outer   | Parameter with comma                 |
| `iC`   | @call.inner        | Call arguments                       |
| `aC`   | @call.outer        | Whole function call                  |
| `ib`   | @block.inner       | Block body                           |
| `ab`   | @block.outer       | Whole block                          |
| `i?`   | @conditional.inner | if/else body                         |
| `a?`   | @conditional.outer | Whole if/else                        |
| `il`   | @loop.inner        | Loop body                            |
| `al`   | @loop.outer        | Whole loop                           |
| `i/`   | @comment.inner     | Comment text                         |
| `a/`   | @comment.outer     | Whole comment                        |
| `ir`   | @return.inner      | Return value                         |
| `ar`   | @return.outer      | Whole return statement               |
| `i=`   | @assignment.inner  | Right-hand side of assignment        |
| `a=`   | @assignment.outer  | Whole assignment                     |

> `lookahead = true` — if cursor is before an object, captures the nearest next one.

### Move (n, x, o)

| Key  | Action                          |
|------|---------------------------------|
| `]f` | Next function start             |
| `[f` | Previous function start         |
| `]F` | Next function end               |
| `[F` | Previous function end           |
| `]c` | Next class                      |
| `[c` | Previous class                  |
| `]l` | Next loop                       |
| `[l` | Previous loop                   |
| `]?` | Next conditional                |
| `[?` | Previous conditional            |

> `set_jumps = true` — jumps are added to the jumplist (`<C-o>`/`<C-i>`).

### Swap (n)

| Key     | Action                              |
|---------|-------------------------------------|
| `<A-l>` | Swap parameter with the next one    |
| `<A-h>` | Swap parameter with the previous one|

---

## nvim-various-textobjs

All default keymaps enabled. Only `n` (nearEoL) is disabled — conflicts with vim search-next.

| Key        | Textobject             | Description                                      |
|------------|------------------------|--------------------------------------------------|
| `ii/ai/aI` | indentation            | Surrounding lines with same or higher indentation|
| `R`        | restOfIndentation      | Lines downwards with same or higher indentation  |
| `ig/ag`    | greedyOuterIndentation | Outer indentation expanded to blank lines        |
| `iS/aS`    | subword                | camelCase / snake_case / kebab-case segment      |
| `C`        | toNextClosingBracket   | From cursor to next `]`, `)`, or `}`            |
| `io/ao`    | anyBracket             | Any `()`, `[]`, or `{}` on one line              |
| `iq/aq`    | anyQuote               | Any `"`, `'`, or `` ` `` on one line            |
| `Q`        | toNextQuotationMark    | From cursor to next quotation mark               |
| `r`        | restOfParagraph        | Rest of paragraph (like `}` but linewise)        |
| `gG`       | entireBuffer           | Entire buffer                                    |
| `i_/a_`    | lineCharacterwise      | Current line characterwise                       |
| `\|`       | column                 | Column down until indent or shorter line         |
| `iv/av`    | value                  | Value of key-value pair / right side             |
| `ik/ak`    | key                    | Key of key-value pair / left side                |
| `L`        | url                    | HTTP/HTTPS link                                  |
| `in/an`    | number                 | Number (inner: digits only, outer: with sign)    |
| `!`        | diagnostic             | nvim diagnostic                                  |
| `iz/az`    | closedFold             | Closed fold                                      |
| `im/am`    | chainMember            | Chain member like `foo.bar.baz`                  |
| `gw`       | visibleInWindow        | All lines visible in current window              |
| `gW`       | restOfWindow           | From cursor to last line in window               |
| `g;`       | lastChange             | Last change, yank, or paste                      |
| `iN/aN`    | notebookCell           | Jupyter cell (`# %%`)                            |
| `.`        | emoji                  | Single emoji or Nerdfont glyph                   |
| `i,/a,`    | argument               | Comma-separated argument                         |
| `iF/aF`    | filepath               | UNIX filepath (inner: filename only)             |
| `i#/a#`    | color                  | HEX / RGB / HSL / ANSI color                     |
| `iD/aD`    | doubleSquareBrackets   | Text enclosed by `[[]]`                          |
