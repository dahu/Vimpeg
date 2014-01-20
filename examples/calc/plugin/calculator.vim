so <sfile>:p:h:h/autoload/calc.vim
so <sfile>:p:h:h/autoload/calculator.vim
func! Calc(expr)
  "echo "Calc: " . string(a:expr)
  return g:calc#parser.match(a:expr)['value']
endfunc
