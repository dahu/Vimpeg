" Parser compiled on Tue 07 Feb 2012 08:17:21 AM CST,
" with VimPEG v0.2 and VimPEG Compiler v0.1
" from "csv.vimpeg"
" with the following grammar:

" ; RFC4180 Compliant CSV Parser
" ; Vimpeg Example Grammar
" ; Barry Arthur, 2011 10 24
" ; Adapted from ANTLR grammar by Nathaniel Harward <nharward@gmail.com>
" ;   as found on http://www.antlr.org/grammar/list
" 
" .skip_white = false
" .namespace = 'csv_parser'
" .parser_name = 'csv#parser'
" .root_element = 'file'
" 
" file         ::=  record (newline record)* eof  -> #file
" record       ::=  (q_field | uq_field) ( s* comma (q_field | uq_field))*  ->  #record
" q_field      ::=  s* dq ( (char | comma | dqdq | newline))* dq  -> #q_field
" uq_field     ::=  s* char*  -> #uq_field
" char         ::=  !(newline | dq | s* comma) '.'  -> #char
" comma        ::=  ','
" dqdq         ::=  dq dq  -> #dqdq
" dq           ::=  '"'
" newline      ::=  ('\%x0d'? '\%x0a') | '\%x0d'  -> #newline
" s            ::=  '\s'
" eof          ::=  '$'

let s:p = vimpeg#parser({'root_element': 'file', 'skip_white': 0, 'parser_name': 'csv#parser', 'namespace': 'csv_parser'})
call s:p.and(['record', s:p.maybe_many(s:p.and(['newline', 'record'])), 'eof'],
      \{'id': 'file', 'on_match': 'csv_parser#file'})
call s:p.and([s:p.or(['q_field', 'uq_field']), s:p.maybe_many(s:p.and([s:p.maybe_many('s'), 'comma', s:p.or(['q_field', 'uq_field'])]))],
      \{'id': 'record', 'on_match': 'csv_parser#record'})
call s:p.and([s:p.maybe_many('s'), 'dq', s:p.maybe_many(s:p.or(['char', 'comma', 'dqdq', 'newline'])), 'dq'],
      \{'id': 'q_field', 'on_match': 'csv_parser#q_field'})
call s:p.and([s:p.maybe_many('s'), s:p.maybe_many('char')],
      \{'id': 'uq_field', 'on_match': 'csv_parser#uq_field'})
call s:p.and([s:p.not_has(s:p.or(['newline', 'dq', s:p.and([s:p.maybe_many('s'), 'comma'])])), s:p.e('.')],
      \{'id': 'char', 'on_match': 'csv_parser#char'})
call s:p.e(',',
      \{'id': 'comma'})
call s:p.and(['dq', 'dq'],
      \{'id': 'dqdq', 'on_match': 'csv_parser#dqdq'})
call s:p.e('"',
      \{'id': 'dq'})
call s:p.or([s:p.and([s:p.maybe_one(s:p.e('\%x0d')), s:p.e('\%x0a')]), s:p.e('\%x0d')],
      \{'id': 'newline', 'on_match': 'csv_parser#newline'})
call s:p.e('\s',
      \{'id': 's'})
call s:p.e('$',
      \{'id': 'eof'})

let g:csv#parser = s:p.GetSym('file')
