" Test simple expression matching digits with on_match evaluation

let value_1 = digits.pmatch({'str' : '12', 'pos' : 0})['value'][0]
let value_2 = digits.pmatch({'str' : '23', 'pos' : 0})['value'][0]
let result = 35
echomsg result . " == " . (value_1 + value_2)
quit!
