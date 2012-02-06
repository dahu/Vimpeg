let &rtp = expand('<sfile>:p:h:h:h:h:h').'/vimpeg,'.&rtp.','.expand('<sfile>:p:h:h:h:h:h').'/vimpeg/after'
let &rtp = expand('<sfile>:p:h:h:h:h:h').'/runVimTests,'.&rtp
let &rtp = expand('<sfile>:p:h:h:h:h:h').'/vimtap,'.&rtp
let &rtp = expand('<sfile>:p:h:h').','.&rtp
