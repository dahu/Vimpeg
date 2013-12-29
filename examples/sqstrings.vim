" Single Quote Strings
" Barry Arthur, Jun 2011

let p = vimpeg#parser({'skip_white': 1})

" sqstr           ::=  "'" ("''" | !"'" '.')* "'"
let sqstr = p.and([ p.e("'"),
                  \ p.maybe_many(p.or([p.e("''"),
                  \                    p.and([p.not_has(p.e("'")),
                  \                           p.e('.')])])),
                  \ p.e("'")],
                  \{'id': 'sqstr', 'on_match': 'SQStr'})

func! SQStr(elems)
  return join(map(a:elems[1], 'v:val[1]'), '')
endfunc

func! String(expr)
  return g:sqstr.match(a:expr)['value']
endfunc

" client side
echo 'xyz' == String("'xyz'")
echo 'xy\n' == String('''xy\n''')
echo 'xy\n' != String('''xy\\n''')
echo 'xy\n' == String("'xy\\n'")
echo 'xy\n' != String("'xy\n'")
