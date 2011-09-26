so ../plugin/vimpeg.vim
let p = Vimpeg()

" Inline Arrow Expander - example VimPeg usage

" NOTE: vimpeg is greedy with whitespace, so leading ws is lost.
" trailing ws can be kept with explict inclusion in patterns.
" an option to control this behaviour will be added in a coming version.

let dqstring  = p.and([p.e('"'), p.e('.\{-}\ze"'), p.e('"\s*')], {'id': 'dqstring'})
let sqstring  = p.and([p.e("'"), p.e(".\\{-}\\ze'"), p.e("'\\s*")], {'id': 'sqstring'})
let qstring   = p.or([dqstring, sqstring], {'id': 'qstring', 'on_match': 'QString'})
let uqstring1 = p.e('.\{-}[''"]\@=', {'id': 'uqstring1'})
let uqstring2 = p.e('.\+', {'id': 'uqstring2'})
let uqstring  = p.or([uqstring1, uqstring2], {'id': 'uqstring', 'on_match': 'UQString'})
let string    = p.many(p.or([qstring, uqstring], {'id': 'string'}))

" ex functions called on successful match of element (grammar provider library side)
func! QString(elems)
  "echo "QString: " . string(a:elems)
  return join(map(a:elems, 'join(v:val)'), "")
endfunc

func! UQString(elems)
  "echo "UQString: " . string(a:elems)
  return substitute(a:elems[0], '->', nr2char(0x2192), 'g')
endfunc

func! InlineExpandArrows(str)
  return join(map(g:string.match(a:str)['value'], 'join(v:val)'), "")
endfunc

" client side

echo '#' . InlineExpandArrows('this -> here "that -> there" and -> more ''here -> too'' so -> on') . '#'

" Uncomment following and experiment with typing below the   finish   line
"augroup inline_expander
  "au!
  "au InsertLeave * call setline('.', InlineExpandArrows(getline('.')))<CR>
"augroup END

finish

this -> here and "this -> here" and -> more
