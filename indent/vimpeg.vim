" Only load this indent file when no other was loaded.
if exists('b:did_indent')
   finish
endif
let b:did_indent = 1

setlocal indentexpr=GetVimPEGIndent()
setlocal indentkeys=o,O,!^F

" Restore when changing filetype.
let b:undo_indent = 'setl indentexpr< indentkeys<'

" Only define the function once.
if exists('s:loaded')
  finish
endif
let s:loaded = 1

" Allow use of line continuation.
let s:save_cpo = &cpo
set cpo&vim

function GetVimPEGIndent()
  if v:lnum == 1
    " first line
    return 0
  endif
  let lnum = v:lnum
  let line = getline(lnum)
  let lines = []
  let equal_string = ''
  let i = -1
  while lnum > 0
        \ && line !~# '\m\C^\s*;'
        \ && (lnum == v:lnum || line =~# '\m\C\%(^\|[^\\]\)\%(\\\\\)*\\$')
    call insert(lines, line)
    if line =~# '\m\C='
      " a posible = of an assignment or option, let's save its info
      let equal_string = matchstr(line, '\m\C^[^=]\{}\%(::\ze=\|[^:]=\s*\|$\)')
      let equal_index = i
    endif
    let lnum -= 1
    let line = getline(lnum)
    let i -= 1
  endwhile
  if empty(lines) || len(lines) == 1
    " not a continued line
    return 0
  endif
  if equal_index < -2
    " the first equal sign in not on the previous line, copy the indentation
    return indent(v:lnum - 1)
  endif
  if equal_index == -2
    " the first equal sign is in the previous line, align with it
    return strdisplaywidth(equal_string)
  endif
  let indent_label = 'vimpeg_indent_continued'
  let multiplier = get(b:, indent_label, get(g:, indent_label, 3))
  return shiftwidth() * multiplier
endfunction

let &cpo = s:save_cpo
unlet! s:save_cpo

" Template From: https://github.com/dahu/Area-41/
" vim: set sw=2 sts=2 et fdm=marker:
