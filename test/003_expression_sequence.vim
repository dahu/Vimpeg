call vimtest#StartTap()
call vimtap#Plan(10) " <== XXX  Keep plan number updated.  XXX

func! Grammar(p)
  let p = a:p
  call p.and([p.e('one'), p.e('two'), p.or([p.e('three'), p.e('four')])], {'id': 'seq'})
endfunc

" G() is defined in _setup.vim
call G({'skip_white': 1}, 'seq', 'Grammar')

call Is(V('one two three') , ['one', 'two', 'three'])
call Is(V('one two four')  , ['one', 'two', 'four'])
call Is(M('one')           , 0)
call Is(M('two')           , 0)
call Is(M('one two')       , 0)
call Is(M('three')         , 0)
call Is(M('four')          , 0)
call Is(M('one two one')   , 0)
call Is(M('one two two')   , 0)
call Is(M('one two five')  , 0)

call vimtest#Quit()
