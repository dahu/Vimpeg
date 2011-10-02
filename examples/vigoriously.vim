" Vigoriously - VimL Function (snippet) generator
" Barry Arthur, 02 Oct 2011

so ../plugin/vimpeg.vim
let p = Vimpeg({'skip_white': 1})

" fdecl               := identifier arguments
" identifier          := '\w\+'
" value               := '\w\+'
" arguments           := '(' arg_list ')'
" arg_list            := assignment (',' assignment)*
" assignment          := identifier ':' expression
" expression          := COMPLICATED - for now, use   value

call p.e('"', {'id': 'comment'})
call p.e('\w\+', {'id': 'value'})
call p.e('\w\+', {'id': 'ident'})
call p.and(['ident', p.maybe_one(p.and([p.e(':'), 'value']))], {'id': 'arg', 'on_match': 'Arg'})

" change this to allow argumentless functions
call p.and(['arg', p.maybe_many(p.and([p.e(','), 'arg']))], {'id': 'arglist', 'on_match': 'ArgList'})
call p.and([p.e('('), 'arglist', p.e(')')], {'id': 'args', 'on_match': 'Args'})

let vigoriously = p.and(['comment', 'ident', 'args'], {'id': 'fdecl', 'on_match': 'FDecl'})

" callbacks on successful match of element (grammar provider library side)

func! Arg(elems)
  "echo "Arg: " . string(a:elems)
  let assignment = {}
  let assignment[a:elems[0]] = '__vigor_manarg'
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
  let name = a:elems[1]
  let args = a:elems[2]
  let fhead = "function! " . name . " ("
  let fargs = []
  let unbounds = 0
  let lets = ''
  let cnt = 0
  for arg in items(args)
    if arg[1] != '__vigor_manarg'
      let unbounds = 1
    else
      let lets .= "  let " . arg[0] . " = a:" . arg[0] . "\n"
      call add(fargs, arg[0])
    endif
    let cnt += 1
  endfor

  let varargs = filter(items(copy(args)), 'v:val[1] != "__vigor_manarg"')
  let varvals = {}
  call map(map(copy(varargs), '{v:val[0]: v:val[1]}'), 'extend(varvals, v:val)')

  let lets .= "  let l:__vigor_argvals = " . string(varvals) . "\n"
  let lets .= "  let l:__vigor_args = " . string(map(varargs, 'v:val[0]')) . "\n"

  let lets .= "  let cnt = 0" . "\n"
  let lets .= "  for i in a:000" . "\n"
  let lets .= "    exe 'let ' . l:__vigor_args[cnt] . ' = ' . i" . "\n"
  let lets .= "    let cnt += 1" . "\n"
  let lets .= "  endfor" . "\n"
  let lets .= "  for i in range(cnt, len(l:__vigor_args) - 1)" . "\n"
  let lets .= "    exe 'let ' . l:__vigor_args[i] . ' = ' . l:__vigor_argvals[l:__vigor_args[i]]" . "\n"
  let lets .= "  endfor" . "\n"

  if unbounds
    call add(fargs, '...')
  endif

  return fhead . join(fargs, ',') . ")\n" . lets . "\nendfunction"
endfunc

func! Vigoriously()
  let res = g:vigoriously.match(getline('.'))
  if res['is_matched']
    call append('.', split(res['value'], '\n'))
  else
    echo res['errmsg']
  endif
endfunc

nnoremap <leader>x :call Vigoriously()<CR>



" 1. Move your cursor to the line below and type   <leader>x

" Mul (a, b: 2, c: 3)



" 2. Add the following line to the end of the generated function above
"    (uncommented):
"
"  return a * b * c
"
" 3. Re-source the file with   :so %   to vivify the newly generated Mul()
"    function.
"
" 4. And then experiment with calls like:
"
"  :echo Mul(1)
"  :echo Mul(4)
"  :echo Mul(4,5)
"  :echo Mul(4,5,6)
"
" 5. Experiment with other function signatures, like:
"
" Mul (a, b, c: 3)
