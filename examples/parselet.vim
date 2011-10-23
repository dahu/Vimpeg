" Parselt example of Vimpeg
" Barry Arthur,  01 Oct 2011

let q = vimpeg#parser({'skip_white': 0})

let integer      =  q.and([q.e('\d\+'), 'maybe_space'], {'id': 'integer'})

let space        =  q.e('\s', {'id': 'space'})
let maybe_space  =  q.maybe_many('space', {'id': 'maybe_space'})

let operator     =  q.and([q.e('+'), 'maybe_space'], {'id': 'operator'})

let sum          =  q.and(['integer', 'operator', 'expression'], {'id': 'sum'})
let expression   =  q.or(['sum', 'integer'], {'id': 'expression'})

let ident        =  q.e('\w\+', {'id': 'ident'})
let assignment   =  q.and(['ident', 'maybe_space', q.e('='), 'maybe_space', 'expression'], {'id': 'assignment'})


function! ParseExpression(str)
  let res = g:expression.match(a:str)
  if res['is_matched']
    return res['value']
  else
    return res['errmsg']
  endif
endfunction

function! ErrorTree(pobj)
  if has_key(a:pobj, 'errmsg')
    if a:pobj['errmsg'] != ''
      echo a:pobj['errmsg']
    endif
  endif
  if has_key(a:pobj, 'elements')
    for o in a:pobj['elements']
      if type(o) == type({})
        call ErrorTree(o)
      elseif type(o) == type([])
        for o2 in o
          call ErrorTree(o2)
        endfor
      endif
    endfor
  endif
endfunction

function! ParseAssignment(str)
  let res = g:assignment.match(a:str)
  if res['is_matched']
    return res['value']
  else
    "echo res
    call ErrorTree(res)
    return res['errmsg']
  endif
endfunction

"echo ParseExpression('1 + 2 + 3')
"echo ParseAssignment('x = 1 + 2')
echo ParseAssignment('x 1 + 2')
