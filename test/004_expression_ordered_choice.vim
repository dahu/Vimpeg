call vimtest#StartTap()
call vimtap#Plan(4) " <== XXX  Keep plan number updated.  XXX

func! Grammar(p)
  let p = a:p
  call p.or([p.e('one'), p.e('two'), p.e('three')], {'id': 'exp'})
endfunc

" G() is defined in _setup.vim
call G({'skip_white': 1}, 'exp', 'Grammar')

call Is(V('one')   , 'one')
call Is(V('two')   , 'two')
call Is(V('three') , 'three')
call Is(M('four')  , 0)

call vimtest#Quit()
