let p = vimpeg#parser({'skip_white': 1})
let q = vimpeg#parsevimpeg#parser({'skip_white': 0})

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
  "echo "Arg: " . string(a:elems)
  let assignment = {}
  let assignment[a:elems[0]] = '__unbound__'
  if len(a:elems[1]) > 0
    let assignment[a:elems[0]] = a:elems[1][0][1]
  endif
  return assignment
endfunc

func! ArgList(elems)
  "echo "ArgList: " . string(a:elems)
  let arglist = a:elems[0]
  call map(map(a:elems[1], 'v:val[1]'), 'extend(arglist, v:val)')
  return arglist
endfunc

func! Args(elems)
  "echo "Args: " . string(a:elems)
  return a:elems[1]
endfunc

func! FDecl(elems)
  "echo "FDecl: " . string(a:elems)
  let name = a:elems[0]
  let args = a:elems[2]
  let body = a:elems[4][0]
  let fhead = "function! " . name . " (args)\n"
  let lets = ''
  let cnt = 0
  for arg in items(args)
    if arg[1] != '__unbound__'
      let lets .= "  let a:" . arg[0] . " = has_key(a:args, '" . arg[0] . "') ? a:args['" . arg[0] . "'] : " . arg[1] . "\n"
    else
      let lets .= "  let a:" . arg[0] . " = a:args['" . arg[0] . "']\n"
    endif
    let lets .= "  let " . arg[0] . " = a:" . arg[0] . "\n"
    let cnt += 1
  endfor

  return fhead . lets . body . "\nendfunction"
endfunc

func! FBody(elems)
  "echo "FBody: " . string(a:elems)
  return a:elems
endfunc

func! FCall(elems)
  "echo "FCall: " . string(a:elems)
  let fargs = a:elems[1]
  "let avals = a:elems[1][0][0]
  "call map(a:elems[1][0][1], 'extend(fargs, v:val)')
  "call filter(avals, 'has_key(fargs, v:val) == 0')
  "if len(avals) > 0
    "call extend(fargs, {'b': avals[0]})
  "endif
  return "let r = " . a:elems[0] . "(" . string(fargs) . ")"
endfunc

func! VFunc(elems)
  "echo "VFunc: " . string(a:elems)
  return a:elems
endfunc

func! Vigor(expr)
  let res = g:vigor.match(a:expr)
  if res['is_matched']
    let r = ''
    echo res['value']
    exec res['value']
    return r
  else
    echo res['errmsg']
  endif
endfunc

" client side

" The power() function, defaulting to powers of 10
echo Vigor("Pow = (a, b: 20) ->\n  let x = a * b\n  return x")
"echo Vigor("Pow(a: 2)")
echo Vigor("Pow(a: 3, b: 8)")
"echo Vigor("Pow(b: 3, a: 8)")

" This is still hard because we still need a func-table with expected arg details
"echo Vigor("Pow(a: 8, 2)")

" The resulting VimL function should be callable from VimL as:
"   echo Pow({'a': 2, 'b': 3})
"   echo Pow({'a': 4})
"
" Which would be represented in Vigor as:
"   NOTE: But isn't yet because the same args parse-code is being used for
"   call as with decl, so for now, the real args look like:
"     echo Pow(a: 2, b: 3)
"
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

