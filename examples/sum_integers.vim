" Introducing Vimpeg - A PEG Parser Generator for Vim
" Barry Arthur,  01 Oct 2011
" Demonstrates: Summing a series of integers

let p = vimpeg#parser({'skip_white': 1})
call p.e('\d\+', {'id': 'integer', 'on_match': 'Integer'})
call p.and(['integer', p.e('+'), 'expression'], {'id': 'sum'})
let expression =  p.or(['sum', 'integer'], {'id': 'expression'})

function! Integer(elems)
  return str2nr(a:elems)
endfunction

function! SumList(s)
  return type(a:s) == type(1) ? a:s : a:s[0] + SumList(a:s[2])
endfunction

function! Sum(str)
  let res = g:expression.match(a:str)
  if res['is_matched']
    echo res.value
    return SumList(res['value'])
  else
    return res['errmsg']
  endif
endfunction

"echo Sum('123')
"echo Sum('1 + 2')
echo Sum('1 + 2 + 3')
"echo Sum('12 + 34 + 56 + 78')
