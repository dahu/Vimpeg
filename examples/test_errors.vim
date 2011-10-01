" Test Error Messages in Vimpeg
" Barry Arthur, Oct 2011

source ../plugin/vimpeg.vim
let p = Vimpeg({'skip_white': 1})

let err1 = p.e('\d\+', {'id': 'integers'})

function! Errs(str)
  let res = g:err1.match(a:str)
  if res['is_matched']
    return res['value'][0]
  else
    return res['id'] . ' Error: ' . res['errmsg']
  endif
endfunction

echo '42'        . '==' . Errs('42')
echo '42'        . '==' . Errs('a')
