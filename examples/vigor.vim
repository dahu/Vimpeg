so ../plugin/vimpeg.vim
let p = Vimpeg({'skip_white': 1})
let q = Vimpeg({'skip_white': 0})

" Like coffeescript for VimL

" vigor               := fdecl / fcall
" fdecl               := identifier '=' arguments '->' block
" identifier          := '\k\+'
" value               := '\k\+'
" arguments           := '(' arg_list ')'
" arg_list            := assignment (',' assignment)*
" assignment          := identifier ':' expression
" expression          := COMPLICATED - for now, use   value
" block               := '\n' indented_block / inline_block
" inline_block        := '.*$'
" indented_block      := indented_block_line+
" indented_block_line := '^\s\+' expression

" Example 1 : Inline block
" NOTE: Inline blocks don't work yet
" function! Min(a, b)
"   return a:a < a:b ? a:a : a:b
" endfunction
"
" Min = (a, b) -> return a < b ? a : b
"
" Example 2 : Indented block
" function! BackspaceIgnoreIndent()
"   if search('^\s\+\%#', 'bn') != 0
"     return "\<c-u>\<c-h>"
"   else
"     return "\<c-h>"
"   endif
" endfunction
"
" NOTE: At the moment, all blocks are still required to be valid VimL, so the
" following example with the end-less   if  is not yet possible.
"
" BackspaceIgnoreIndent = () ->
"   if search('^\s\+\%#', 'bn') != 0
"     return "\<c-u>\<c-h>"
"   else
"     return "\<c-h>"

call p.e('\k\+', {'id': 'value'})
call p.e('\k\+', {'id': 'ident'})
call p.and(['ident', p.maybe_one(p.and([p.e(':'), 'value']))], {'id': 'arg', 'on_match': 'Arg'})

" change this to allow argumentless functions
call p.and(['arg', p.maybe_many(p.and([p.e(','), 'arg']))], {'id': 'arglist', 'on_match': 'ArgList'})

call p.and([p.e('('), 'arglist', p.e(')')], {'id': 'args', 'on_match': 'Args'})

" q is the non-whitespace-skipping parser
call q.many(q.e('^  .\+'), {'id': 'fbody', 'on_match': 'FBody'})
call p.AddSym(q.GetSym('fbody'))

call p.and(['ident', p.e('='), 'args', p.e('->\n'), 'fbody'], {'id': 'fdecl', 'on_match': 'FDecl'})
call p.and(['ident', 'args'], {'id': 'fcall', 'on_match': 'FCall'})
let vigor = p.or(['fdecl', 'fcall'], {'id': 'vfunc', 'on_match': 'VFunc'})

" callbacks on successful match of element (grammar provider library side)

func! Arg(elems)
  "echo "elems: " . string(a:elems)
  let assignment = {}
  if len(a:elems[1]) > 0
    let assignment[a:elems[0][0]] = a:elems[1][0][1][0]
  endif
  return a:elems[0] + [assignment]
endfunc

func! ArgList(elems)
  let arglist = [a:elems[0][0][0]]
  let letlist = [a:elems[0][0][1]]
  call extend(arglist, map(copy(a:elems[1]), 'v:val[1][0][0]'))
  call extend(letlist, map(copy(a:elems[1]), 'v:val[1][0][1]'))
  return [arglist] + [letlist]
endfunc

func! Args(elems)
  return a:elems[1][0]
endfunc

func! FDecl(elems)
  "echo "FDecl: " . string(a:elems)
  let name = a:elems[0][0]
  let args = a:elems[2][0][0]
  let lets = a:elems[2][0][1]
  let body = a:elems[4][0][0]
  "echo "name: " . name
  "echo "args: " . string(args)
  "echo "lets: " . string(lets)
  let fhead = "function! " . name . " (args)\n"
  let cnt = 0
  for arg in args
    if lets[cnt] != {}
      let val = values(lets[cnt])[0]
      let fhead .= "  let a:" . arg . " = has_key(a:args, '" . arg . "') ? a:args['" . arg . "'] : " . val . "\n"
    else
      let fhead .= "  let a:" . arg . " = a:args['" . arg . "']\n"
    endif
    let fhead .= "  let " . arg . " = a:" . arg . "\n"
    let cnt += 1
  endfor

  return fhead . body . "\nendfunction"
endfunc

func! FBody(elems)
  "echo "FBody: " . string(a:elems)
  return a:elems[0]
endfunc

func! FCall(elems)
  "echo "FCall: " . string(a:elems)
  return "let r = " . a:elems[0][0] . "({'a':'2'})"
endfunc

func! VFunc(elems)
  "echo "VFunc: " . string(a:elems)
  return a:elems[0]
endfunc

func! Vigor(expr)
  "return g:vigor.match(a:expr)['value'][0]
  let res = g:vigor.match(a:expr)
  if res['is_matched']
    let r = ''
    exec res['value'][0]
    return r
  "else
    "echo res['errmsg']
  endif
endfunc

" client side

" The power() function, defaulting to powers of 10
echo Vigor("Pow = (a, b: 10) ->\n  let x = a * b\n  return x")
echo Vigor("Pow(a: 2)")

" The resulting VimL function should be callable from VimL as:
"   echo Pow({'a': 2, 'b': 3})
"   echo Pow({'a': 4})
"
" Which would be represented in Vigor as:
"   echo Pow(a = 2, b = 3)  or  echo Pow(2, 3)
"   echo Pow(a = 4)         or  echo Pow(4)


" Summary of intended call signatures:

"   Foo = (a: 6, b: 7) -> return a * a

"   echo Foo(10)              " a = 10
"   echo Foo(10, 20)          " a = 10, b = 20
"   echo Foo(a = 10)          " a = 10, b = 7
"   echo Foo(b = 10)          " a = 6,  b = 10
"   echo Foo(a = 5, b = 10)   " a = 5,  b = 10
"   echo Foo(b = 5, a = 10)   " a = 10, b = 5


" This doesn't work yet - all functions must have at least one arg
"echo Vigor("Pow = () ->\n  let x = a * b\n  return x")

