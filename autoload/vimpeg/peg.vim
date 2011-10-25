" Vim library file
" Description:	VimPEG Parser compiler.
" Maintainer:	Israel Chauca <israelchauca@gmail.com>
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
" Comment <- ’%’ (!EndOfLine .)* EndOfLine
" Space <- ’ ’ / ’\t’ / EndOfLine
" EndOfLine <- ’\r\n’ / ’\n’ / ’\r’
" EndOfFile <- !.
" }}}

" ; VimPEG grammar {{{
" .skip_white = true
" .skip_all = false
" .string_option = 'abc'
" .other_string_option = "def"
" .numeric_option = 3 ; a comment
" .float_option = 2.5
" <line>             ::= ( <option> | <definition> )? <comment>? -> Line
" <definition>       ::= <label> <mallet> <expression> <callback>? -> Definition
" <expression>       ::= <sequence> ( <or> <sequence> )* -> Expression
" <sequence>         ::= <prefix>* -> Sequence
" <prefix>           ::= <not>? <suffix> -> Prefix
" <suffix>           ::= <primary> ( <question> | <star> | <plus> )? -> Suffix
" <primary>          ::= <label> !<mallet> | <open> <expression> <close> | <regex> -> Primary
" <callback>         ::= <right_arrow> '\%([a-zA-Z0-9_:.#]*\w\+\)\?' -> Callback
" <option>           ::= <dot> <option_name> <equal> <option_value> -> Option
" <option_name>      ::= <identifier>
" <option_value>     ::= <squoted_string> | <squoted_string> | <number> | <boolean>
" <label>            ::= <lt> <identifier> <gt> -> Label
" <identifier>       ::= '\h\w*' -> Identifier
" <regex>            ::= <dquoted_string> | <squoted_string> -> Regex
" <dquoted_string>   ::= <dquote> ( <double_backslash> | <escaped_dquote> | '[^"]' )* <dquote> -> Dquoted_string
" <squoted_string>   ::= <squote> ( "[^']" | <double_squote> )* <squote> -> Squoted_string
" <escaped_dquote>   ::= <backslash> <dquote>
" <double_backslash> ::= <backslash> <backslash>
" <backslash>        ::= '\'
" <number>           ::= '\%(0\|[1-9]\d*\)\%(\.\d\+\)\?'
" <dquote>           ::= '"'
" <double_squote>    ::= "''"
" <squote>           ::= "'"
" <comment>          ::= ';.*$'
" <right_arrow>      ::= '->'
" <mallet>           ::= '::=' ; End of line
" <boolean>          ::= <true> | <false>
" <true>             ::= 'true\|on' -> True
" <false>            ::= 'false\|off' -> False
" <equal>            ::= '='
" <or>               ::= '|'
" <not>              ::= '!'
" <question>         ::= '?'
" <star>             ::= '\*'
" <plus>             ::= '+'
" <close>            ::= ')'
" <open>             ::= '('
" ; whole line
" <dot>              ::= '\.'
" <gt>               ::= '>'
" <lt>               ::= '<'
" ; }}}

" Parser building {{{
call s:p.and([s:p.maybe_one(s:p.or(['option', 'definition', 'empty_line'])), s:p.maybe_one('comment')],
      \{'id': 'line', 'on_match': s:SID().'Line'})
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
call s:p.and(['right_arrow', 'callback_identifier'],
      \{'id': 'callback', 'on_match': s:SID().'Callback'})
call s:p.and(['dot', 'option_name', 'equal', 'option_value', s:p.maybe_one('comment')],
      \{'id': 'option', 'on_match': s:SID().'Option'})
call s:p.and(['identifier'],
      \{'id': 'option_name'})
call s:p.or(['squoted_string', 'dquoted_string', 'boolean', 'number'],
      \{'id': 'option_value', 'on_match': s:SID().'Option_value'})
call s:p.and(['lt', 'identifier', 'gt'],
      \{'id': 'label', 'on_match': s:SID().'Label'})
call s:p.e('[[:alnum:]#._:]\+',
      \{'id': 'callback_identifier', 'on_match': s:SID().'Identifier'})
call s:p.e('\h\w*',
      \{'id': 'identifier', 'on_match': s:SID().'Identifier'})
call s:p.or(['dquoted_string', 'squoted_string'],
      \{'id': 'regex', 'on_match': s:SID().'Regex'})
call s:p.and(['dquote', s:p.maybe_many(s:p.or(['double_backslash', 'escaped_dquote', s:p.e('[^"]')])), 'dquote'],
      \{'id': 'dquoted_string', 'on_match': s:SID().'Dquoted_string'})
call s:p.and(['squote', s:p.maybe_many(s:p.or([s:p.e("[^']"), 'double_squote'])), 'squote'],
      \{'id': 'squoted_string', 'on_match': s:SID().'Squoted_string'})
call s:p.and(['backslash', 'dquote'],
      \{'id': 'escaped_dquote'})
call s:p.and(['backslash', 'backslash'],
      \{'id': 'double_backslash'})
call s:p.e('\',
      \{'id': 'backslash'})
call s:p.e('\%(0\|[1-9]\d*\)\%(\.\d\+\)\?',
      \{'id': 'number'})
call s:p.e('"',
      \{'id': 'dquote'})
call s:p.e('''''',
      \{'id': 'double_squote'})
call s:p.e("'",
      \{'id': 'squote'})
call s:p.e(';.*$',
      \{'id': 'comment', 'on_match': s:SID().'Comment'})
call s:p.e('^$',
      \{'id': 'empty_line'})
call s:p.e('->',
      \{'id': 'right_arrow'})
call s:p.e('::=',
      \{'id': 'mallet'})
call s:p.or(['true', 'false'],
      \{'id': 'boolean'})
call s:p.e('\ctrue\|on',
      \{'id': 'true', 'on_match': s:SID().'True'})
call s:p.e('\cfalse\|off',
      \{'id': 'false', 'on_match': s:SID().'False'})
call s:p.e('=',
      \{'id': 'equal'})
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
call s:p.e('\.',
      \{'id': 'dot'})
call s:p.e('>',
      \{'id': 'gt'})
call s:p.e('<',
      \{'id': 'lt'})
" }}}

" Callback functions {{{
function! s:Line(elems) abort "{{{
  "echom string(a:elems)
  if len(a:elems[0]) > 0
    let result = a:elems[0][0]
  else
    let result = ''
  endif
  "echom 'Line: ' . result
  return result
endfunction "}}}
function! s:Definition(elems) abort "{{{
  "echom 'Definition: ' . string(a:elems)
  let s:setting_options = 0
  " Definition
  let label = a:elems[0]
  if !exists('s:root_element')
    exec 'let s:root_element = '.label
  endif
  let mallet = a:elems[1]
  let expression = a:elems[2]
  "echom expression
  let expression = expression =~ '^''' ? 's:p.and(['.expression.']' : expression[:-2]
  let callback = len(a:elems[3]) > 0 ? a:elems[3][0] : ''
  let callback = (callback =~ '^#' ?
        \         get(s:parser_options, 'namespace', '') :
        \         '') .
        \ callback
  let result = 'call '.expression.",\n      \\{'id': ".label.
        \(callback != '' ? ", 'on_match': '".callback."'" : '')."})"
  "echom 'Definition: ' . result
  return result
endfunction "}}}
function! s:Expression(elems) abort "{{{
  "echom string(a:elems)
  if len(a:elems[1]) > 0
    let result = 's:p.or(['.a:elems[0]. ', '. join(map(copy(a:elems[1]), 'v:val[1]'), ', ').'])'
  else
    let result = a:elems[0]
  endif
  "echom 'Expression: ' . result
  return result
endfunction "}}}
function! s:Sequence(elems) abort "{{{
  "echom string(a:elems)
  let sequence = a:elems
  if len(sequence) > 1
    let result = 's:p.and(['.join(sequence, ', ').'])'
  else
    let result = sequence[0]
  endif
  "echom 'Sequence: ' . result
  return result
endfunction "}}}
function! s:Prefix(elems) abort "{{{
  "echom string(a:elems)
  let suffix = a:elems[1]
  if len(a:elems[0]) > 0
    let prefix = a:elems[0][0]
    let result = 's:p.not_has('.suffix.')'
  else
    let result = suffix
  endif
  "echom 'Prefix: ' . result
  return result
endfunction "}}}
function! s:Suffix(elems) abort "{{{
  "echom string(a:elems)
  let primary = a:elems[0]
  if len(a:elems[1]) > 0
    let suffix = a:elems[1][0]
    let result = 's:p.'.(suffix == '*' ? 'maybe_many' : (suffix == '+' ? 'many' : 'maybe_one')) . '('.primary.')'
  else
    let result = primary
  endif
  "echom 'Suffix: ' . result
  return result
endfunction "}}}
function! s:Primary(elems) abort "{{{
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
endfunction "}}}
function! s:Callback(elems) abort "{{{
  let callback = a:elems[1]
  "echom 'Callback: ' . callback
  return callback
endfunction "}}}
function! s:Option(elems) abort "{{{
  "echom string(a:elems)
  if exists('s:parser_options')
    if s:setting_options == 0
      echoerr 'All options must be declared before definitions.'
    endif
    exec 'let s:parser_options.'.a:elems[1][0].' = '.a:elems[3]
  endif
  "echom 'Option: let s:parser_options.'.a:elems[1][0].' = '.a:elems[3]
  return ''
endfunction "}}}
function! s:Label(elems) abort "{{{
  "echom string(a:elems)
  let result = "'".a:elems[1]."'"
  "echom 'Label: ' . result
  return result
endfunction "}}}
function! s:Identifier(elems) abort "{{{
  "echom string(a:elems)
  let id = a:elems
  "echom 'Identifier: ' . id
  return id
endfunction "}}}
function! s:Option_value(elems) abort "{{{
  "echom string(a:elems)
  "echom 'Option_value: '.string(a:elems)
  return a:elems
endfunction "}}}
function! s:Regex(elems) abort "{{{
  "echom string(a:elems)
  let regex = 's:p.e('.a:elems.')'
  "echom 'Regex: ' . regex
  return regex
endfunction "}}}
function! s:Dquoted_string(elems) abort "{{{
  "echom string(a:elems)
  let dquoted_string = a:elems[0].join(a:elems[1], '').a:elems[2]
  "echom 'Dquoted_string: ' . dquoted_string
  return dquoted_string
endfunction "}}}
function! s:Squoted_string(elems) abort "{{{
  "echom string(a:elems)
  let squoted_string = a:elems[0].join(a:elems[1], '').a:elems[2]
  "echom 'Squoted_string: ' . squoted_string
  return squoted_string
endfunction "}}}
function! s:Escaped_dquote(elems) abort "{{{
  "echom string(a:elems)
  let escaped_dquote = a:elems[0]
  "echom 'Escaped_dquote: ' . escaped_dquote
  return escaped_dquote
endfunction "}}}
function! s:Double_backslash(elems) abort "{{{
  "echom string(a:elems)
  let double_backslash = a:elems[0]
  "echom 'Double_backslash: ' . double_backslash
  return double_backslash
endfunction "}}}
function! s:Backslash(elems) abort "{{{
  "echom string(a:elems)
  let backslash = a:elems[0]
  "echom 'Backslash: ' . backslash
  return backslash
endfunction "}}}
function! s:Dquote(elems) abort "{{{
  "echom string(a:elems)
  let dquote = a:elems[0]
  "echom 'Dquote: ' . dquote
  return dquote
endfunction "}}}
function! s:Double_squote(elems) abort "{{{
  let double_squote = a:elems[0]
  "echom 'Double_squote: ' . double_squote
  return double_squote
endfunction "}}}
function! s:Squote(elems) abort "{{{
  let squote = a:elems[0]
  "echom 'Squote: ' . squote
  return squote
endfunction "}}}
function! s:Right_arrow(elems) abort "{{{
  let right_arrow = a:elems[0]
  "echom 'Right_arrow: ' . right_arrow
  return right_arrow
endfunction "}}}
function! s:Mallet(elems) abort "{{{
  let mallet = a:elems
  "echom 'Mallet: ' . mallet
  return mallet
endfunction "}}}
function! s:Boolean(elems) abort "{{{
  "echom string(a:elems)
  "echom 'Boolean: ' . string(a:elems)
  return a:elems
endfunction "}}}
function! s:Comment(elems) abort "{{{
  "echo 'Comment: -->' . string(a:elems) . '<--'
  "return '"'.a:elems
  return ''
endfunction "}}}
function! s:True(elems) abort "{{{
  "echom string(a:elems)
  "echom 'True: ' . string(a:elems)
  return 1
endfunction "}}}
function! s:False(elems) abort "{{{
  "echom string(a:elems)
  "echom 'False: ' . string(a:elems)
  return 0
endfunction "}}}
function! s:Or(elems) abort "{{{
  let or = a:elems[0]
  "echom 'Or: ' . or
  return or
endfunction "}}}
function! s:Not(elems) abort "{{{
  let not = a:elems[0]
  "echom 'Not: ' . not
  return not
endfunction "}}}
function! s:Question(elems) abort "{{{
  let question = a:elems[0]
  "echom 'Question: ' . question
  return question
endfunction "}}}
function! s:Star(elems) abort "{{{
  let star = a:elems[0]
  "echom 'Star: ' . star
  return star
endfunction "}}}
function! s:Plus(elems) abort "{{{
  let plus = a:elems[0]
  "echom 'Plus: ' . plus
  return plus
endfunction "}}}
function! s:Close(elems) abort "{{{
  let close = a:elems[0]
  "echom 'Close: ' . close
  return close
endfunction "}}}
function! s:Open(elems) abort "{{{
  let open = a:elems[0]
  "echom 'Open: ' . open
  return open
endfunction "}}}
function! s:Gt(elems) abort "{{{
  let gt = a:elems[0]
  "echom 'Gt: ' . gt
  return gt
endfunction "}}}
function! s:Lt(elems) abort "{{{
  let lt = a:elems[0]
  "echom 'Lt: ' . lt
  return lt
endfunction "}}}
" }}}

" Public interface {{{
let vimpeg#peg#parser = s:p.GetSym('line')

function! vimpeg#peg#parse(lines) abort
  let s:setting_options = 1
  " Get rid of comment marks, if any.
  "let result = map(copy(a:lines), 'substitute(v:val, ''^"\s*'', "", "")')
  " Parse the lines
  let result = map(filter(copy(a:lines), 'v:val != ""'), 'g:vimpeg#peg#parser.match(v:val).value')
  " Split at newlines
  let result = eval(substitute(string(result), '\n', "', '", 'g'))
  " Remove empty items
  call filter(result, 'v:val != ""')
  return result
endfunction

" writefile(bang, [target, source]) range abort
"   target : destination file for parser output
"   source : parser definition in PEG DSL format
"
function! vimpeg#peg#writefile(bang, args) range abort
  let parser_path = len(a:args) > 0 ? a:args[0] : expand('%:p:r:h').'.vim'

  " See if file exists
  if glob(parser_path) != '' && !a:bang
    echohl ErrorMsg
    echom 'The file "'.parser_path.'" already exists, add ! to overwrite it.'
    echohl None
    exec 'so '.parser_path
    return 0
  endif

  " Get the source
  let source_path = len(a:args) == 2 ? a:args[1] : expand('%')
  let s:parser_options = {}
  unlet! let s:root_element
  if source_path == expand('%')
    let lines = getline(a:firstline, a:lastline)
  else
    let lines = readfile(source_path)
  endif

  " Add comment marks if needed
  let peg_rules = map(copy(lines), 'v:val =~ ''^\s*"\s*'' ? v:val : ''" ''.v:val')
  let peg_commands = vimpeg#peg#parse(lines)
  let parser_name = get(s:parser_options, 'parser_name', fnamemodify(source_path, ':p:t:r'))
  let root_element = get(s:parser_options, 'root_element', s:root_element)
  let content = [
        \ '" Parser compiled on '.strftime('%c').',',
        \ '" with VimPEG v'.g:vimpeg_version.' and VimPEG Compiler v'.g:vimpeg_peg_version.'',
        \ '" from "'.fnamemodify(source_path, ':p:t').'"',
        \ '" with the following grammar:',
        \ ''
        \ ] +
        \ peg_rules +
        \ ['',
        \ 'let s:p = vimpeg#parser('. string(s:parser_options).')'] +
        \ peg_commands +
        \ ['',
        \ 'let g:'.parser_name.' = s:p.GetSym('''.root_element.''')']

  let result =  writefile(content, parser_path) + 1
  echohl WarningMsg
  echom 'The parser was built into "'.parser_path.'".'
  echohl None
  exec 'so '.parser_path
  echohl WarningMsg
  echom 'The parser was loaded.'
  echohl None
  return result
endfunction
" }}}

nore <leader><leader> :w<bar>so %<bar>echo join(vimpeg#peg#parse(map(getline('.', '.'), 'substitute(v:val, ''^"\s*'', "", "")')), "\n")<CR>

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: et sw=2 fdm=marker
