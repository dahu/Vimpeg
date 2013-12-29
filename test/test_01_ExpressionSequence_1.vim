" Test simple expression sequences of digits and words

echo words.match('hello')
echo nums_words.match('123abc')
let value = nums_words.match('123abc')['value']
echomsg string([123, 'abc']) . " == " . string(value)
quit!
