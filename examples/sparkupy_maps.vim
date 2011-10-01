so ../plugin/vimpeg.vim
let p = Vimpeg({'skip_white': 1})

" Sparkupy grammar for Vim maps
" NOTE: This is only a demonstration of the parser, not a viable
" implementation of such a sparkupy map generator.

" vimmap   := (string | keycode | keycombo)*             : VimMap
" keycode  := (
"              'bu' | 'en' | 'ex' | 'ho' | 'lx' | 'lt' |
"              'pd' | 'pl' | 'pu' | 'sc' | 'sd' | 'si' |
"              'sp' | 'tb' | 'un' | 'xx' |
"              '[ _,.behjklr]'
"             )                                          : KeyCode
" keycombo := '[-acdms]' '.'                             : KeyCombo
" string   := '.+'                                       : String

let vimmap = p.many(p.or(['keycombo', 'keycode', 'string']),     {'id': 'vimmap',   'on_match': 'VimMap'  })
call           p.or([p.e('bu'), p.e('en'), p.e('ex'), p.e('ho'),
      \              p.e('lx'), p.e('lt'), p.e('pd'), p.e('pl'),
      \              p.e('pu'), p.e('sc'), p.e('sd'), p.e('si'),
      \              p.e('sp'), p.e('tb'), p.e('un'), p.e('xx'),
      \              p.e('[ _,.behjklr]')],                      {'id': 'keycode',  'on_match': 'KeyCode' })
call          p.and([p.e('[-acdms]'), p.e('.')],                 {'id': 'keycombo', 'on_match': 'KeyCombo'})
call            p.e('.\+',                                       {'id': 'string',   'on_match': 'String'  })

" ex functions called on successful match of element (grammar provider library side)

let s:ctrl = ''

func! VimMap(elems)
  "echomsg "VimMap: " . string(a:elems)
  let s = ''
  if s:ctrl != ''
    let s = '>'
  endif
  return join(map(a:elems, 'v:val[0]'), '') . s
endfunc
func! KeyCode(elems)
  let keycodes = {
        \    ' '  : " ",
        \    '_'  : "",
        \    ','  : "",
        \    '.'  : "<Space>",
        \    'b'  : "<Bar>",
        \    'bu' : " <buffer> ",
        \    'e'  : "<Esc>",
        \    'en' : "<End>",
        \    'ex' : " <expr> ",
        \    'h'  : "<Left>",
        \    'ho' : "<Home>",
        \    'j'  : "<Down>",
        \    'k'  : "<Up>",
        \    'l'  : "<Right>",
        \    'lx' : "<LocalLeader>",
        \    'lt' : "<lt>",
        \    'pd' : "<PageDown>",
        \    'pl' : "<Plug>",
        \    'pu' : "<PageUp>",
        \    'r'  : "<CR>",
        \    'sc' : " <script> ",
        \    'sd' : "<SID>",
        \    'si' : " <silent> ",
        \    'sp' : " <special> ",
        \    'tb' : "<Tab>",
        \    'un' : " <unique> ",
        \    'xx' : "<Leader>",
        \}
  let s = ''
  if s:ctrl != ''
    let s = '>'
    let s:ctrl = ''
  endif
  return(s . keycodes[a:elems[0]])
endfunc
func! KeyCombo(elems)
  let s = ''
  if a:elems[0][0] == '-'
    let s = '><' . s:ctrl . '-' . a:elems[1][0]
  else
    if s:ctrl != ''
      let s = '>'
    endif
    let s:ctrl = a:elems[0][0]
    let s .= '<' . s:ctrl . '-' . a:elems[1][0]
  end
  return s
end
endfunc
func! String(elems)
  return a:elems
endfunc
func! SparkupVimMap(expr)
  let s:ctrl = ''
  let retval = g:vimmap.match(a:expr)
  if retval['is_matched']
    return retval['value'][0]
  else
    return a:expr
  endif
endfunc

func! SVM(line)
  return join(map(split(a:line, ' '), 'SparkupVimMap(v:val)'), ' ')
endfunc

nnoremap <leader>x :call setline('.', SVM(getline('.')))<CR>

" tests - uncomment 'finish' to run tests

echo 'abc'                                     . ' == ' . SparkupVimMap('"abc"')
echo '<PageUp><PageDown>'                      . ' == ' . SparkupVimMap('pupd')
echo '<Leader>x'                               . ' == ' . SparkupVimMap('xx_x')
echo '<c-x>'                                   . ' == ' . SparkupVimMap('cx')
echo '<c-x><c-f>'                              . ' == ' . SparkupVimMap('cx-f')
echo 'nnoremap <Leader>x :ls <CR> :b <Space>'  . ' == ' . SVM('nnoremap xx_x :ls r :b .')
