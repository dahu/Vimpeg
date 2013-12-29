" Test expression repetition

let value = many_cats_and_dogs.match('cats dogs dogs cats cats')['value']
echomsg "['cats', 'dogs', 'dogs', 'cats', 'cats']" . " == " . string(value)

let value = sentence2.match('raining cats dogs cats tonight')['value']
echomsg "['raining', ['cats', 'dogs', 'cats'], 'tonight']" . " == " . string(value)

quit!
