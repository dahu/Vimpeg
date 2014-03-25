let &rtp = expand('<sfile>:p:h:h') . ',' . &rtp . ',' . expand('<sfile>:p:h:h') . '/after'

runtime autoload/vimpeg.vim
runtime plugin/vimpeg.vim

let g:parser = {}
func! G(opt, root, callback)
  let  p = vimpeg#parser(a:opt)
  call call(a:callback, [p])
  let  g:parser = p.GetSym(a:root)
endfunc

func! V(val)
  return g:parser.match(a:val)['value']
endfunc

func! M(val)
  return g:parser.match(a:val)['is_matched']
endfunc

func! Is(actual, expected)
  let expected = string(a:expected)
  call vimtap#Is(a:actual, a:expected, expected, expected)
endfunc
