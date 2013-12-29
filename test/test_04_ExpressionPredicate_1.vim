" Test expression predicate: has

let value = foo_followed_by_digits.match('foo 123')['value']
echomsg "['foo', 123]" . " == " . string(value)

let result = foo_followed_by_digits_2.match('foo 123')
echomsg "1" . " == " . result['is_matched']
let value = result['value']
echomsg "[['foo', 123], 123]" . " == " . string(value)
quit!
