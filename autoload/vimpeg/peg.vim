" Vim library file
" Description:	VimPEG Parser compiler.
" Maintainer:	%Maintainer% <%Email%>
" Version:	0.1
" Last Change:	Sat Oct 22 19:28:03 2011
" License:	Vim License (see :help license)
" Location:	autoload/vimpeg/peg.vim

if exists("g:loaded_vimpeg_peg")
"      \ || v:version < 700 || &compatible
  "finish
endif
let g:loaded_vimpeg_peg = 1

let vimpeg_peg_version = '0.1'

" Allow use of line continuation.
let s:save_cpo = &cpo
set cpo&vim

let s:p = vimpeg#parser({'skip_white': 1})

function! s:SID() abort
  return matchstr(expand('<sfile>'), '<SNR>\d\+_\zeSID$')
endfun

" Ideas {{{
" - For later, maybe create callback functions populated with vars
"   corresponding to each element? Check Definition(). Not sure if all vars
"   would be used, though.
" - Add support for double quoted strings.
" - Should VimPEG's function have the abort flag?
" }}}

" Original PEG syntax {{{
" # Hierarchical syntax
" Grammar <- Spacing Definition+ EndOfFile
" Definition <- Identifier LEFTARROW Expression
" Expression <- Sequence (SLASH Sequence)*
" Sequence <- Prefix*
" Prefix <- (AND / NOT)? Suffix
" Suffix <- Primary (QUESTION / STAR / PLUS)?
" Primary <- Identifier !LEFTARROW / OPEN Expression CLOSE / Literal / Class / DOT
" # Lexical syntax
" Identifier <- IdentStart IdentCont* Spacing
" IdentStart <- [a-zA-Z_]
" IdentCont <- IdentStart / [0-9]
" Literal <- [’] (![’] Char)* [’] Spacing / ["] (!["] Char)* ["] Spacing
" Class <- ’[’ (!’]’ Range)* ’]’ Spacing
" Range <- Char ’-’ Char / Char
" Char <- ’\\’ [nrt’"\[\]\\] / ’\\’ [0-2][0-7][0-7] / ’\\’ [0-7][0-7]?  / !’\\’ .
" LEFTARROW <- ’<-’ Spacing
" SLASH <- ’/’ Spacing
" AND <- ’&’ Spacing
" NOT <- ’!’ Spacing
" QUESTION <- ’?’ Spacing
" STAR <- ’*’ Spacing
" PLUS <- ’+’ Spacing
" OPEN <- ’(’ Spacing
" CLOSE <- ’)’ Spacing
" DOT <- ’.’ Spacing
" Spacing <- (Space / Comment)*
" Comment <- ’#’ (!EndOfLine .)* EndOfLine
" Space <- ’ ’ / ’\t’ / EndOfLine
" EndOfLine <- ’\r\n’ / ’\n’ / ’\r’
" EndOfFile <- !.
" }}}

" VimPEG syntax {{{
" <definition>       ::= <label> <mallet> <expression> <callback>?
" <expression>       ::= <sequence> ( <or> <sequence> )*
" <sequence>         ::= <prefix>*
" <prefix>           ::= <not>? <suffix>
" <suffix>           ::= <primary> ( <question> | <star> | <plus> )?
" <primary>          ::= <label> !<mallet> | <open> <expression> <close> | <regex>
" <callback>         ::= <right_arrow> <identifier>
" <label>            ::= <lt> <identifier> <gt>
" <identifier>       ::= <ident_start> <ident_cont>?
" <ident_cont>       ::= '\w\+'
" <ident_start>      ::= '\h'
" <regex>            ::= <dquoted_string> | <squoted_string>
" <dquoted_string>   ::= <dquote> ( <double_backslash> | <escaped_dquote> | '[^"]' )* <dquote>
" <squoted_string>   ::= <squote> ( "[^']" | <double_squote> )* <squote>
" <escaped_dquote>   ::= <backslash> <dquote>
" <double_backslash> ::= <backslash> <backslash>
" <backslash>        ::= '\'
" <dquote>           ::= '"'
" <double_squote>    ::= ''''''
" <squote>           ::= "'"
" <right_arrow>      ::= '->'
" <mallet>           ::= '::='
" <or>               ::= '|'
" <not>              ::= '!'
" <question>         ::= '?'
" <star>             ::= '\*'
" <plus>             ::= '+'
" <close>            ::= ')'
" <open>             ::= '('
" <gt>               ::= '>'
" <lt>               ::= '<'
" }}}

" Parser grammar {{{
"let vimpeg#peg#parser = s:p.and(['label', 'mallet', 'expression', s:p.maybe_one('callback')],
call s:p.and(['label', 'mallet', 'expression', s:p.maybe_one('callback')],
      \{'id': 'definition', 'on_match': s:SID().'Definition'})
call s:p.and(['sequence', s:p.maybe_many(s:p.and(['or', 'sequence']))],
      \{'id': 'expression', 'on_match': s:SID().'Expression'})
call s:p.maybe_many('prefix',
      \{'id': 'sequence', 'on_match': s:SID().'Sequence'})
call s:p.and([s:p.maybe_one('not'), 'suffix'],
      \{'id': 'prefix', 'on_match': s:SID().'Prefix'})
call s:p.and(['primary', s:p.maybe_one(s:p.or(['question', 'star', 'plus']))],
      \{'id': 'suffix', 'on_match': s:SID().'Suffix'})
call s:p.or([s:p.and(['label', s:p.not_has('mallet')]), s:p.and(['open', 'expression', 'close']), 'regex'],
      \{'id': 'primary', 'on_match': s:SID().'Primary'})
call s:p.and(['right_arrow', 'identifier'],
      \{'id': 'callback', 'on_match': s:SID().'Callback'})
call s:p.and(['lt', 'identifier', 'gt'],
      \{'id': 'label', 'on_match': s:SID().'Label'})
call s:p.and(['ident_start', s:p.maybe_one('ident_cont')],
      \{'id': 'identifier', 'on_match': s:SID().'Identifier'})
call s:p.e('\w\+',
      \{'id': 'ident_cont'})
call s:p.e('\h',
      \{'id': 'ident_start'})
call s:p.or(['squoted_string', 'dquoted_string'],
      \{'id': 'regex', 'on_match': s:SID().'Regex'})
call s:p.and(['dquote', s:p.maybe_many(s:p.or(['double_backslash', 'escaped_dquote', s:p.e('[^"]\+')])), 'dquote'],
      \{'id': 'dquoted_string', 'on_match': s:SID().'Dquoted_string'})
call s:p.and(['squote', s:p.maybe_many(s:p.or([s:p.e('[^'']\+'),'double_squote'])), 'squote'],
      \{'id': 'squoted_string', 'on_match': s:SID().'Squoted_string'})
call s:p.and(['backslash', 'dquote'],
      \{'id': 'escaped_dquote', 'on_match': s:SID().'Escaped_dquote'})
call s:p.and(['backslash', 'backslash'],
      \{'id': 'double_backslash', 'on_match': s:SID().'Double_backslash'})
call s:p.e('\',
      \{'id': 'backslash'})
call s:p.e('"',
      \{'id': 'dquote'})
call s:p.e("''",
      \{'id': 'double_squote'})
call s:p.e("'",
      \{'id': 'squote'})
call s:p.e('->',
      \{'id': 'right_arrow'})
call s:p.e('::=',
      \{'id': 'mallet'})
call s:p.e('|',
      \{'id': 'or'})
call s:p.e('!',
      \{'id': 'not'})
call s:p.e('?',
      \{'id': 'question'})
call s:p.e('\*',
      \{'id': 'star'})
call s:p.e('+',
      \{'id': 'plus'})
call s:p.e(')',
      \{'id': 'close'})
call s:p.e('(',
      \{'id': 'open'})
call s:p.e('>',
      \{'id': 'gt'})
call s:p.e('<',
      \{'id': 'lt'})
" }}}

" Callback functions {{{
function! s:Definition(elems) abort
  "echom string(a:elems)
  let label = a:elems[0]
  let mallet = a:elems[1]
  let expression = a:elems[2]
  let callback = len(a:elems[3]) > 0 ? a:elems[3][0] : ''
  let result = 'call '.expression[:-2].",\n        \\{'id': ".label.
        \(callback != '' ? ", 'on_match': ".string(callback) : '') . "})"
  "echom 'Definition: ' . result
  return result
endfunction
function! s:Expression(elems) abort
  "echom string(a:elems)
  if len(a:elems[1]) > 0
    "echom 1
    let result = 'p.or(['.a:elems[0]. ', '. join(map(copy(a:elems[1]), 'v:val[1]'), ', ').'])'
  else
    "echom 2
    let result = a:elems[0]
  endif
  "echom 'Expression: ' . result
  return result
endfunction
function! s:Sequence(elems) abort
  "echom string(a:elems)
  let sequence = a:elems
  if len(sequence) > 1
    let result = 'p.and(['.join(sequence, ', ').'])'
  else
    let result = sequence[0]
  endif
  "echom 'Sequence: ' . result
  return result
endfunction
function! s:Prefix(elems) abort
  "echom string(a:elems)
  let suffix = a:elems[1]
  if len(a:elems[0]) > 0
    let prefix = a:elems[0][0]
    let result = 'p.not_has('.suffix.')'
  else
    let result = suffix
  endif
  "echom 'Prefix: ' . result
  return result
endfunction
function! s:Suffix(elems) abort
  let primary = a:elems[0]
  if len(a:elems[1]) > 0
    let suffix = a:elems[1][0]
    let result = 'p.'.(suffix == '*' ? 'maybe_many' : (suffix == '+' ? 'many' : 'maybe_one')) . '('.primary.')'
  else
    let result = primary
  endif
  "echom 'Suffix: ' . result
  return result
endfunction
function! s:Primary(elems) abort
  "echom 'Primary: '.string(a:elems)
  let len = len(a:elems)
  if type(a:elems) == type('')
    let result = a:elems
  elseif len == 2
    let result = a:elems[0]
  else
    let result = a:elems[1]
  endif
  "echom 'Primary: ' . result
  return result
endfunction
function! s:Callback(elems) abort
  let callback = a:elems[1]
  "echom 'Callback: ' . callback
  return callback
endfunction
function! s:Label(elems) abort
  "echom string(a:elems)
  let result = "'".a:elems[1]."'"
  "echom 'Label: ' . result
  return result
endfunction
function! s:Identifier(elems) abort
  let id = a:elems[0] . join(a:elems[1], '')
  "echom 'Identifier: ' . id
  return id
endfunction
function! s:Regex(elems) abort
  "echom string(a:elems)
  let regex = 'p.e('.a:elems.')'
  "echom 'Regex: ' . regex
  return regex
endfunction
function! s:Dquoted_string(elems) abort
  "echom string(a:elems)
  let dquoted_string = a:elems[0].join(a:elems[1], '').a:elems[2]
  "echom 'Dquoted_string: ' . dquoted_string
  return dquoted_string
endfunction
function! s:Squoted_string(elems) abort
  "echom string(a:elems)
  let squoted_string = a:elems[0].join(a:elems[1], '').a:elems[2]
  "echom 'Squoted_string: ' . squoted_string
  return squoted_string
endfunction
function! s:Escaped_dquote(elems) abort
  "echom string(a:elems)
  let escaped_dquote = a:elems[0]
  "echom 'Escaped_dquote: ' . escaped_dquote
  return escaped_dquote
endfunction
function! s:Double_backslash(elems) abort
  "echom string(a:elems)
  let double_backslash = a:elems[0]
  "echom 'Double_backslash: ' . double_backslash
  return double_backslash
endfunction
function! s:Backslash(elems) abort
  "echom string(a:elems)
  let backslash = a:elems[0]
  "echom 'Backslash: ' . backslash
  return backslash
endfunction
function! s:Dquote(elems) abort
  "echom string(a:elems)
  let dquote = a:elems[0]
  "echom 'Dquote: ' . dquote
  return dquote
endfunction
function! s:Double_squote(elems) abort
  let double_squote = a:elems[0]
  "echom 'Double_squote: ' . double_squote
  return double_squote
endfunction
function! s:Squote(elems) abort
  let squote = a:elems[0]
  "echom 'Squote: ' . squote
  return squote
endfunction
function! s:Right_arrow(elems) abort
  let right_arrow = a:elems[0]
  "echom 'Right_arrow: ' . right_arrow
  return right_arrow
endfunction
function! s:Mallet(elems) abort
  let mallet = a:elems
  "echom 'Mallet: ' . mallet
  return mallet
endfunction
function! s:Or(elems) abort
  let or = a:elems[0]
  "echom 'Or: ' . or
  return or
endfunction
function! s:Not(elems) abort
  let not = a:elems[0]
  "echom 'Not: ' . not
  return not
endfunction
function! s:Question(elems) abort
  let question = a:elems[0]
  "echom 'Question: ' . question
  return question
endfunction
function! s:Star(elems) abort
  let star = a:elems[0]
  "echom 'Star: ' . star
  return star
endfunction
function! s:Plus(elems) abort
  let plus = a:elems[0]
  "echom 'Plus: ' . plus
  return plus
endfunction
function! s:Close(elems) abort
  let close = a:elems[0]
  "echom 'Close: ' . close
  return close
endfunction
function! s:Open(elems) abort
  let open = a:elems[0]
  "echom 'Open: ' . open
  return open
endfunction
function! s:Gt(elems) abort
  let gt = a:elems[0]
  "echom 'Gt: ' . gt
  return gt
endfunction
function! s:Lt(elems) abort
  let lt = a:elems[0]
  "echom 'Lt: ' . lt
  return lt
endfunction
" }}}
let vimpeg#peg#parser = s:p.GetSym('definition')
function! vimpeg#peg#parse(lines) abort
  " Get rid of comment marks, if any.
  let result = map(copy(a:lines), 'substitute(v:val, ''^"\s*'', "", "")')
  call map(result, 'g:vimpeg#peg#parser.match(v:val).value')
  let result = eval(substitute(string(result), '\n', "', '", 'g'))
  return result
endfunction

function! vimpeg#peg#writefile(bang, args) range abort
  let source_path = len(a:args) == 2 ? a:args[1] : expand('%')
  let parser_path = len(a:args) > 0 ? a:args[0] : expand('%:p:r:h').'.vim'
  let parser_name = fnamemodify(parser_path, ':p:t:r')

  " See if file exists
  if glob(parser_path) != '' && !a:bang
    echohl ErrorMsg
    echom 'The file "'.parser_path.'" already exists, add ! to overwrite it.'
    echohl None
    return 0
  endif

  " Get the source
  if source_path == expand('%')
    let lines = getline(a:firstline, a:lastline)
  else
    let lines = readfile(source_path)
  endif

  " Add comments marks if needed
  let peg_rules = map(copy(lines), 'v:val =~ ''^\s*"\s*'' ? v:val : ''" ''.v:val')
  let peg_commands = vimpeg#peg#parse(lines)
  let header = [
        \ '" Parser compiled on '.strftime('%c').',',
        \ '" with VimPEG v0.1 and VimPEG Compiler v'.g:vimpeg_peg_version.'',
        \ '" from "'.source_path.'"',
        \ '" with the following grammar:',
        \ ''
        \ ]
  let content =
        \ header +
        \ peg_rules +
        \ [''] +
        \ peg_commands
  return writefile(content, parser_path) + 1
endfunction

nore <leader><leader> :w<bar>so %<bar>echo join(vimpeg#peg#parse([getline('.')]), "\n")<CR>

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: et sw=2 fdm=marker
