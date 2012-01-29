" Vim filetype plugin file
" Language:	VimPEG
" Maintainer:	Israel Chauca <israelchauca@gmail.com>
" Version:	%Version%
" Last Change:	%Date%
" License:	Vim License (see :help license)
" Location:	ftplugin/%Plugin_File%

" Only do this when not done yet for this buffer
if exists("b:did_ftplugin")
  finish
endif

" Don't load another filetype plugin for this buffer
let b:did_ftplugin = 1

" Allow use of line continuation.
let s:save_cpo = &cpo
set cpo&vim

" Restore things when changing filetype.
let b:undo_ftplugin = "sil! iunmap :| setl fo< com< ofu<"

" Configure the matchit plugin.
let b:match_words = &matchpairs
let b:match_skip = 's:comment\|string\|character'
"let b:match_ignorecase = 1

" Set 'formatoptions' to break comment lines but not other lines,
" and insert the comment leader when hitting <CR> or using "o".
setlocal fo-=t fo+=croql

" Set completion with CTRL-X CTRL-O to autoloaded function.
"if exists('&ofu')
"  setlocal ofu=%FileType%complete#Complete
"endif

" A little help to speed typing the mallet.
silent! ino <unique><buffer><expr> : getline('.') =~ '\m^\s*\h\w*\s*[^:]*$' ? '::= ' : ':'

" Set 'comments'.
"setlocal comments&

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: et sw=2

