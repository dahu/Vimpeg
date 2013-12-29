" Test simple expression matching digits

let value = digits.pmatch({'str' : '12', 'pos' : 0})['value']
let hundred = 100
echo 112 . " == " . (hundred + value)
quit!
