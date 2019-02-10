" Only load this indent file when no other was loaded.
if exists('b:did_indent')
   finish
endif
let b:did_indent = 1

" Allow use of line continuation.
"let s:save_cpo = &cpo
"set cpo&vim

setlocal indentexpr=vimpeg#get_indent()
setlocal indentkeys=o,O,!^F

" Restore when changing filetype.
let b:undo_indent = 'setl indentexpr< indentkeys<'

"let &cpo = s:save_cpo
"unlet! s:save_cpo

" Template From: https://github.com/dahu/Area-41/
" vim: set sw=2 sts=2 et fdm=marker:
