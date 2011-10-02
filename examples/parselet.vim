" Parselt example of Vimpeg
" Barry Arthur,  01 Oct 2011

so ../plugin/vimpeg.vim
let q = Vimpeg({'skip_white': 0})

let integer      =  q.and([q.e('\d\+'), 'maybe_space'], {'id': 'integer'})

let space        =  q.e('\s', {'id': 'space'})
let maybe_space  =  q.maybe_many('space', {'id': 'maybe_space'})

let operator     =  q.and([q.e('+'), 'maybe_space'], {'id': 'operator'})

let sum          =  q.and(['integer', 'operator', 'expression'], {'id': 'sum'})
let expression   =  q.or(['sum', 'integer'], {'id': 'expression'})


function! Parse(str)
  let res = g:expression.match(a:str)
  "echo res
  if res['is_matched']
    return res['value']
  else
    return res['errmsg']
  endif
endfunction

"echo Parse('1 + 2 + 3')
echo Parse('1 + 2 + a')
