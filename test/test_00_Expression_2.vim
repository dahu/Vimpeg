" Test simple expression matching digits with on_match evaluation

let value_1 = digits.match('12')['value']
let value_2 = digits.match('23')['value']
let result = 35
echomsg result . " == " . (value_1 + value_2)
quit!
