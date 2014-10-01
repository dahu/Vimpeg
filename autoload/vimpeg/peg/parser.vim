" Parser compiled on Wed Oct  1 12:55:53 2014,
" with VimPEG v0.2 and VimPEG Compiler v0.1
" from "parser.vimpeg"
" with the following grammar:

" ; Original PEG syntax {{{
" ; # Hierarchical syntax
" ; Grammar <- Spacing Definition+ EndOfFile
" ; Definition <- Identifier LEFTARROW Expression
" ; Expression <- Sequence (SLASH Sequence)*
" ; Sequence <- Prefix*
" ; Prefix <- (AND / NOT)? Suffix
" ; Suffix <- Primary (QUESTION / STAR / PLUS)?
" ; Primary <- Identifier !LEFTARROW / OPEN Expression CLOSE / Literal / Class / DOT
" ; # Lexical syntax
" ; Identifier <- IdentStart IdentCont* Spacing
" ; IdentStart <- [a-zA-Z_]
" ; IdentCont <- IdentStart / [0-9]
" ; Literal <- [’] (![’] Char)* [’] Spacing / ["] (!["] Char)* ["] Spacing
" ; Class <- ’[’ (!’]’ Range)* ’]’ Spacing
" ; Range <- Char ’-’ Char / Char
" ; Char <- ’\\’ [nrt’"\[\]\\] / ’\\’ [0-2][0-7][0-7] / ’\\’ [0-7][0-7]?  / !’\\’ .
" ; LEFTARROW <- ’<-’ Spacing
" ; SLASH <- ’/’ Spacing
" ; AND <- ’&’ Spacing
" ; NOT <- ’!’ Spacing
" ; QUESTION <- ’?’ Spacing
" ; STAR <- ’*’ Spacing
" ; PLUS <- ’+’ Spacing
" ; OPEN <- ’(’ Spacing
" ; CLOSE <- ’)’ Spacing
" ; DOT <- ’.’ Spacing
" ; Spacing <- (Space / Comment)*
" ; Comment <- ’%’ (!EndOfLine .)* EndOfLine
" ; Space <- ’ ’ / ’\t’ / EndOfLine
" ; EndOfLine <- ’\r\n’ / ’\n’ / ’\r’
" ; EndOfFile <- !.
" ; }}}
" 
" ; VimPEG grammar
" .skip_white   = false
" .namespace    = 'vimpeg#peg'
" .parser_name  = 'parser'
" .root_element = 'line'
" .ignore_case  = false
" .debug        = false
" .verbose      = 0
" 
" line             ::= ( option | definition ) ? eol -> #line
" definition       ::= identifier mallet expression callback ? eol -> #definition
" expression       ::= sequence ( or sequence ) * -> #expression
" sequence         ::= prefix * -> #sequence
" prefix           ::= ( and | not ) ? suffix -> #prefix
" suffix           ::= primary ( question | star | plus ) ? -> #suffix
" primary          ::= identifier ! mallet | open expression close | regex -> #primary
" callback         ::= right_arrow '\%([a-zA-Z0-9_:.#]*\w\+\)\?' -> #callback
" option           ::= dot option_name equal option_value eol -> #option
" option_name      ::= identifier
" option_value     ::= squoted_string | squoted_string | number | boolean
" identifier       ::= '\h\w*' space -> #identifier
" regex            ::= dquoted_string | squoted_string -> #regex
" dquoted_string   ::= dquote ( double_backslash | escaped_dquote | '[^"]' ) * dquote space -> #dquoted_string
" squoted_string   ::= squote ( "[^']" | double_squote ) * squote space -> #squoted_string
" escaped_dquote   ::= backslash dquote
" double_backslash ::= backslash backslash
" backslash        ::= '\'
" number           ::= '\%(0\|[1-9]\d*\)\%(\.\d\+\)\?' space -> #first
" dquote           ::= '"'
" double_squote    ::= "''"
" squote           ::= "'"
" comment          ::= ';[^\n]*'
" right_arrow      ::= '->' space -> #first
" mallet           ::= '::=' space -> #first
" boolean          ::= true | false
" true             ::= 'true\|on' space -> #true
" false            ::= 'false\|off' space -> #false
" equal            ::= '=' space -> #first
" or               ::= '|' space -> #first
" and              ::= '&' space -> #first
" not              ::= '!' space -> #first
" question         ::= '?' space -> #first
" star             ::= '\*' space -> #first
" plus             ::= '+' space -> #first
" close            ::= ')' space -> #first
" open             ::= '(' space -> #first
" dot              ::= '\.'
" space            ::= '\%(\s\|\\\n\)*'
" eol              ::= comment ? '\n\|$' -> #eol

let s:p = vimpeg#parser({'root_element': 'line', 'skip_white': 0, 'ignore_case': 0, 'verbose': 0, 'parser_name': 'parser', 'namespace': 'vimpeg#peg', 'debug': 0})
call s:p.and([s:p.maybe_one(s:p.or(['option', 'definition'])), 'eol'],
      \{'id': 'line', 'on_match': 'vimpeg#peg#line'})
call s:p.and(['identifier', 'mallet', 'expression', s:p.maybe_one('callback'), 'eol'],
      \{'id': 'definition', 'on_match': 'vimpeg#peg#definition'})
call s:p.and(['sequence', s:p.maybe_many(s:p.and(['or', 'sequence']))],
      \{'id': 'expression', 'on_match': 'vimpeg#peg#expression'})
call s:p.maybe_many('prefix',
      \{'id': 'sequence', 'on_match': 'vimpeg#peg#sequence'})
call s:p.and([s:p.maybe_one(s:p.or(['and', 'not'])), 'suffix'],
      \{'id': 'prefix', 'on_match': 'vimpeg#peg#prefix'})
call s:p.and(['primary', s:p.maybe_one(s:p.or(['question', 'star', 'plus']))],
      \{'id': 'suffix', 'on_match': 'vimpeg#peg#suffix'})
call s:p.or([s:p.and(['identifier', s:p.not_has('mallet')]), s:p.and(['open', 'expression', 'close']), 'regex'],
      \{'id': 'primary', 'on_match': 'vimpeg#peg#primary'})
call s:p.and(['right_arrow', s:p.e('\%([a-zA-Z0-9_:.#]*\w\+\)\?')],
      \{'id': 'callback', 'on_match': 'vimpeg#peg#callback'})
call s:p.and(['dot', 'option_name', 'equal', 'option_value', 'eol'],
      \{'id': 'option', 'on_match': 'vimpeg#peg#option'})
call s:p.and(['identifier'],
      \{'id': 'option_name'})
call s:p.or(['squoted_string', 'squoted_string', 'number', 'boolean'],
      \{'id': 'option_value'})
call s:p.and([s:p.e('\h\w*'), 'space'],
      \{'id': 'identifier', 'on_match': 'vimpeg#peg#identifier'})
call s:p.or(['dquoted_string', 'squoted_string'],
      \{'id': 'regex', 'on_match': 'vimpeg#peg#regex'})
call s:p.and(['dquote', s:p.maybe_many(s:p.or(['double_backslash', 'escaped_dquote', s:p.e('[^"]')])), 'dquote', 'space'],
      \{'id': 'dquoted_string', 'on_match': 'vimpeg#peg#dquoted_string'})
call s:p.and(['squote', s:p.maybe_many(s:p.or([s:p.e("[^']"), 'double_squote'])), 'squote', 'space'],
      \{'id': 'squoted_string', 'on_match': 'vimpeg#peg#squoted_string'})
call s:p.and(['backslash', 'dquote'],
      \{'id': 'escaped_dquote'})
call s:p.and(['backslash', 'backslash'],
      \{'id': 'double_backslash'})
call s:p.e('\',
      \{'id': 'backslash'})
call s:p.and([s:p.e('\%(0\|[1-9]\d*\)\%(\.\d\+\)\?'), 'space'],
      \{'id': 'number', 'on_match': 'vimpeg#peg#first'})
call s:p.e('"',
      \{'id': 'dquote'})
call s:p.e("''",
      \{'id': 'double_squote'})
call s:p.e("'",
      \{'id': 'squote'})
call s:p.e(';[^\n]*',
      \{'id': 'comment'})
call s:p.and([s:p.e('->'), 'space'],
      \{'id': 'right_arrow', 'on_match': 'vimpeg#peg#first'})
call s:p.and([s:p.e('::='), 'space'],
      \{'id': 'mallet', 'on_match': 'vimpeg#peg#first'})
call s:p.or(['true', 'false'],
      \{'id': 'boolean'})
call s:p.and([s:p.e('true\|on'), 'space'],
      \{'id': 'true', 'on_match': 'vimpeg#peg#true'})
call s:p.and([s:p.e('false\|off'), 'space'],
      \{'id': 'false', 'on_match': 'vimpeg#peg#false'})
call s:p.and([s:p.e('='), 'space'],
      \{'id': 'equal', 'on_match': 'vimpeg#peg#first'})
call s:p.and([s:p.e('|'), 'space'],
      \{'id': 'or', 'on_match': 'vimpeg#peg#first'})
call s:p.and([s:p.e('&'), 'space'],
      \{'id': 'and', 'on_match': 'vimpeg#peg#first'})
call s:p.and([s:p.e('!'), 'space'],
      \{'id': 'not', 'on_match': 'vimpeg#peg#first'})
call s:p.and([s:p.e('?'), 'space'],
      \{'id': 'question', 'on_match': 'vimpeg#peg#first'})
call s:p.and([s:p.e('\*'), 'space'],
      \{'id': 'star', 'on_match': 'vimpeg#peg#first'})
call s:p.and([s:p.e('+'), 'space'],
      \{'id': 'plus', 'on_match': 'vimpeg#peg#first'})
call s:p.and([s:p.e(')'), 'space'],
      \{'id': 'close', 'on_match': 'vimpeg#peg#first'})
call s:p.and([s:p.e('('), 'space'],
      \{'id': 'open', 'on_match': 'vimpeg#peg#first'})
call s:p.e('\.',
      \{'id': 'dot'})
call s:p.e('\%(\s\|\\\n\)*',
      \{'id': 'space'})
call s:p.and([s:p.maybe_one('comment'), s:p.e('\n\|$')],
      \{'id': 'eol', 'on_match': 'vimpeg#peg#eol'})

let g:vimpeg#peg#parser#parser = s:p.GetSym('line')
function! vimpeg#peg#parser#parse(in)
  return g:vimpeg#peg#parser#parser.match(a:in)
endfunction
function! vimpeg#peg#parser#parser()
  return deepcopy(g:vimpeg#peg#parser#parser)
endfunction
