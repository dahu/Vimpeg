" Test simple expression sequences of digits and words

let value = nums_times_nums.match('123*456')['value']
echomsg (123 * 456) . " == " . value

let value = expr.match('123+456')['value']
echomsg (123 + 456) . " == " . value

let value = expr.match('234*456')['value']
echomsg (234 * 456) . " == " . value

quit!
