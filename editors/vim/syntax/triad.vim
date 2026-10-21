" Vim/Neovim syntax per il linguaggio Triad.
" Installazione: copia editors/vim/* in ~/.vim/ (o in un package di Neovim).

if exists("b:current_syntax")
  finish
endif

syn keyword triadKeyword function struct macro end if elseif else for in while let
      \ begin return break continue fact rule solve quote try catch with requires ensures
syn keyword triadBoolean true false
syn keyword triadNil nothing
syn keyword triadWordOperator isa is not
syn keyword triadSolveOption limit depth steps trace

syn match triadRuleOperator ":-"
syn match triadComment "#.*$" contains=@Spell
syn region triadBlockComment start="#=" end"=#"

syn region triadString start=+"+ skip=+\\\\\|\\"+ end=+"+
      \ contains=triadEscape,triadInterpolation
syn match triadEscape "\\[nt\"\\$]" contained
syn match triadInterpolation "\$[A-Za-z_][A-Za-z0-9_]*" contained
syn match triadInterpolation "\$(" contained

syn match triadLogicalVar "\?[A-Za-z_][A-Za-z0-9_]*"
syn match triadSymbol ":[A-Za-z_][A-Za-z0-9_!]*"
syn match triadSymbolOperator ":[+*/%^<>=!]\+"
syn match triadMacro "@[A-Za-z_][A-Za-z0-9_]*"
syn match triadNumber "\<\d[\d_]*\%(\.\d[\d_]*\)\?\%([eE][+-]\?\d\+\)\?\>"
syn keyword triadType Int Float Number Bool String Symbol Any Nothing Function Expr
      \ List Term LVar Solution Err Type
syn match triadTypeName "\<[A-Z][A-Za-z0-9_]*\>"
syn match triadFunction "\<\%(function\|macro\)\s\+\zs[A-Za-z_][A-Za-z0-9_!]*"
syn match triadOperator "==\|!=\|<=\|>=\|&&\|||\|->\|+=\|-=\|\*="
syn match triadOperator "[-+*/%^<>=!$?]"

hi def link triadKeyword Keyword
hi def link triadBoolean Boolean
hi def link triadNil Constant
hi def link triadWordOperator Operator
hi def link triadSolveOption Keyword
hi def link triadRuleOperator Keyword
hi def link triadComment Comment
hi def link triadBlockComment Comment
hi def link triadString String
hi def link triadEscape SpecialChar
hi def link triadInterpolation Special
hi def link triadLogicalVar Identifier
hi def link triadSymbol Constant
hi def link triadSymbolOperator Constant
hi def link triadMacro Function
hi def link triadNumber Number
hi def link triadType Type
hi def link triadTypeName Type
hi def link triadFunction Function
hi def link triadOperator Operator

let b:current_syntax = "triad"
