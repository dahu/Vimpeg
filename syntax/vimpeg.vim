" Vim syntax file
" Language:	VimPEG
" Maintainer:	Israel Chauca F. <israelchauca@gmail.com>
" Version:	0.1
" Last Change:	Wed Oct 26 20:39:36 2011
" License:	Vim License (see :help license)
" Location:	syntax/vimpeg.vim

" Quit when a (custom) syntax file was already loaded
if exists("b:current_syntax")
  finish
endif

" Allow use of line continuation.
let s:save_cpo = &cpo
set cpo&vim

syn region  vimpegOptRegion    start=/^\s*\./ end=/^\ze\s*</ contains=vimpegOption,vimpegComment
syn match   vimpegOption       /^\s*\..*/ contains=vimpegOptLabel,vimpegAssign,vimpegOptValue,vimpegComment,vimpegOptBoolean contained
syn match   vimpegOptName      /\h\w*/ containedin=vimpegOptLabel contained
syn match   vimpegOptLabel     /^\s*\.\h\w*/ containedin=vimpegOption contains=vimpegOptName contained
syn keyword vimpegOptBoolean   true false on off contained
syn match   vimpegOptEqual     /=/ containedin=vimpegOption

syn region  vimpegDefRegion    start=/^\ze\s*</ skip=/./ end=/\%$/ contains=vimpegError,vimpegDefinition,vimpegComment
syn region  vimpegDefinition   start=/^\s*\ze</ end=/$/ contains=vimpegLabel,vimpegDefMallet,vimpegDefTag,vimpegComment contained
syn region  vimpegDefTag       matchgroup=vimpegDefLabel start=/</ end=/>/ contained
syn region  vimpegDefLabel     matchgroup=Normal start=/^\s*\zs</ end=/>\ze\s/ containedin=vimpegDefinition contained
syn match   vimpegDefLimit     /::=/ containedin=vimpegDefinition contained
syn match   vimpegDefLimit     /|/ containedin=vimpegDefinition contained
syn match   vimpegDefLimit     /->/ containedin=vimpegDefCallback contained
syn match   vimpegDefCallback  /->\s*[[:alnum:]_:.#]*\ze\%(\s*;.*\)\?/ containedin=vimpegDefinition
syn match   vimpegDefSpecial   /[!&]/ containedin=vimpegDefinition contained
syn match   vimpegDefQuantifier /[?*+]/ containedin=vimpegDefinition contained
syn match   vimpegDelimiter      /[()]/ contained containedin=vimpegDefinition

syn region  vimpegString       matchgroup=vimpegDelimiter start=/'/ skip=/''/ end=/'/ containedin=vimpegOption,vimpegDefinition
syn region  vimpegString       matchgroup=vimpegDelimiter start=/"/ skip=/\\\\\|\\"/ end=/"/ containedin=vimpegOption,vimpegDefinition
syn match   vimpegError        /^\s*\..*/ contained
syn match   vimpegComment      /;.*$/

hi link vimpegOptName      PreProc
hi link vimpegOptEqual     Operator
hi link vimpegOptBoolean   Boolean
hi link vimpegDefLabel     Type
hi link vimpegDefTag       Normal
hi link vimpegDelimiter    Delimiter
hi link vimpegDefLimit     Conditional
hi link vimpegDefQuantifier  Conditional
hi link vimpegDefCallback  Function
hi link vimpegDefSpecial   Special
hi link vimpegDefGroup     Type
hi link vimpegString       String
hi link vimpegComment      Comment
hi link vimpegError        Error

let b:current_syntax = "vimpeg"

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: et sw=2
