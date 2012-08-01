" Walker for AST built by VimPEG
" Barry Arthur, 2012 08 01

exe "so " . expand('<sfile>:h'). '/../autoload/ast.vim'
exe "so " . expand('<sfile>:h'). '/../autoload/unicorns.vim'

" The Walk() function should probably go in VimPEG or an AST sub-lib
func! Walk(ast, visitor)
  let val = []
  for node in a:ast
    if type(node) == type([])
      "echo node
      call add(val, call(a:visitor[node[0]], [node[1]], a:visitor))
    endif
    unlet node
  endfor
  return join(val)
endfunc

" rainbows and unicorns
function! RnU()
  let rnu = {}
  let rnu.case = 'normalcase'
  func rnu.apply(func, args) dict
    return join(map(a:args, 'call(a:func, [v:val], self)'))
  endfunc
  func rnu.P(args) dict
    return self.apply(self.case, a:args)
  endfunc
  func rnu.N(args) dict
    let self.case = self.normalcase
    return self.apply(self.case, a:args)
  endfunc
  func rnu.U(args) dict
    let self.case = 'toupper'
    return self.apply(self.case, a:args)
  endfunc
  func rnu.L(args) dict
    let self.case = 'tolower'
    return self.apply(self.case, a:args)
  endfunc
  func rnu.T(args) dict
    let self.case = self.titlecase
    return self.apply(self.case, a:args)
  endfunc
  func rnu.C(args) dict
    return '<color '. a:args[0] .'>' . self.apply(self.case, a:args[1]) . '</color>'
  endfunc
  " dictless helpers
  func rnu.normalcase(args)
    return a:args
  endfunc
  func rnu.titlecase(args)
    return substitute(a:args, '\(\w\)\(\w\+\)', '\u\1\L\2', 'g')
  endfunc
  return rnu
endfunction

function! Unicorns_AST(string)
  return g:rnu#parser.match(a:string).value
endfunction

let ast = Unicorns_AST('P T unicorns now served with U lots of C red extra cheese N aNd sAuCe!')
echo ast
echo Walk(ast, RnU())
