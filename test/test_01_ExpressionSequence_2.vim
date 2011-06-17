" Test simple expression sequences of digits and words

let value = nums_plus_nums.pmatch({'str' : '123 + 456', 'pos' : 0})['value'][0]
echomsg (123 + 456) . " == " . value
quit!
