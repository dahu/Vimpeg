" Only show code within a given #ifdef - example of Vimpeg
" Barry Arthur,  01 Oct 2011
"
" NOTE: This is only a proof-of-concept.
"
" A real implementation would handle nested #if[n]def blocks - this example
" DOES NOT

let p = vimpeg#parser({'skip_white': 1})

call  p.e('#ifdef',  {'id': 'ifdef'})
call  p.e('#ifndef', {'id': 'ifndef'})
call  p.e('#else',   {'id': 'else'})
call  p.e('#endif',  {'id': 'endif'})

call  p.e('\w\+', {'id': 'macro'})

call  p.and(['ifdef', 'macro'], {'id': 'ifdef_macro'})
call  p.and(['ifndef', 'macro'], {'id': 'ifndef_macro'})

let condition = p.or(['ifdef_macro', 'ifndef_macro', 'else', 'endif'], {'id': 'condition'})

let g:defines = []
let g:defines = ['ALLOWED']
"let g:defines = ['DISALLOWED']
"let g:defines = ['ALLOWED', 'DISALLOWED']

function! ParseConditions(file)
  let flines = readfile(a:file)
  let plines = []
  let ok = 1
  for line in flines
    let res = g:condition.match(line)
    if res['is_matched']
      if type(res['value']) == type([])
        if ok
          if res['value'][0] == '#ifdef'
            if index(g:defines, res['value'][1]) == -1
              let ok = 0
            endif
          else
            if index(g:defines, res['value'][1]) != -1
              let ok = 0
            endif
          endif
        endif
        continue
      elseif res['value'] == '#else'
        let ok = !ok
        continue
      elseif res['value'] == '#endif'
        " too simplistic - doesn't allow nested #ifdef's (which C does)
        let ok = 1
        continue
      endif
    endif
    if ok
      call add(plines, line)
    endif
  endfor
  "echo plines
  enew
  call append(0, plines)
endfunction

call ParseConditions('foo.c')
