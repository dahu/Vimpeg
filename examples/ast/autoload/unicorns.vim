function! unicorns#command(args)
  let cmd = len(a:args[1]) > 0 ? a:args : a:args[0]
  if len(cmd) > 0
    if cmd[0][0] == 'C'
      return [cmd[0][0], [cmd[0][1], cmd[1]]]
    endif
  endif
  return cmd
endfunction

function! unicorns#word(args)
  return a:args[1]
endfunction
