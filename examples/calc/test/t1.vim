so ../plugin/calculator.vim
function! Test()
  echo (45 + 123)                  . '==' . Calc('45 + 123')
  echo (123 - 45)                  . '==' . Calc('123 - 45')
  echo (123 * 45)                  . '==' . Calc('123 * 45')
  echo (123 / 45)                  . '==' . Calc('123 / 45')
  echo (14 + 15 * 3 + 2 * (5 - 7)) . '==' . Calc('14 + 15 * 3 + 2 * (5 - 7)')
  echo (10 + 2 / 3 * 4 + (5 - 6))  . '==' . Calc('10 + 2 / 3 * 4 + (5 - 6)')
endfunction

if 1
  call Test()
else
  profile start calc.prof
  profile func Test
  for x in range(10)
    silent call Test()
  endfor
  quit
endif
