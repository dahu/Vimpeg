" Assignment Expression PEG
" Barry Arthur, Jun 2011

let p = vimpeg#parser({'skip_white': 1})

"Grammar for Jack Crenshaw's Assignment Expression Parser (Part 3):
  "<assignment>  ::=  <name> = <expression>
  "<expression>  ::=  <term> ( <add> | <subtract> )*
  "<subtract>    ::=  '-' <term>
  "<add>         ::=  '+' <term>
  "<term>        ::=  <factor> ( <multiply> | <divide> )*
  "<divide>      ::=  '/' <factor>
  "<multiply>    ::=  '*' <factor>
  "<factor>      ::=  <number> | '(' <expression> ')' | <ident>
  "<ident>       ::=  <func> | <name>
  "<func>        ::=  <name> '(' ')'
  "<name>        ::=  <alpha> <alphanum>*
  "<alpha>       ::=  [a-zA-Z_]
  "<alphanum>    ::=  <alpha> | <digit>
  "<number>      ::=  <digit>+
  "<digit>       ::=  [0-9]

let ass = p.and(['name', p.e('='), 'expression'],                               {'id': 'assignment', 'on_match': 'Assignment'})
call      p.and(['term', p.maybe_many(p.or(['add', 'subtract']))],              {'id': 'expression', 'on_match': 'Expression'})
call      p.and([p.e('-'), 'term'],                                             {'id': 'subtract',   'on_match': 'Op'})
call      p.and([p.e('+'), 'term'],                                             {'id': 'add',        'on_match': 'Op'})
call      p.and(['factor', p.maybe_many(p.or(['multiply', 'divide']))],         {'id': 'term',       'on_match': 'Term'})
call      p.and([p.e('/'), 'factor'],                                           {'id': 'divide',     'on_match': 'Op'})
call      p.and([p.e('*'), 'factor'],                                           {'id': 'multiply',   'on_match': 'Op'})
call       p.or(['number', p.and([p.e('('), 'expression', p.e(')')]), 'ident'], {'id': 'factor',     'on_match': 'Factor'})
call       p.or(['func', 'name'],                                               {'id': 'ident',      'on_match': 'Ident'})
call      p.and(['name', p.and([p.e('('), p.e(')')])],                          {'id': 'func',       'on_match': 'Func'})
call      p.and(['alpha', p.maybe_many('alphanum')],                            {'id': 'name',       'on_match': 'Name'})
call        p.e('[a-zA-Z_]',                                                    {'id': 'alpha'})
call       p.or(['alpha', 'digit'],                                             {'id': 'alphanum'})
call     p.many('digit',                                                        {'id': 'number',     'on_match': 'Number'})
call        p.e('[0-9]',                                                        {'id': 'digit'})

func! Assignment(elems)
  "echo 'Assignment='.string(a:elems)
  return "let " . a:elems[0] . ' = ' . a:elems[2]
endfunc
func! Expression(elems)
  "echo 'Expression='.string(a:elems)
  return Flatten(a:elems)
endfunc
func! Factor(elems)
  "echo 'Factor='.string(a:elems)
  return Flatten(a:elems)
endfunc
func! Op(elems)
  return Flatten(a:elems)
endfunc
func! Term(elems)
  "echo 'Term='.string(a:elems)
  return Flatten(a:elems)
endfunc
func! Ident(elems)
  "echo 'Ident='.string(a:elems)
  return a:elems
endfunc
func! Func(elems)
  "echo 'Func='.string(a:elems)
  return Flatten(a:elems)
endfunc
func! Name(elems)
  "echo 'Name='.string(a:elems)
  return Flatten(a:elems)
endfunc
func! Number(elems)
  return Flatten(a:elems)
endfunc

function! Flatten(array)
  if type(a:array) == type([])
    return join(map(a:array, 'Flatten(v:val)'), '')
  elseif type(a:array) == type(0)
    return '' . a:array
  elseif type(a:array) == type("")
    return a:array
  endif
endfunction

" Toggle the return options here to variously see the entire match object, or
" the evaluated result (the 'value').
func! Ass(expr)
  return string(g:ass.match(a:expr)['value'])
endfunc

" client side
echo 'let x = 45'           . '==' . Ass('x = 45')
echo 'let x = 45 - 101'           . '==' . Ass('x = 45 - 101')
echo 'let x = 45 + 99'      . '==' . Ass('x = 45 + 99')
echo 'let x = 15 - 101'     . '==' . Ass('x = 15 - 101')
echo 'let x = 234 * 3'      . '==' . Ass('x = 234 * 3')
echo 'let x = 1023 / 2'     . '==' . Ass('x = 1023 / 2')
echo 'let x = (1023 / 2) + 7'     . '==' . Ass('x = (1023 / 2) + 7')
echo 'let x = ((1023 / 2) * 9) + (7 - 2)'     . '==' . Ass('x = ((1023 / 2) * 9) + (7 - 2)')

echo 'let x = a / 2'        . '==' . Ass('x = a / 2')
echo 'let x = abc / 2'      . '==' . Ass('x = abc / 2')
echo 'let x = apple() / 2'  . '==' . Ass('x = apple() / 2')
