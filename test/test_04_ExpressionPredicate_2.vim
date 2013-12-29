" Test expression predicate: has_not

let value = foo_not_followed_by_digits.match('foo bar')['value']
echomsg "['foo', []]" . " == " . string(value)

let result = foo_not_followed_by_digits_2.match('foo bar')
echomsg "1" . " == " . result['is_matched']
let value = result['value']
echomsg "[['foo', []], 'bar']" . " == " . string(value)
quit!
