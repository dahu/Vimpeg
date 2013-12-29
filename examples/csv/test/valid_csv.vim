" Test RegEx strings.
call vimtest#StartTap()

let test_files = split(glob("valid/valid_*.csv"), "\n")

" Plan to run a lot of tests.
call vimtap#Plan(len(test_files)*2)
let match = 1

" loop over valid csv files
for test in test_files

  " Run test:
  let csv_data  = join(readfile(test), "\n")
  let csv_value = eval(join(readfile(fnamemodify(test, ':r').'.dump'), ""))
  silent let result = csv#parser.match(csv_data)

  let passed = result.is_matched
  "" Report:
  let msg = csv_data . ' is ' . (match ? '' : 'not ') .
        \ 'valid and it was ' . (result.is_matched ? '' : 'not ') . 'matched.'
  call vimtap#Ok(passed, 'passed', msg)

  " Did it parse it as expected?
  let passed = string(csv_value) == string(result.value)
  let msg = csv_data . ' was ' . (passed ? '' : 'not ') .
        \ 'parsed as expected => ' . string(csv_value) . ' vs ' . string(result.value)
  call vimtap#Ok(passed, 'passed', msg)
endfor

call vimtest#Quit()
" vim:sw=2 et sts=2
