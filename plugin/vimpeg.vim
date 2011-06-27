" Plugin: Vimpeg - A PEG parser for Vim
" Author: Barry Arthur
" Last Updated: 2011 06 17
" Status: functional, if not beautiful
" Next: Build a parser-generator that reads PEG format and produces Vimpeg calls
"
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

function! Vimpeg()
  let peg = {}
  let peg.Symbols = {}
  let peg.Expression = {}
  let peg.Expression.parent = peg
  let peg.Expression.value = []
  let peg.Expression.id = ''
  let peg.Expression.debug = 0
  let peg.Expression.verbose = 0

  func peg.Expression.AddSym(symbol) dict "{{{2
    let symbol = a:symbol
    " TODO: For now, don't allow symbol redefinition. May reverse this later.
    if !has_key(self.parent.Symbols, symbol['id'])
      let self.parent.Symbols[symbol['id']] = symbol
      return symbol
    else
      echoerr "Error: AddSym() : Symbol " . symbol['id'] . " already defined."
    endif
  endfunc
  func peg.Expression.GetSym(id) dict
    let id = a:id
    if type(id) == type("")
      if !has_key(self.parent.Symbols, id)
        echoerr "Error: GetSym() : Symbol " . id . " is undefined."
      else
        return self.parent.Symbols[id]
      endif
    elseif type(id) == type({})
      return id
    else
      echoerr "Error: GetSym() : Unknown id type: " . type(id)
    endif
  endfunc

  func peg.Expression.SetOptions(options) dict
    for o in ['id', 'debug', 'verbose', 'on_match']
      if has_key(a:options, o)
        exe "let self." . o . " = a:options['" . o . "']"
      endif
    endfor
  endfunc
  func peg.Expression.Copy(...) dict
    let e = copy(self)
    if a:0
      call e.SetOptions(a:000[0])
    endif
    return e
  endfunc

  " (input, [{id,debug,verbose}])
  func peg.Expression.new(pat, ...) dict "{{{2
    let e = self.Copy(a:0 ? a:000[0] : {})
    let e.pat = a:pat
    if e.id != ''
      call self.AddSym(e)
    endif
    return e
  endfunc
  func peg.Expression.matcher(input) dict "{{{3
    let is_matched = 1
    let ends = [0,0]
    let ends[0] = match(a:input.str, self.pat, a:input.pos)
    let ends[1] = matchend(a:input.str, self.pat, a:input.pos)
    if ends[0] != a:input.pos
      if self.verbose
        echo "Failed at byte " . a:input.pos . " while looking for /" . self.pat . "/"
      endif
      let ends = [a:input.pos,a:input.pos]
      let is_matched = 0
    end
    if is_matched
      let self.value = [strpart(a:input.str, ends[0], ends[1] - ends[0])]
      if has_key(self, 'on_match')
        let self.value = [call(self.on_match, [self.value[0]])]
      endif
    endif
    return {'id' : self.id, 'pattern' : self.pat, 'ends' : ends, 'pos': ends[1], 'value' : self.value, 'is_matched': is_matched}
  endfunc
  func peg.Expression.skip_white(input) dict "{{{3
    if match(a:input.str, '\s\+', a:input.pos) == a:input.pos
      let a:input.pos = matchend(a:input.str, '\s\+', a:input.pos)
    endif
  endfunc
  func peg.Expression.match(input) dict
    let self.value = []
    return self.pmatch({'str': a:input, 'pos': 0})
  endfunc
  func peg.Expression.pmatch(input) dict "{{{3
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
  func! peg.ExpressionSequence.new(seq, ...) dict
    let e = self.Copy(a:0 ? a:000[0] : {})
    let e.seq = a:seq
    if e.id != ''
      call self.AddSym(e)
    endif
    return e
  endfunc
  " TODO: make it backtrack!
  func! peg.ExpressionSequence.matcher(input) dict "{{{3
    let elements = []
    let is_matched = 1
    " TODO: should this be -1 or 0?
    let pos = -1
    for s in self.seq
      let e = copy(self.GetSym(s))
      let e.elements = []
      let m = e.pmatch(a:input)
      if !m['is_matched']
        let is_matched = 0
        break
      endif
      " TODO: do I need to delete these elements if not matched?
      call add(elements, m)
      unlet s
    endfor
    if is_matched
      let pos = elements[-1]['pos']
      let self.value = map(copy(elements), 'v:val["value"]')
      if has_key(self, 'on_match')
        let self.value = [call(self.on_match, [self.value])]
      endif
    endif
    return {'id': self.id, 'elements': elements, 'pos': pos, 'value': self.value, 'is_matched': is_matched}
  endfunc

  let peg.ExpressionOrderedChoice = copy(peg.Expression) "{{{2
  func! peg.ExpressionOrderedChoice.new(choices, ...) dict
    let e = self.Copy(a:0 ? a:000[0] : {})
    let e.choices = a:choices
    if e.id != ''
      call self.AddSym(e)
    endif
    return e
  endfunc
  func! peg.ExpressionOrderedChoice.matcher(input) dict "{{{3
    let element = {}
    let is_matched = 0
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
        let self.value = [call(self.on_match, [self.value])]
      endif
    endif
    return {'id': self.id, 'elements': [element], 'pos': pos, 'value': self.value, 'is_matched': is_matched}
  endfunc

  let peg.ExpressionMany = copy(peg.Expression) "{{{2
  func! peg.ExpressionMany.new(exp, min, max, ...) dict
    let e = self.Copy(a:0 ? a:000[0] : {})
    let e.exp = copy(a:exp)
    let e.min = a:min
    let e.max = a:max
    if e.id != ''
      call self.AddSym(e)
    endif
    return e
  endfunc
  func! peg.ExpressionMany.matcher(input) dict "{{{3
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
          let self.value = [call(self.on_match, [self.value])]
        endif
      endif
    endif
    return {'id': self.id, 'elements': elements, 'pos': pos, 'count': cnt, 'min': self.min, 'max': self.max, 'value': self.value, 'is_matched': is_matched}
  endfunc

  let peg.ExpressionPredicate = copy(peg.Expression) "{{{2
  func! peg.ExpressionPredicate.new(exp, type, ...) dict
    let e = self.Copy(a:0 ? a:000[0] : {})
    let e.exp = a:exp
    let e.type = a:type
    if e.id != ''
      call self.AddSym(e)
    endif
    return e
  endfunc
  func! peg.ExpressionPredicate.matcher(input) dict "{{{3
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
        let self.value = [call(self.on_match, [self.value])]
      endif
    endif
    return {'id': self.id, 'elements': [element], 'pos': pos, 'type': self.type, 'value': self.value, 'is_matched': is_matched}
  endfunc

  func peg.e(exp, ...) dict "{{{2
    return self.Expression.new(a:exp, a:0 ? a:000[0] : {})
  endfunc
  func peg.and(seq, ...) dict
    return self.ExpressionSequence.new(a:seq, a:0 ? a:000[0] : {})
  endfunc
  func peg.or(choices, ...) dict
    return self.ExpressionOrderedChoice.new(a:choices, a:0 ? a:000[0] : {})
  endfunc
  func peg.maybe_many(exp, ...) dict
    return self.ExpressionMany.new(a:exp, 0, 0, a:0 ? a:000[0] : {})
  endfunc
  func peg.many(exp, ...) dict
    return self.ExpressionMany.new(a:exp, 1, 0, a:0 ? a:000[0] : {})
  endfunc
  func peg.maybe_one(exp, ...) dict
    return self.ExpressionMany.new(a:exp, 0, 1, a:0 ? a:000[0] : {})
  endfunc
  func peg.between(exp, min, max, ...) dict
    return self.ExpressionMany.new(a:exp, a:min, a:max, a:0 ? a:000[0] : {})
  endfunc
  func peg.has(exp, ...) dict
    return self.ExpressionPredicate.new(a:exp, 'has', a:0 ? a:000[0] : {})
  endfunc
  func peg.not_has(exp, ...) dict
    return self.ExpressionPredicate.new(a:exp, 'not_has', a:0 ? a:000[0] : {})
  endfunc
  return peg
endfunction

"{{{2 Testing

"let p = Vimpeg()

"func! Speak(c)
  "if a:c == 'cats'
    "return "meow!"
  "elseif a:c == 'dogs'
    "return "woof!"
  "endif
"endfunc

""let raining = p.e('raining')
"let cats = p.e('cats', {'id': 'cats', 'on_match' : function('Speak')})
""let cats = p.Expression.new('cats', {'id': 'cats', 'debug': 1})
"echo cats.pmatch({'str' : "cats", 'pos' : 0})
""let v = cats.pmatch({'str' : "cats", 'pos' : 0})['value'][0]
""echo v

"let dogs = p.e('dogs', {'id': 'dogs', 'on_match': function('Speak')})
""let dogs = p.e('dogs')
"let seqq = p.and([cats, dogs])
"echo string(seqq.pmatch({'str' : "cats dogs", 'pos' : 0}))

"let ordd = p.or([cats, dogs])
"let mmny = p.maybe_many(cats)
"let vmny = p.many(cats)
"let mone = p.maybe_one(cats)
"let mbtw = p.between(cats, 2, 3)
"let emny = p.many(p.and([cats, dogs]))
"let hasp = p.and([dogs, p.has(cats)])
"let notp = p.and([dogs, p.not_has(cats)])


"let grammar = peg.compile('and([raining, maybe_many(or([cats, dogs])))')
"let grammar = peg.and([raining, peg.maybe_many(peg.or([cats, dogs])))
"let grammar = peg.and([raining, cats])
"echo grammar.match()
finish

raining cats dogs cats cats dogs

" standard EBNF for PEGs
" NUMBER | "(" & Sum & ")"
" number = p.e('\d\+')
" lb = p.e('(')
" rb = p.e(')')
" p.or([number, p.and([lb, sum, rb])])

" vim: fdm=marker
