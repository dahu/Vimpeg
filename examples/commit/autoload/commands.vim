" Parser compiled on Sun 02 Nov 2014 14:34:46 CST,
" with VimPEG v0.2 and VimPEG Compiler v0.1
" from "commands.vimpeg"
" with the following grammar:

" ; Simple Commit Example
" ; Vimpeg Example Grammar
" ; Barry Arthur, 2014 11 2
" 
" .skip_white = true
" .namespace = 'commands_parser'
" .parser_name = 'commands#parser'
" .root_element = 'commands'
" 
" commands ::= show | set
" set      ::= 'set' (sym (('=' . (val | sym)) | '!')?)? -> #set
" show     ::= 'show' sym?                     -> #show
" sym      ::= '\h\w*'
" val      ::= '\d\+'

let s:p = vimpeg#parser({'root_element': 'commands', 'skip_white': 1, 'parser_name': 'commands#parser', 'namespace': 'commands_parser'})
call s:p.or(['show', 'set'],
      \{'id': 'commands'})
call s:p.and([s:p.e('set'), s:p.maybe_one(s:p.and(['sym', s:p.maybe_one(s:p.or([s:p.and([s:p.e('='), s:p.commit(s:p.or(['val', 'sym']))]), s:p.e('!')]))]))],
      \{'id': 'set', 'on_match': 'commands_parser#set'})
call s:p.and([s:p.e('show'), s:p.maybe_one('sym')],
      \{'id': 'show', 'on_match': 'commands_parser#show'})
call s:p.e('\h\w*',
      \{'id': 'sym'})
call s:p.e('\d\+',
      \{'id': 'val'})

let g:commands#parser = s:p.GetSym('commands')
function! commands#parse(input)
  if type(a:input) != type('')
    echohl ErrorMsg
    echom 'VimPEG: Input must be a string.'
    echohl NONE
    return []
  endif
  return g:commands#parser.match(a:input)
endfunction
function! commands#parser()
  return deepcopy(g:commands#parser)
endfunction
