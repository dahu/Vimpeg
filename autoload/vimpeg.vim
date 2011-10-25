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
let s:save_cpo = &cpo
set cpo&vim

function! vimpeg#parser(options) abort
  let peg = {}
  let peg.optSkipWhite = 0
  let peg.Symbols = {}
  let peg.Expression = {}
  let peg.Expression.parent = peg
  let peg.Expression.value = []
  let peg.Expression.id = ''
  let peg.Expression.debug = 0
  let peg.Expression.verbose = 0

  if has_key(a:options, 'skip_white')
    let peg.optSkipWhite = a:options['skip_white']
  endif

  func peg.callback(func, args) dict abort
    if a:func =~ '\.'
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
        echoerr "Error: GetSym() : Symbol " . id . " is undefined."
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
      echoerr "Error: AddSym() : Symbol " . symbol['id'] . " already defined."
    endif
  endfunc

  func peg.Expression.AddSym(symbol) dict  abort"{{{2
    return self.parent.AddSym(a:symbol)
  endfunc

  func peg.Expression.GetSym(id) dict  abort"{{{2
    return self.parent.GetSym(a:id)
  endfunc

  func peg.Expression.SetOptions(options) dict  abort"{{{2
    for o in ['id', 'debug', 'verbose', 'on_match']
      if has_key(a:options, o)
        exe "let self." . o . " = a:options['" . o . "']"
      endif
    endfor
  endfunc
  func peg.Expression.Copy(...) dict  abort"{{{2
    let e = copy(self)
    if a:0
      call e.SetOptions(a:000[0])
    endif
    return e
  endfunc

  " (input, [{id,debug,verbose}])
  func peg.Expression.new(pat, ...) dict  abort"{{{3
    let e = self.Copy(a:0 ? a:000[0] : {})
    let e.pat = a:pat
    if e.id != ''
      call self.AddSym(e)
    endif
    return e
  endfunc
  func peg.Expression.matcher(input) dict  abort"{{{3
    let errmsg = ''
    let is_matched = 1
    let ends = [0,0]
    let ends[0] = match(a:input.str, self.pat, a:input.pos)
    let ends[1] = matchend(a:input.str, self.pat, a:input.pos)
    if ends[0] != a:input.pos
      let errmsg = "Failed to match /". self.pat . "/ at byte " . a:input.pos
      if self.verbose
        echoerr errmsg
      endif
      let ends = [a:input.pos,a:input.pos]
      let is_matched = 0
    end
    if is_matched
      let self.value = strpart(a:input.str, ends[0], ends[1] - ends[0])
      if has_key(self, 'on_match')
        let self.value = self.parent.callback(self.on_match, self.value)
      endif
    endif
    return {'id' : self.id, 'pattern' : self.pat, 'ends' : ends, 'pos': ends[1], 'value' : self.value, 'is_matched': is_matched, 'errmsg': errmsg}
  endfunc
  func peg.Expression.skip_white(input) dict  abort"{{{3
    if self.parent.optSkipWhite == 1
      if match(a:input.str, '\s\+', a:input.pos) == a:input.pos
        let a:input.pos = matchend(a:input.str, '\s\+', a:input.pos)
      endif
    endif
  endfunc
  func peg.Expression.match(input) dict  abort"{{{3
    let self.value = []
    return self.pmatch({'str': a:input, 'pos': 0})
  endfunc
  func peg.Expression.pmatch(input) dict  abort"{{{3
    let save = a:input.pos
    call self.skip_white(a:input)
    let m = self.matcher(a:input)
    " TODO: Prove this logic right
    if !m['is_matched']
      let a:input.pos = save
    else
      let a:input.pos = m['pos']
    endif
    return m
  endfunc

  let peg.ExpressionSequence = copy(peg.Expression) "{{{2
  func! peg.ExpressionSequence.new(seq, ...) dict  abort"{{{3
    let e = self.Copy(a:0 ? a:000[0] : {})
    let e.seq = a:seq
    if e.id != ''
      call self.AddSym(e)
    endif
    return e
  endfunc
  " TODO: make it backtrack!
  func! peg.ExpressionSequence.matcher(input) dict  abort"{{{3
    let elements = []
    let is_matched = 1
    let errmsg = ''
    " TODO: should this be -1 or 0?
    let pos = -1
    for s in self.seq
      let e = copy(self.GetSym(s))
      let e.elements = []
      let m = e.pmatch(a:input)
      " BEA: Expermineting with adding even possible fails for errmsg...
      call add(elements, m)
      if !m['is_matched']
        let is_matched = 0
        break
      endif
      " TODO: do I need to delete these elements if not matched?
      "call add(elements, m)
      unlet s
    endfor
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
  func! peg.ExpressionOrderedChoice.new(choices, ...) dict  abort"{{{3
    let e = self.Copy(a:0 ? a:000[0] : {})
    let e.choices = a:choices
    if e.id != ''
      call self.AddSym(e)
    endif
    return e
  endfunc
  func! peg.ExpressionOrderedChoice.matcher(input) dict  abort"{{{3
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
  func! peg.ExpressionMany.new(exp, min, max, ...) dict  abort"{{{3
    let e = self.Copy(a:0 ? a:000[0] : {})
    let e.exp = copy(a:exp)
    let e.min = a:min
    let e.max = a:max
    if e.id != ''
      call self.AddSym(e)
    endif
    return e
  endfunc
  func! peg.ExpressionMany.matcher(input) dict  abort"{{{3
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
      let m = e.pmatch(a:input)
    endwhile
    if cnt < self.min
      " TODO: this should be an error
      if self.verbose
        echo "Failed to match enough repeated items. Needed " . self.min . " but only found " . cnt
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
  func! peg.ExpressionPredicate.new(exp, type, ...) dict  abort"{{{3
    let e = self.Copy(a:0 ? a:000[0] : {})
    let e.exp = a:exp
    let e.type = a:type
    if e.id != ''
      call self.AddSym(e)
    endif
    return e
  endfunc
  func! peg.ExpressionPredicate.matcher(input) dict  abort"{{{3
    let is_matched = 0
    let pos = a:input.pos
    let e = copy(self.GetSym(self.exp))
    let e.elements = []
    let element = e.pmatch(a:input)
    let a:input.pos = pos
    if self.type == 'has'         " AND predicate
      let is_matched = element['is_matched']
    elseif self.type == 'not_has' " NOT predicate
      let is_matched = !element['is_matched']
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

  func peg.e(exp, ...) dict  abort"{{{2
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
  return peg
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: et sw=2 fdm=marker
