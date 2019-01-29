" Vim syntax file
" Language:	VimPEG
" Maintainer:	Israel Chauca F. <israelchauca@gmail.com>
" Version:	0.1
" Last Change:	Wed Oct 26 20:39:36 2011
" License:	Vim License (see :help license)
" Location:	syntax/vimpeg.vim

" Stop when a (custom) syntax file was already loaded
if exists("b:current_syntax")
  finish
endif

" Allow use of line continuation.
let s:save_cpo = &cpo
set cpo&vim

syn region  vimpegOptRegion     start=/^\s*\./ end=/^\ze\s*\h/ contains=vimpegOption,vimpegComment
syn match   vimpegOption        /^\s*\..*/ contains=vimpegOptLabel,vimpegAssign,vimpegOptValue,vimpegComment,vimpegOptBoolean contained display
syn match   vimpegOptName       /\h\w*/ containedin=vimpegOptLabel contained display
syn match   vimpegOptLabel      /^\s*\.\h\w*/ containedin=vimpegOption contains=vimpegOptName contained display
syn keyword vimpegOptBoolean    true false on off contained
syn match   vimpegOptEqual      /=/ containedin=vimpegOption display

syn region  vimpegDefRegion     start=/^\ze\s*\h/ skip=/./ end=/\%$/ contains=vimpegError,vimpegDefinition,vimpegComment
syn match   vimpegError         /\S/ contained containedin=vimpegDefinition display
syn region  vimpegDefinition    start=/^\s*\ze\h/ skip=/\\\n/ end=/$/ contains=vimpegDefLabel,vimpegDefMallet,vimpegDefTag,vimpegComment contained
syn match   vimpegDefTag        /\h\w*/ contained display
syn match   vimpegDefLabel      /^\s*\h\w*/ contained display
syn match   vimpegDefLimit      /::=/ containedin=vimpegDefinition contained display
syn match   vimpegDefLimit      /|/ containedin=vimpegDefinition contained display
syn match   vimpegDefLimit      /->/ containedin=vimpegDefCallback contained display
syn match   vimpegDefCallback   /->\s*[[:alnum:]_:.#]*\ze\%(\s*;.*\)\?/ containedin=vimpegDefinition display
syn match   vimpegDefSpecial    /[!&]/ containedin=vimpegDefinition contained display
syn match   vimpegDefQuantifier /[?*+]/ containedin=vimpegDefinition contained display
syn match   vimpegDelimiter     /[()]/ contained containedin=vimpegDefinition display

syn match   vimpegContinued     /\\$/ contained containedin=vimpegDefinition display

syn region  vimpegString        matchgroup=vimpegDelimiter start=/'/ skip=/''/ end=/'/ containedin=vimpegOption,vimpegDefinition display oneline
syn region  vimpegString        matchgroup=vimpegDelimiter start=/"/ skip=/\\\\\|\\"/ end=/"/ containedin=vimpegOption,vimpegDefinition display oneline
syn match   vimpegError         /^\s*\..*/ contained display
syn match   vimpegComment       /;.*$/ contains=vimpegTodo display
syn keyword vimpegTodo          TODO FIXME XXX NOTE contained

hi link vimpegOptName		PreProc
hi link vimpegOptEqual		Operator
hi link vimpegOptBoolean	Boolean
hi link vimpegDefLabel		Type
hi link vimpegDefTag		Normal
hi link vimpegDelimiter		Delimiter
hi link vimpegDefLimit		Conditional
hi link vimpegDefQuantifier	Conditional
hi link vimpegDefCallback	Function
hi link vimpegDefSpecial	Special
hi link vimpegContinued 	Special
hi link vimpegDefGroup		Type
hi link vimpegString		String
hi link vimpegComment		Comment
hi link vimpegError		Error
hi link vimpegTodo		Todo

let b:current_syntax = 'vimpeg'

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: et sw=2
