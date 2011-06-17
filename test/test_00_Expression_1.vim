" Test simple expression matching digits

echomsg string(digits.pmatch({'str' : '1', 'pos' : 0}))
echomsg string(digits.pmatch({'str' : '12', 'pos' : 0}))
let value = digits.pmatch({'str' : '12', 'pos' : 0})['value'][0]
let hundred = 100
echomsg 112 . " == " . (hundred + value)
quit!
