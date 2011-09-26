so ../plugin/vimpeg.vim
let p = Vimpeg()

" Simple Calculator Grammar, Rooted at 'calc'

" (goal is to generate the code below from the following PEG grammar)
"
" calc  := add | sub | prod
" add   := prod '+' calc      : Add
" sub   := prod '-' calc      : Sub
" prod  := mul | div | atom
" mul   := atom '\*' prod     : Mul
" div   := atom '\/' prod     : Div
" ncalc := '(' calc ')'       : NCalc
" atom  := num | ncalc
" num   := '\d\+'             : Num

let calc =  p.or(['add'    , 'sub'     , 'prod'   ], {'id': 'calc'                        })
call       p.and(['prod'   , p.e('+')  , 'calc'   ], {'id': 'add'    , 'on_match': 'Add'  })
call       p.and(['prod'   , p.e('-')  , 'calc'   ], {'id': 'sub'    , 'on_match': 'Sub'  })
call        p.or(['mul'    , 'div'     , 'atom'   ], {'id': 'prod'                        })
call       p.and(['atom'   , p.e('\*') , 'prod'   ], {'id': 'mul'    , 'on_match': 'Mul'  })
call       p.and(['atom'   , p.e('\/') , 'prod'   ], {'id': 'div'    , 'on_match': 'Div'  })
call       p.and([p.e('(') , 'calc'     , p.e(')')], {'id': 'ncalc'  , 'on_match': 'NCalc'})
call        p.or(['num'    , 'ncalc'              ], {'id': 'atom'                        })
call         p.e('\d\+'                            , {'id': 'num'    , 'on_match': 'Num'  })

" ex functions called on successful match of element (grammar provider library side)

func! Add(elems)
  return a:elems[0][0] + a:elems[2][0]
endfunc
func! Sub(elems)
  return a:elems[0][0] - a:elems[2][0]
endfunc
func! Mul(elems)
  return a:elems[0][0] * a:elems[2][0]
endfunc
func! Div(elems)
  return a:elems[0][0] / a:elems[2][0]
endfunc
func! Num(elem)
  return str2nr(a:elem)
endfunc
func! NCalc(elem)
  return a:elem[1][0]
endfunc
func! Calc(expr)
  "return string(g:calc.match(a:expr))
  return string(g:calc.match(a:expr)['value'][0])
endfunc

" client side

echo (3 + 4)                      . '==' . Calc('3 + 4')
echo (14 + 15 * 3 + 2 * (5 - 7))  . '==' . Calc('14 + 15 * 3 + 2 * (5 - 7)')
