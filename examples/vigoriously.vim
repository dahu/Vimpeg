" Vigoriously - VimL Function (snippet) generator
" Barry Arthur, 02 Oct 2011
" Last updated: 10 Oct 2011
" version 0.4 - Ready for Release in Vimpeg Article

let p = vimpeg#parser({'skip_white': 1})

call p.e('"', {'id': 'comment'})
call p.e('[[:alnum:]&]\+', {'id': 'value'})
call p.e('\w\+', {'id': 'ident'})
call p.and(['ident', p.maybe_one(p.and([p.e(':'), 'value']))], {'id': 'arg', 'on_match': 'Arg'})

" change this to allow argumentless functions
call p.and(['arg', p.maybe_many(p.and([p.e(','), 'arg']))], {'id': 'arglist', 'on_match': 'ArgList'})
call p.and([p.e('('), 'arglist', p.e(')')], {'id': 'args', 'on_match': 'Args'})

let vigoriously = p.and(['comment', 'ident', 'args', p.e('->'), p.e('.*')], {'id': 'fdecl', 'on_match': 'FDecl'})

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
  let body = a:elems[4]
  let fhead = "function! " . name . " ("
  let fargs = []
  let unbounds = 0
  let lets = '  " vigoriously {{{' . "\n"
  let cnt = 0
  for arg in items(args)
    if arg[1] != '__vigor_manarg'
      let unbounds = 1
    else
      call add(fargs, arg[0])
    endif
    let cnt += 1
  endfor

  let varargs = filter(items(copy(args)), 'v:val[1] != "__vigor_manarg"')
  call map(args, 'v:val =~ "manarg" ? "a:".v:key : v:val')
  let lets .= "  let __vigor_args = " . string(map(varargs, 'v:val[0]')) . "\n"
  let lets .= "  let __vigor_argvals = " . string(args) . "\n"

  let lets .= "  let i = 0" . "\n"
  let lets .= "  while i < a:0" . "\n"
  let lets .= "    let __vigor_argvals[__vigor_args[i]] = a:000[i]" . "\n"
  let lets .= "    let i += 1" . "\n"
  let lets .= "  endwhile" . "\n"
  let lets .= "  for i in keys(__vigor_argvals)" . "\n"
  let lets .= "    exe 'let ' . i . ' = ' . __vigor_argvals[i]" . "\n"
  let lets .= "  endfor" . "\n"
  let lets .= "  unlet i" . ' "}}}' . "\n"
  let lets .= "\n  "

  if unbounds
    call add(fargs, '...')
  endif

  let body = substitute(body, '|', "\n  ", 'g')

  return fhead . join(fargs, ',') . ")\n" . lets . body . "\nendfunction"
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

" 0. Source this file with   :so %

" 1. Move your cursor to the line below and type   <leader>x

" MinWinWidth (textwidth, numberwidth: &numberwidth, foldcolumn: &foldcolumn) -> exe "set textwidth=" . textwidth . " numberwidth=" . numberwidth . " foldcolumn=" . foldcolumn
function! MinWinWidth (textwidth,...)
  " vigoriously {{{
  let __vigor_args = ['numberwidth', 'foldcolumn']
  let __vigor_argvals = {'numberwidth': '&numberwidth', 'foldcolumn': '&foldcolumn', 'textwidth': 'a:textwidth'}
  let i = 0
  while i < a:0
    let __vigor_argvals[__vigor_args[i]] = a:000[i]
    let i += 1
  endwhile
  for i in keys(__vigor_argvals)
    exe 'let ' . i . ' = ' . __vigor_argvals[i]
  endfor
  unlet i "}}}

  exe "set textwidth=" . textwidth . " numberwidth=" . numberwidth . " foldcolumn=" . foldcolumn
endfunction

" 2. Save & then re-source the file with   :so %   to vivify the newly
"    generated MinWinWidth() function.
"
" 3. And then experiment with calls like:
"
"  :call MinWinWidth(80)
"  :call MinWinWidth(80, 4)
"  :call MinWinWidth(80, 6, 4)
"  :call MinWinWidth(80, 1, 0)
