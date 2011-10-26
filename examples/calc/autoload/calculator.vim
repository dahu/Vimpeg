func! calculator#add(elems)
  "echo "Add: " . string(a:elems)
  return a:elems[0] + a:elems[2]
endfunc
func! calculator#sub(elems)
  "echo "Sub: " . string(a:elems)
  return a:elems[0] - a:elems[2]
endfunc
func! calculator#mul(elems)
  "echo "Mul: " . string(a:elems)
  return a:elems[0] * a:elems[2]
endfunc
func! calculator#div(elems)
  "echo "Div: " . string(a:elems)
  return a:elems[0] / a:elems[2]
endfunc
func! calculator#num(elems)
  "echo "Num: " . string(a:elems)
  return str2nr(a:elems)
endfunc
func! calculator#nCalc(elems)
  "echo "nCalc: " . string(a:elems)
  return a:elems[1]
endfunc
