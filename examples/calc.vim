let s:p = vimpeg#parser({'root_element': 'calc', 'skip_white': 1})

call s:p.or(['add', 'sub', 'prod'],
      \{'id': 'calc'})

call s:p.and(['prod', s:p.t('+'), 'calc'],
      \{'id': 'add',
      \ 'on_match': Fn('(elems) => a:elems[0] + a:elems[1]')})

call s:p.and(['prod', s:p.t('-'), 'calc'],
      \{'id': 'sub',
      \ 'on_match': Fn('(elems) => a:elems[0] - a:elems[1]')})

call s:p.or(['mul', 'div', 'atom'],
      \{'id': 'prod'})

call s:p.and(['atom', s:p.t('\*'), 'prod'],
      \{'id': 'mul',
      \ 'on_match': Fn('(elems) => a:elems[0] * a:elems[1]')})

call s:p.and(['atom', s:p.t('\/'), 'prod'],
      \{'id': 'div',
      \ 'on_match': Fn('(elems) => a:elems[0] / a:elems[1]')})

call s:p.and([s:p.t('('), 'calc', s:p.t(')')],
      \{'id': 'ncalc',
      \ 'on_match': Fn('(elems) => a:elems[0]')})

call s:p.or(['num', 'ncalc'],
      \{'id': 'atom'})

call s:p.e('\d\+',
      \{'id': 'num',
      \ 'on_match': Fn('(elems) => str2nr(a:elems)')})

let g:calc#parser = s:p.GetSym('calc')
let Calc = Fn('(expr) => g:calc#parser.match(a:expr)["value"]')

echo (45 + 123)                  . '==' . Calc('45 + 123')
echo (123 - 45)                  . '==' . Calc('123 - 45')
echo (123 * 45)                  . '==' . Calc('123 * 45')
echo (123 / 45)                  . '==' . Calc('123 / 45')
echo (14 + 15 * 3 + 2 * (5 - 7)) . '==' . Calc('14 + 15 * 3 + 2 * (5 - 7)')
echo (10 + 2 / 3 * 4 + (5 - 6))  . '==' . Calc('10 + 2 / 3 * 4 + (5 - 6)')
