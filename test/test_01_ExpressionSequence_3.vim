" Test simple expression sequences of digits and words

let value = nums_times_nums.pmatch({'str' : '123 * 456', 'pos' : 0})['value'][0]
echomsg (123 * 456) . " == " . value

"let value = expr.match({'str' : '123 * 456', 'pos' : 0})['value'][0]
"echomsg (123 * 456) . " == " . value

let result = expr.pmatch({'str' : '123 + 456', 'pos' : 0})
let value = result['value'][0]
echomsg (123 + 456) . " == " . value
quit!
