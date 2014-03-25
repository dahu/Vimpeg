call vimtest#StartTap()
call vimtap#Plan(6) " <== XXX  Keep plan number updated.  XXX

func! Grammar(p)
  let p = a:p
  call p.e('\w\+', {'id': 'exp'})
endfunc

" G() is defined in _setup.vim
call G({'skip_white': 1}, 'exp', 'Grammar')

call Is(V('one')   , 'one')
call Is(V('two')   , 'two')
call Is(V('three') , 'three')
call Is(V('four')  , 'four')
call Is(M(' ')     , 0)
call Is(M('.')     , 0)

call vimtest#Quit()
