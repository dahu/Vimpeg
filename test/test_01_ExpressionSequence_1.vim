" Test simple expression sequences of digits and words

echomsg string(words.pmatch({'str' : 'hello', 'pos' : 0}))
echomsg string(nums_words.pmatch({'str' : '123 abc', 'pos' : 0}))
let value = nums_words.pmatch({'str' : '123 abc', 'pos' : 0})['value']
echomsg string([[123], ['abc']]) . " == " . string(value)
quit!
