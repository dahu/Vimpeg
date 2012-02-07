func! csv_parser#file(elems)
  "echo "File: " . string(a:elems)
  return extend([a:elems[0]], map(a:elems[1], 'v:val[1]'))
endfunc
func! csv_parser#record(elems)
  "echo "Record: " . string(a:elems)
  return extend([a:elems[0]], map(a:elems[1], 'v:val[2]'))
endfunc
func! csv_parser#q_field(elems)
  "echo "Q_Field: " . string(a:elems)
  return '"' . join(a:elems[2], '') . '"'
endfunc
func! csv_parser#uq_field(elems)
  "echo "UQ_Field: " . string(a:elems)
  return join(a:elems[1], '')
endfunc
func! csv_parser#char(elems)
  "echo "Char: " . string(a:elems)
  return a:elems[1]
endfunc
func! csv_parser#dqdq(elems)
  "echo "Newline: " . string(a:elems)
  return '""'
endfunc
func! csv_parser#newline(elems)
  "echo "Newline: " . string(a:elems)
  return "\n"
endfunc
