" Vim library file
" Description:	Vimpeg - A PEG parser for Vim.
" Maintainers:	Barry Arthur & Israel Chauca
" Version:	0.2
" Last Change:	2011 10 24
" License:	Vim License (see :help license)
" Location:	autoload/vimpeg.vim
" Status:	functional, if not beautiful

"TODO:
" * Currently returns an 'elements' list of all matches - this might be useful
"   in debugging, but not particularly useful afterwards.
" * The predicates 'collect' successful matches (even though the input scanner
"   is repositioned to before the predicated element. I'm not sure if
"   collecting the match is beneficial or even desired. It doesn't hurt
"   scanning, but the semantic 'on_match' functions will need to know that
"   there is an extra element in the 'value' list.
" * There are a bunch of TODO statements littering the code - they need doing
"   too. :)

" HISTORY:
" 0.2 - PEG DSL Release
"   Uses a PEG DSL for describing parsers instead of the manual programmatic
"   API approach.
"   Cleaned up to be usr_41 compliant.
"
" 0.1 - Initial Release
"   Functional PEG parser generator using programmatic API.
"   Bundled with various examples.

if exists("g:loaded_vimpeg_lib")
"      \ || v:version < 700 || &compatible
  "finish
endif
let g:loaded_vimpeg_lib = 1

" Allow use of line continuation.
let vimpeg_save_cpo = &cpo
set cpo&vim

" memoization
let s:sym = 0
function! NextSym()
  let s:sym += 1
  return s:sym
endfunction

function! vimpeg#parser(options) abort
  let peg = {}
  let peg.optSkipWhite = get(a:options, 'skip_white', 0)
  let peg.optIgnoreCase = get(a:options, 'ignore_case', 0)
  let peg.optMemoization = get(a:options, 'memoization', 1)
  let peg.Symbols = {}
  let peg.Cache = {}                " memoization
  let peg.Expression = {}
  let peg.Expression.parent = peg
  let peg.Expression.value = []
  let peg.Expression.id = ''
  let peg.Expression.sym = 0  " memoization
  let peg.Expression.debug = get(a:options, 'debug', 0)
  let peg.Expression.debug_ids = split(get(a:options, 'debug_ids', ''), '\s*,\s*')
  let peg.Expression.verbose = get(a:options, 'verbose', 0)

  func peg.callback(func, args) dict abort
    if (type(a:func) == type('')) && (a:func =~ '\.')
      let func = (a:func =~ '^\a:' ? '' : 'g:').a:func
      let dict = substitute(func, '^\(.*\)\..\+', '\1', '')
      let cmd = 'call('.func.', [a:args], '.dict.')'
      exec 'return '.cmd
    else
      return call(a:func, [a:args])
    endif
  endfunction

  func peg.GetSym(id) dict abort
    let id = a:id
    if type(id) == type("")
      if !has_key(self.Symbols, id)
        echoerr "Error: GetSym() : Symbol '" . id . "' is undefined."
      else
        return self.Symbols[id]
      endif
    elseif type(id) == type({})
      return id
    else
      echoerr "Error: GetSym() : Unknown id type: " . type(id)
    endif
  endfunc

  func peg.AddSym(symbol) dict abort
    let symbol = a:symbol
    " TODO: For now, don't allow symbol redefinition. May reverse this later.
    if !has_key(self.Symbols, symbol['id'])
      let self.Symbols[symbol['id']] = symbol
      return symbol
    else
      echoerr "Error: AddSym() : Symbol '" . symbol['id'] . "' already defined."
    endif
  endfunc

  " memoization
  func peg.MkSym(pos, sym) dict
    return a:pos . '_' . a:sym
  endfunc

  func peg.CacheClear() dict
   let self.Cache = {}
  endfunc

  func peg.CacheGet(pos, sym) dict
   return get(self.Cache, self.MkSym(a:pos, a:sym), '')
  endfunc

  func peg.CacheSet(pos, sym, obj) dict
    let self.Cache[self.MkSym(a:pos, a:sym)] = a:obj
  endfunc

  func peg.Expression.CacheClear() dict
    return self.parent.CacheClear()
  endfunc

  func peg.Expression.CacheGet(pos, sym) dict
    return self.parent.CacheGet(a:pos, a:sym)
  endfunc

  func peg.Expression.CacheSet(pos, sym, obj) dict
    return self.parent.CacheSet(a:pos, a:sym, a:obj)
  endfunc

  func peg.Expression.AddSym(symbol) dict  abort "{{{2
    return self.parent.AddSym(a:symbol)
  endfunc

  func peg.Expression.GetSym(id) dict  abort "{{{2
    return self.parent.GetSym(a:id)
  endfunc

  func peg.Expression.SetOptions(options) dict  abort "{{{2
    for o in ['id', 'debug', 'debug_ids', 'verbose', 'on_match']
      if has_key(a:options, o)
        exe "let self." . o . " = a:options['" . o . "']"
      endif
    endfor
  endfunc
  func peg.Expression.Copy(...) dict  abort "{{{2
    let e = copy(self)
    if a:0
      call e.SetOptions(a:000[0])
    endif
    return e
  endfunc

  " (input, [{id,debug,verbose}])
  func peg.Expression.new(pat, ...) dict  abort "{{{3
    let e = self.Copy(a:0 ? a:000[0] : {})
    let e.pat = a:pat
    let e.sym = NextSym()
    if e.id != ''
      call self.AddSym(e)
    endif
    return e
  endfunc
  func peg.Expression.matcher(input) dict  abort "{{{3
    let errmsg = ''
    let is_matched = 1
    let ends = [0,0]
    "echo "peg.Expression: " . string(a:input) . ' ' . string(self.pat)
    let ends[0] = match(a:input.str, '\m'.self.pat, a:input.pos)
    let ends[1] = matchend(a:input.str, '\m'.self.pat, a:input.pos)
    if ends[0] != a:input.pos
      let errmsg = "Failed to match '".self.id."' /". self.pat . "/ at byte " . a:input.pos . " on '" . a:input.str[a:input.pos : a:input.pos + 30] . "'"
      if self.verbose == 2
        "echom "peg.Expression: " . string(a:input) . ' ' . string(self.pat)
        echohl WarningMsg
        echom errmsg
        echohl None
      endif
      let ends = [a:input.pos,a:input.pos]
      let is_matched = 0
    end
    if is_matched
      if self.verbose
        "echom "peg.Expression: " . string(a:input) . ' ' . string(self.pat)
        echom "Matched '".self.id."' /". self.pat . "/ at byte " . a:input.pos . " on '" . a:input.str[a:input.pos : a:input.pos + 30] . "'"
      endif
      let self.value = strpart(a:input.str, ends[0], ends[1] - ends[0])
      if has_key(self, 'on_match')
        let self.value = self.parent.callback(self.on_match, self.value)
      endif
    endif
    return {'id' : self.id, 'pattern' : self.pat, 'ends' : ends, 'pos': ends[1], 'value' : self.value, 'is_matched': is_matched, 'errmsg': errmsg}
  endfunc
  func peg.Expression.skip_white(input) dict  abort "{{{3
    if self.parent.optSkipWhite == 1
      if match(a:input.str, '\s\+', a:input.pos) == a:input.pos
        let a:input.pos = matchend(a:input.str, '\s\+', a:input.pos)
      endif
    endif
  endfunc
  func peg.Expression.match(input) dict "{{{3
    let self.value = []
    let save_ic = &ic
    call self.CacheClear()  " memoization
    let &ignorecase = self.parent.optIgnoreCase ? 1 : 0
    try
      let result = self.pmatch({'str': a:input, 'pos': 0})
    catch /^Failed to match Committed Sequence/
      let result = self.parent.commit_result
    finally
      let &ignorecase = save_ic
    endtry
    return result
  endfunc
  func peg.Expression.breakadd() dict "{{{3
    " Add a breakpoint if the id is in the debug_ids option.
    if self.debug && index(self.debug_ids, get(self, 'id', '')) > -1
      let fname = matchstr(expand('<sfile>'), '\w\+\ze\.\.\w\+$')
      echom 'Adding breakpoint for "'.self.id.'" in function {' . fname . '}'
      exec 'breakadd func 3 {' . fname . '}'
      return 1
    endif
    return 0
  endfunc

  func peg.Expression.pmatch(input) dict  abort "{{{3
    if self.breakadd()
      " Remove the breakpoint until it's needed again.
      exec 'breakdel func 3 {'.matchstr(expand('<sfile>'), '\w\+$').'}'
    endif
    let save = a:input.pos
    call self.skip_white(a:input)

    " memoization
    let pos = a:input.pos
    let c = self.CacheGet(pos, self.sym)
    if self.parent.optMemoization && type(c) == type({})
      let m = c
    else
      let m = self.matcher(a:input)
      call self.CacheSet(pos, self.sym, m)
    endif

    if !m['is_matched']
      let a:input.pos = save
    else
      let a:input.pos = m['pos']
    endif
    return m
  endfunc

  let peg.ExpressionSequence = copy(peg.Expression) "{{{2
  func! peg.ExpressionSequence.new(seq, ...) dict  abort "{{{3
    let e = self.Copy(a:0 ? a:000[0] : {})
    let e.seq = a:seq
    let e.sym = NextSym()
    if e.id != ''
      call self.AddSym(e)
    endif
    return e
  endfunc
  " TODO: make it backtrack!
  func! peg.ExpressionSequence.matcher(input) dict  abort "{{{3
    let elements = []
    let is_matched = 1
    let errmsg = ''
    let committed = 0
    " TODO: should this be -1 or 0?
    let pos = -1
    try
      for s in self.seq
        let e = copy(self.GetSym(s))
        let e.elements = []
        if get(e, 'type', '') == 'commit'
          let committed += 1
        endif
        let m = e.pmatch(a:input)
        " BEA: Expermineting with adding even possible fails for errmsg...
        call add(elements, m)
        if !m['is_matched']
          let is_matched = 0
          if committed
            let errmsg = "Failed to match Committed Sequence at byte " . a:input.pos
            if self.verbose
              echohl ErrorMsg
              echom errmsg
              echohl None
            endif
            " XXX: Is this the best approach to bring the info upstairs?
            let self.parent.commit_result = {'id': self.id, 'elements': elements, 'pos': pos, 'value': self.value, 'is_matched': is_matched, 'errmsg': errmsg}
            throw errmsg
          endif
          break
        endif
        " TODO: do I need to delete these elements if not matched?
        "call add(elements, m)
        unlet s
        unlet m
      endfor
    endtry
    if is_matched
      let pos = elements[-1]['pos']
      let self.value = map(copy(elements), 'v:val["value"]')
      if has_key(self, 'on_match')
        let self.value = self.parent.callback(self.on_match, self.value)
      endif
    else
      let errmsg = "Failed to match Sequence at byte " . a:input.pos
    endif
    return {'id': self.id, 'elements': elements, 'pos': pos, 'value': self.value, 'is_matched': is_matched, 'errmsg': errmsg}
  endfunc

  let peg.ExpressionOrderedChoice = copy(peg.Expression) "{{{2
  func! peg.ExpressionOrderedChoice.new(choices, ...) dict  abort "{{{3
    let e = self.Copy(a:0 ? a:000[0] : {})
    let e.choices = a:choices
    let e.sym = NextSym()
    if e.id != ''
      call self.AddSym(e)
    endif
    return e
  endfunc
  func! peg.ExpressionOrderedChoice.matcher(input) dict  abort "{{{3
    let element = {}
    let is_matched = 0
    let errmsg = ''
    " TODO: -1 or 0?
    let pos = -1
    for c in self.choices
      let e = copy(self.GetSym(c))
      let e.elements = []
      let m = e.pmatch(a:input)
      if m['is_matched']
        let element = m
        let is_matched = 1
        break
      endif
      unlet c
      unlet m
    endfor
    if is_matched
      let pos = element['pos']
      let self.value = element["value"]
      if has_key(self, 'on_match')
        let self.value = self.parent.callback(self.on_match, self.value)
      endif
    else
      let errmsg = "Failed to match Ordered Choice at byte " . a:input.pos
    endif
    return {'id': self.id, 'elements': [element], 'pos': pos, 'value': self.value, 'is_matched': is_matched, 'errmsg': errmsg}
  endfunc

  let peg.ExpressionMany = copy(peg.Expression) "{{{2
  func! peg.ExpressionMany.new(exp, min, max, ...) dict  abort "{{{3
    let e = self.Copy(a:0 ? a:000[0] : {})
    let e.exp = copy(a:exp)
    let e.min = a:min
    let e.max = a:max
    let e.sym = NextSym()
    if e.id != ''
      call self.AddSym(e)
    endif
    return e
  endfunc
  func! peg.ExpressionMany.matcher(input) dict  abort "{{{3
    let is_matched = 1
    let pos = a:input['pos']
    let cnt = 0
    let elements = []
    let e = copy(self.GetSym(self.exp))
    let e.elements = []
    let m = e.pmatch(a:input)
    while m['is_matched']
      call add(elements, m)
      "let a:input.pos = m[1]
      let cnt += 1
      if (self.max != 0) && (cnt >= self.max)
        break
      endif
      " unlet m   ?
      let m = e.pmatch(a:input)
    endwhile
    if cnt < self.min
      " TODO: this should be an error
      if self.verbose
        echohl ErrorMsg
        echom "Failed to match enough repeated items. Needed " . self.min . " but only found " . cnt
        echohl None
      endif
      let is_matched = 0
    endif
    if is_matched
      if cnt != 0
        let pos = elements[-1]['pos']
        let self.value = map(copy(elements), 'v:val["value"]')
        if has_key(self, 'on_match')
          let self.value = self.parent.callback(self.on_match, self.value)
        endif
      endif
    endif
    return {'id': self.id, 'elements': elements, 'pos': pos, 'count': cnt, 'min': self.min, 'max': self.max, 'value': self.value, 'is_matched': is_matched}
  endfunc

  let peg.ExpressionPredicate = copy(peg.Expression) "{{{2
  func! peg.ExpressionPredicate.new(exp, type, ...) dict  abort "{{{3
    let e = self.Copy(a:0 ? a:000[0] : {})
    let e.exp = a:exp
    let e.type = a:type
    let e.sym = NextSym()
    if e.id != ''
      call self.AddSym(e)
    endif
    return e
  endfunc
  func! peg.ExpressionPredicate.matcher(input) dict  abort "{{{3
    let is_matched = 0
    let pos = a:input.pos
    let e = copy(self.GetSym(self.exp))
    let e.elements = []
    let element = e.pmatch(a:input)
    let a:input.pos = pos
    if self.type == 'not_has'         " NO predicate
      let is_matched = !element['is_matched']
    else                              " AND and COMMIT predicates
      let is_matched = element['is_matched']
    endif
    if is_matched
      " TODO: Unsure if it is wise to have this in a predicate... may make for
      " interesting parsers...
      let self.value = element["value"]
      if has_key(self, 'on_match')
        let self.value = self.parent.callback(self.on_match, self.value)
      endif
    endif
    return {'id': self.id, 'elements': [element], 'pos': pos, 'type': self.type, 'value': self.value, 'is_matched': is_matched}
  endfunc

  func peg.e(exp, ...) dict  abort "{{{2
    return self.Expression.new(a:exp, a:0 ? a:000[0] : {})
  endfunc
  func peg.and(seq, ...) dict abort
    return self.ExpressionSequence.new(a:seq, a:0 ? a:000[0] : {})
  endfunc
  func peg.or(choices, ...) dict abort
    return self.ExpressionOrderedChoice.new(a:choices, a:0 ? a:000[0] : {})
  endfunc
  func peg.maybe_many(exp, ...) dict abort
    return self.ExpressionMany.new(a:exp, 0, 0, a:0 ? a:000[0] : {})
  endfunc
  func peg.many(exp, ...) dict abort
    return self.ExpressionMany.new(a:exp, 1, 0, a:0 ? a:000[0] : {})
  endfunc
  func peg.maybe_one(exp, ...) dict abort
    return self.ExpressionMany.new(a:exp, 0, 1, a:0 ? a:000[0] : {})
  endfunc
  func peg.between(exp, min, max, ...) dict abort
    return self.ExpressionMany.new(a:exp, a:min, a:max, a:0 ? a:000[0] : {})
  endfunc
  func peg.has(exp, ...) dict abort
    return self.ExpressionPredicate.new(a:exp, 'has', a:0 ? a:000[0] : {})
  endfunc
  func peg.not_has(exp, ...) dict abort
    return self.ExpressionPredicate.new(a:exp, 'not_has', a:0 ? a:000[0] : {})
  endfunc
  func peg.commit(exp, ...) dict abort
    return self.ExpressionPredicate.new(a:exp, 'commit', a:0 ? a:000[0] : {})
  endfunc
  return peg
endfunction

let &cpo = vimpeg_save_cpo
" unlet vimpeeg_save_cpo

" vim: et sw=2 fdm=marker
