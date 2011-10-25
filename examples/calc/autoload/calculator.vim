let calculator#callback = {}
func! calculator#callback.add(elems)
  "echo "Add: " . string(a:elems)
  return a:elems[0] + a:elems[2]
endfunc
func! calculator#callback.sub(elems)
  "echo "Sub: " . string(a:elems)
  return a:elems[0] - a:elems[2]
endfunc
func! calculator#callback.mul(elems)
  "echo "Mul: " . string(a:elems)
  return a:elems[0] * a:elems[2]
endfunc
func! calculator#callback.div(elems)
  "echo "Div: " . string(a:elems)
  return a:elems[0] / a:elems[2]
endfunc
func! calculator#callback.num(elems)
  "echo "Num: " . string(a:elems)
  return str2nr(a:elems)
endfunc
func! calculator#callback.nCalc(elems)
  "echo "nCalc: " . string(a:elems)
  return a:elems[1]
endfunc
