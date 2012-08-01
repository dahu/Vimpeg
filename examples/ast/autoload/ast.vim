" Parser compiled on Wed 01 Aug 2012 02:22:06 PM CST,
" with VimPEG v0.2 and VimPEG Compiler v0.1
" from "ast.vimpeg"
" with the following grammar:

" ; AST Generation
" ; Vimpeg Example Grammar
" ; Barry Arthur, 2012 08 01
" 
" .skip_white = true
" .namespace = 'unicorns'
" .parser_name = 'rnu#parser'
" .root_element = 'rnu'
" 
" rnu     ::= command+
" command ::= cmd word* -> #command
" cmd     ::= print | normal | upper | lower | title | colour
" print   ::= 'P'
" normal  ::= 'N'
" upper   ::= 'U'
" lower   ::= 'L'
" title   ::= 'T'
" colour  ::= 'C' '\w\+'
" word    ::= (!cmd '\w\+') -> #word

let s:p = vimpeg#parser({'root_element': 'rnu', 'skip_white': 1, 'parser_name': 'rnu#parser', 'namespace': 'unicorns'})
call s:p.many('command',
      \{'id': 'rnu'})
call s:p.and(['cmd', s:p.maybe_many('word')],
      \{'id': 'command', 'on_match': 'unicorns#command'})
call s:p.or(['print', 'normal', 'upper', 'lower', 'title', 'colour'],
      \{'id': 'cmd'})
call s:p.e('P',
      \{'id': 'print'})
call s:p.e('N',
      \{'id': 'normal'})
call s:p.e('U',
      \{'id': 'upper'})
call s:p.e('L',
      \{'id': 'lower'})
call s:p.e('T',
      \{'id': 'title'})
call s:p.and([s:p.e('C'), s:p.e('\w\+')],
      \{'id': 'colour'})
call s:p.and([s:p.not_has('cmd'), s:p.e('\w\+')],
      \{'id': 'word', 'on_match': 'unicorns#word'})

let g:rnu#parser = s:p.GetSym('rnu')
