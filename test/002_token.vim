call vimtest#StartTap()
call vimtap#Plan(4) " <== XXX  Keep plan number updated.  XXX

func! Grammar(p)
  let p = a:p
  call p.and([p.t('<'), p.or([p.e('A'), p.e('B')]), p.t('>')], {'id': 'tok'})
endfunc

" G() is defined in _setup.vim
call G({'skip_white': 1}, 'tok', 'Grammar')

call Is(V('<A>')   , ['A'])
call Is(V('<B>')   , ['B'])
call Is(M('<C>')   , 0)
call Is(M('A')     , 0)

call vimtest#Quit()
