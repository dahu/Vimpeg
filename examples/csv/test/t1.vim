so ../autoload/csv.vim
so ../autoload/csv_parser.vim
so ../plugin/csv_parser.vim
edit sample.csv
%call Parse_CSV('g:recs')
enew
call Print_CSV(g:recs)
write sample_out.csv
quit
