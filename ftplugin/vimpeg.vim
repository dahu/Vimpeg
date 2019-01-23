" Vim filetype plugin file
" Language:	VimPEG
" Maintainer:	Israel Chauca <israelchauca@gmail.com>
" Version:	%Version%
" Last Change:	%Date%
" License:	Vim License (see :help license)
" Location:	ftplugin/%Plugin_File%

" Only do this when not done yet for this buffer
if exists('b:did_ftplugin')
  finish
endif

" Don't load another filetype plugin for this buffer
let b:did_ftplugin = 1

" Allow use of line continuation.
let s:save_cpo = &cpo
set cpo&vim

" Restore things when changing filetype.
let b:undo_ftplugin = 'sil! iunmap :| setl fo< com< ofu<'

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
if get(g:, 'vimpeg_align_mallet', 1) && exists(':Tabular')
  silent! ino <silent><buffer><expr> :
        \ getline('.')[:col('.')] =~ '^\s*\h\w*\s*[^:]*$'
        \ && get(g:, 'vimpeg_align_mallet', 1)
        \   ? '::= ' . "\<C-O>:Tabularize/^[^:]*\\zs::=\<CR>\<C-O>f=\<Del>= "
        \   : ':'
endif

if !exists('*s:test')
  function! s:test() range
    let result = vimpeg#peg#quick_test(getline(a:firstline, a:lastline))
    for key in keys(result)
      echo key . ': ' . string(result[key])
    endfor
  endfunction
endif

if !exists(':VimPEG')
  command! -nargs=* -range=% -bang -bar -buffer VimPEG
        \ <line1>,<line2>call vimpeg#peg#writefile(<bang>0, [<f-args>])
endif

if !exists(':VimPEGTest')
  command! -nargs=0 -range -buffer VimPEGTest <line1>;<line2>call s:test()
endif

if empty(maparg('<Plug>VimPEGTest'))
  noremap <silent><Plug>VimPEGTest :VimPEGTest<CR>
endif
if !hasmapto('<Plug>VimPEGTest', 'nv')
  silent! nmap <buffer><unique><leader><leader> <Plug>VimPEGTest
  silent! xmap <buffer><unique><leader><leader> <Plug>VimPEGTest
endif

" Set 'comments'.
"setlocal comments&

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: et sw=2
