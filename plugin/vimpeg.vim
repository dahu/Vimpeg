" Vim global plugin file
" Description:	Vimpeg - A PEG parser for Vim.
" Maintainer:	Barry Arthur & Israel Chauca
" Version:	0.2
" Last Change:	2011 10 24
" License:	Vim License (see :help license)
" Location:	plugin/vimpeg.vim

if exists('g:loaded_vimpeg')
"      \ || v:version < 700 || &compatible
  finish
endif
let g:loaded_vimpeg = 1

let g:vimpeg_version = '0.2'
finish
" Allow use of line continuation.
let s:save_cpo = &cpo
set cpo&vim

" TODO: what should we do with this file besides using it to set vimpeg's
" version?

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: et sw=2
