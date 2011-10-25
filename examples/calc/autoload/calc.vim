" Parser compiled on Tue Oct 25 03:01:12 2011,
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
" <calc>   ::=  <add> | <sub> | <prod>
" <add>    ::=  <prod> '+' <calc>       ->  #callback.add
" <sub>    ::=  <prod> '-' <calc>       ->  #callback.sub
" <prod>   ::=  <mul> | <div> | <atom>
" <mul>    ::=  <atom> '\*' <prod>      ->  #callback.mul
" <div>    ::=  <atom> '\/' <prod>      ->  #callback.div
" <ncalc>  ::=  '(' <calc> ')'          ->  #callback.nCalc
" <atom>   ::=  <num> | <ncalc>
" <num>    ::=  '\d\+'                  ->  #callback.num

let s:p = vimpeg#parser({'root_element': 'calc', 'skip_white': 1, 'parser_name': 'calc#parser', 'namespace': 'calculator'})
call s:p.or(['add', 'sub', 'prod'],
      \{'id': 'calc'})
call s:p.and(['prod', s:p.e('+'), 'calc'],
      \{'id': 'add', 'on_match': 'calculator#callback.add'})
call s:p.and(['prod', s:p.e('-'), 'calc'],
      \{'id': 'sub', 'on_match': 'calculator#callback.sub'})
call s:p.or(['mul', 'div', 'atom'],
      \{'id': 'prod'})
call s:p.and(['atom', s:p.e('\*'), 'prod'],
      \{'id': 'mul', 'on_match': 'calculator#callback.mul'})
call s:p.and(['atom', s:p.e('\/'), 'prod'],
      \{'id': 'div', 'on_match': 'calculator#callback.div'})
call s:p.and([s:p.e('('), 'calc', s:p.e(')')],
      \{'id': 'ncalc', 'on_match': 'calculator#callback.nCalc'})
call s:p.or(['num', 'ncalc'],
      \{'id': 'atom'})
call s:p.e('\d\+',
      \{'id': 'num', 'on_match': 'calculator#callback.num'})

let g:calc#parser = s:p.GetSym('calc')
