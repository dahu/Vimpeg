" Test simple expression sequence and ordered choice of words

let value = sentence.match('raining dogs tonight')['value']
echomsg "['raining', 'dogs', 'tonight']" . " == " . string(value)
let value = sentence.match('raining cats tonight')['value']
echomsg "['raining', 'cats', 'tonight']" . " == " . string(value)
quit!
