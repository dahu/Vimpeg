func! commands_parser#set(elems)
  echo "set: " . string(a:elems)
  " return extend([a:elems[0]], map(a:elems[1], 'v:val[1]'))
  return a:elems
endfunc
func! commands_parser#show(elems)
  echo "show: " . string(a:elems)
  " return extend([a:elems[0]], map(a:elems[1], 'v:val[1]'))
  return a:elems
endfunc
