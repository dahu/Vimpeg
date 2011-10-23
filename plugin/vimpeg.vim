" Vim global plugin file
" Description:	%Plugin% provides some nice feature.
" Maintainer:	%Maintainer% <%Email%>
" Version:	%Version%
" Last Change:	%Date%
" License:	Vim License (see :help license)
" Location:	plugin/%Plugin_File%

if exists("g:loaded_vimpeg")
"      \ || v:version < 700 || &compatible
  finish
endif
let g:loaded_vimpeg = 1

" Allow use of line continuation.
let s:save_cpo = &cpo
set cpo&vim

if !exists(':VimPEG')
  command -nargs=* -range=% -bang -bar VimPEG
        \ <line1>,<line2>call vimpeg#peg#writefile(<bang>0, [<f-args>])
endif

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: et sw=2
