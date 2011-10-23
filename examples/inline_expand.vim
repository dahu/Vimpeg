" Inline Arrow Expander - example VimPeg usage
" Barry Arthur,  02 Oct 201

let p = vimpeg#parser({'skip_white': 0})

call p.and([p.e('"'), p.e('.\{-}\ze"'), p.e('"\s*')], {'id': 'dqstring'})
call p.and([p.e("'"), p.e(".\\{-}\\ze'"), p.e("'\\s*")], {'id': 'sqstring'})
call p.or(['dqstring', 'sqstring'], {'id': 'qstring', 'on_match': 'QString'})
call p.e('.\{-}[''"]\@=', {'id': 'uqstring1'})
call p.e('.\+', {'id': 'uqstring2'})
call p.or(['uqstring1', 'uqstring2'], {'id': 'uqstring', 'on_match': 'UQString'})
let string = p.many(p.or(['qstring', 'uqstring'], {'id': 'string'}))

" ex functions called on successful match of element (grammar provider library side)
func! QString(elems)
  "echo "QString: " . string(a:elems)
  return join(a:elems, '')
endfunc

func! UQString(elems)
  "echo "UQString: " . string(a:elems)
  return substitute(a:elems, '->', nr2char(0x2192), 'g')
endfunc

func! InlineExpandArrows(str)
  let res = g:string.match(a:str)
  return join(res['value'])
endfunc

" client side

echo '#' . InlineExpandArrows('    this -> here "that -> there" and -> more ''here -> too'' so -> on    ') . '#'

" Uncomment following and experiment with typing below the   finish   line
"augroup inline_expander
  "au!
  "au InsertLeave * call setline('.', InlineExpandArrows(getline('.')))<CR>
"augroup END

finish

this → here and "this -> here" and → more  some → here "and -> here" too
