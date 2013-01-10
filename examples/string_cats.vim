" Vimpeg matcher for +-catenated double-quoted strings
" Barry Arthur,  10 Jan 2012

" This file is logically separated into 3 main parts:
" 1. the vimpeg parsing code and callbacks for handling separated
" double-quoted strings.
" 2. the client library for handling line readers and writers - determining
" where the separated strings start in the given context and what operations
" are typically performed on them.
" 3. the actual client area, representing the end user and how they would use
" the client library.
"
" These pieces are shown here as an example of how to logically separate these
" concerns rather than serving as exhaustive implementations of the same.
"
" Typically, each of these three pieces would reside in separate files /
" plugins.

" 1. vimpeg parser definition and callbacks

" builder for given 'sep' separated double-quoted strings

let s:string_cats = {}
function! StringCatBuilder(sep)
  if !has_key(s:string_cats, a:sep)
    let p = vimpeg#parser({'skip_white': 0})
    call p.and(['dqstr', p.maybe_many(p.and([p.e('\s*' . escape(a:sep, '.*^${}[]\') . '\s*'), 'dqstr']))],
          \{'id': 'strcat', 'on_match': 'StrCat'})
    call p.and([p.e('"'), p.maybe_many(p.or([p.e('\\"'), p.and([p.not_has(p.e('"')), p.e('.')])])), p.e('"')],
          \{'id': 'dqstr', 'on_match': 'DQStr'})
    let s:string_cats[a:sep] = p
  endif
  return s:string_cats[a:sep]
endfunction

" callbacks

function! StrCat(elems)
  let res = [a:elems[0]]
  call extend(res, map(a:elems[1], 'v:val[1]'))
  return res
endfunction

function! DQStr(elems)
  let res = join(map(a:elems[1], 'v:val[1]'), '')
  return res
endfunction

" 2. client library (handling '+' separated strings)

function! Strings(expr)
  return map(StringCatBuilder('+').Symbols['strcat'].match(a:expr)['value'], 'escape(v:val, "\"")')
endfunction

function! GetStrings(line)
  return Strings(substitute(a:line, '^.*=\s*', '', ''))
endfunction

function! JoinStrings(line, sep)
  return '["' . join(GetStrings(a:line), '", "') . '"].join("' . escape(a:sep, '"') . '")'
endfunction

function! LineStrings()
  return GetStrings(getline('.'))
endfunction

nnoremap <leader>x :call setline('.', JoinStrings(getline('.'), ' '))<cr>

" 3. client (for +-sep strings)

echo Strings('"xyz"')
echo Strings('"xyz" + "abc"')
echo Strings('"xyz" + "abc" + "ijk"')
echo Strings('"h\"i\"+a"+"b"+"c"+"d+e"')
echo GetStrings('var foo = "h\"i\"+a"+"b"+"c"+"d+e"')
echo '[' . join(GetStrings('var foo = "h\"i\"+a"+"b"+"c"+"d+e"'), ', ') . '].join(" ")'
echo JoinStrings('var foo = "h\"i\"+a"+"b"+"c"+"d+e"', ' ')


" 2B. another example client library (this time for handling '.' separated strings)

function! Strings(expr)
  return map(StringCatBuilder('.').Symbols['strcat'].match(a:expr)['value'], 'escape(v:val, "\"")')
endfunction

nnoremap <leader>x :call setline('.', JoinStrings(getline('.'), ' '))<cr>
echo "Now go to the last line in the file and type   <leader>x"

finish

" example strings for <leader>x map (NOTE: this won't work for +-sep strings
" with the .-sep version activated above.

var foo = "hi+a"+"b"+"c"+"d+e"
var foo = "h\"i\"+a"+"b"+"c"+"d+e"

let foo = "hi+a" . "b" . "c" . "d+e"
