silent call vimpeg#peg#writefile(0, ['calc.vim', 'calc.vimpeg'])

" Callback functions called on successful match of element:
" (grammar provider side, library)

func! Add(elems)
  "echo "Add: " . string(a:elems)
  return a:elems[0] + a:elems[2]
endfunc
func! Sub(elems)
  "echo "Sub: " . string(a:elems)
  return a:elems[0] - a:elems[2]
endfunc
func! Mul(elems)
  "echo "Mul: " . string(a:elems)
  return a:elems[0] * a:elems[2]
endfunc
func! Div(elems)
  "echo "Div: " . string(a:elems)
  return a:elems[0] / a:elems[2]
endfunc
func! Num(elems)
  "echo "Num: " . string(a:elems)
  return str2nr(a:elems)
endfunc
func! NCalc(elems)
  "echo "NCalc: " . string(a:elems)
  return a:elems[1]
endfunc

" Main entry point(s):
" (grammar user side, public interface)

func! Calc(expr)
  "echo "Calc: " . string(a:expr)
  return g:calc.match(a:expr)['value']
endfunc

" (client side)

echo (45 + 123)                  . '==' . Calc('45 + 123')
echo (123 - 45)                  . '==' . Calc('123 - 45')
echo (123 * 45)                  . '==' . Calc('123 * 45')
echo (123 / 45)                  . '==' . Calc('123 / 45')
echo (14 + 15 * 3 + 2 * (5 - 7)) . '==' . Calc('14 + 15 * 3 + 2 * (5 - 7)')
