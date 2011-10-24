call calculator#init()
func! Calc(expr)
  "echo "Calc: " . string(a:expr)
  "return g:calc.match(a:expr)['value']
  return g:calc.match(a:expr)['value']
endfunc
