" haven't yet thought of a better way to do this :-/

" :%call Parse_CSV('g:recs')
func! Parse_CSV(var) range
  let lines = getline(a:firstline, a:lastline)
  exe "let " . a:var . " = g:csv#parser.match(join(lines, '\n'))['value'] "
endfunc

" :call Print_CSV(recs)
func! Print_CSV(records)
  for rec in reverse(a:records)
    call append('.', join(rec, ", "))
  endfor
endfunc
