so ../plugin/calculator.vim
profile start calc.prof
function! Test()
  silent echo (45 + 123)                  . '==' . Calc('45 + 123')
  silent echo (123 - 45)                  . '==' . Calc('123 - 45')
  silent echo (123 * 45)                  . '==' . Calc('123 * 45')
  silent echo (123 / 45)                  . '==' . Calc('123 / 45')
  silent echo (14 + 15 * 3 + 2 * (5 - 7)) . '==' . Calc('14 + 15 * 3 + 2 * (5 - 7)')
  silent echo (10 + 2 / 3 * 4 + (5 - 6))  . '==' . Calc('10 + 2 / 3 * 4 + (5 - 6)')
endfunction
profile func Test
for x in range(100)
  call Test()
endfor
quit
