func! Calc(expr)
  return calc#parse(a:expr)['value']
endfunc
