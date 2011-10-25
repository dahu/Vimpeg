func! Calc(expr)
  "echo "Calc: " . string(a:expr)
  return g:calc#parser.match(a:expr)['value']
endfunc
