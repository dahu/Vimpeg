" Parser compiled on Tue 31 Jul 2012 03:57:53 PM CST,
" with VimPEG v0.2 and VimPEG Compiler v0.1
" from "calc.vimpeg"
" with the following grammar:

" ; Simple Calculator
" ; Vimpeg Example Grammar
" ; Barry Arthur, 2011 10 24
" 
" .skip_white = true
" .namespace = 'calculator'
" .parser_name = 'calc#parser'
" .root_element = 'calc'
" 
" calc   ::=  add | sub | prod
" add    ::=  prod '+' calc       ->  #add
" sub    ::=  prod '-' calc       ->  #sub
" prod   ::=  mul | div | atom
" mul    ::=  atom '\*' prod      ->  #mul
" div    ::=  atom '\/' prod      ->  #div
" ncalc  ::=  '(' calc ')'        ->  #nCalc
" atom   ::=  num | ncalc
" num    ::=  '\d\+'              ->  #num

let s:p = vimpeg#parser({'root_element': 'calc', 'skip_white': 1, 'parser_name': 'calc#parser', 'namespace': 'calculator'})
call s:p.or(['add', 'sub', 'prod'],
      \{'id': 'calc'})
call s:p.and(['prod', s:p.e('+'), 'calc'],
      \{'id': 'add', 'on_match': 'calculator#add'})
call s:p.and(['prod', s:p.e('-'), 'calc'],
      \{'id': 'sub', 'on_match': 'calculator#sub'})
call s:p.or(['mul', 'div', 'atom'],
      \{'id': 'prod'})
call s:p.and(['atom', s:p.e('\*'), 'prod'],
      \{'id': 'mul', 'on_match': 'calculator#mul'})
call s:p.and(['atom', s:p.e('\/'), 'prod'],
      \{'id': 'div', 'on_match': 'calculator#div'})
call s:p.and([s:p.e('('), 'calc', s:p.e(')')],
      \{'id': 'ncalc', 'on_match': 'calculator#nCalc'})
call s:p.or(['num', 'ncalc'],
      \{'id': 'atom'})
call s:p.e('\d\+',
      \{'id': 'num', 'on_match': 'calculator#num'})

let g:calc#parser = s:p.GetSym('calc')
