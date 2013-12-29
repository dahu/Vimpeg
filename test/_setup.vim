let peg = vimpeg#parser({'skip_white': 1})

" reused grammar elements
let digits = peg.e('\d\+', {'id': 'digits', 'on_match': 'str2nr'})
let words = peg.e('\w\+', {'id': 'words'})
let nums_words = peg.and(['digits', 'words'], {'id': 'nums_words'})

func! Plus(elems)
  return a:elems[0] + a:elems[2]
endfunc

let plus = peg.e('+', {'id': 'plus'})
let nums_plus_nums = peg.and(['digits', 'plus', 'digits'], {'id': 'nums_plus_nums', 'on_match': 'Plus'})

func! Times(elems)
  return a:elems[0] * a:elems[2]
endfunc

let times = peg.e('\*', {'id': 'times'})
let nums_times_nums = peg.and(['digits', 'times', 'digits'], {'id': 'nums_times_nums', 'on_match': 'Times'})

let expr = peg.or(['nums_times_nums', 'nums_plus_nums'], {'id': 'expr'})

let raining = peg.e('raining', {'id': 'raining'})
let cats = peg.e('cats', {'id': 'cats'})
let dogs = peg.e('dogs', {'id': 'dogs'})
let tonight = peg.e('tonight', {'id': 'tonight'})
let sentence = peg.and(['raining', peg.or(['cats', 'dogs']), 'tonight'], {'id': 'sentence'})

" ExpressionMany
" 1 - many
let many_cats_and_dogs = peg.many(peg.or(['cats', 'dogs']), {'id': 'many_cats_and_dogs'})
let sentence2 = peg.and(['raining', 'many_cats_and_dogs', 'tonight'])

"2 - maybe many

" coming

" ExpressionPredicate
" 1 - has

let foo_followed_by_digits = peg.and([peg.e('foo'), peg.has('digits')], {'id': 'foo_followed_by_digits'})
let foo_followed_by_digits_2 = peg.and(['foo_followed_by_digits', 'digits'], {'id': 'foo_followed_by_digits_2'})

let foo_not_followed_by_digits = peg.and([peg.e('foo'), peg.not_has('digits')], {'id': 'foo_not_followed_by_digits'})
let foo_not_followed_by_digits_2 = peg.and(['foo_not_followed_by_digits', 'words'], {'id': 'foo_not_followed_by_digits_2'})

