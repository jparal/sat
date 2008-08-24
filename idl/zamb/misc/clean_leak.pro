;
;  CLEAN_LEAK
;
;  finds any lost pointers and cleans them

pro clean_leak, VERBOSE = verbose

ap = ptr_valid(COUNT = s)

print, s, ' leaks found'  

if ((s ne 0) and (Keyword_Set(verbose))) then begin
    for i=0, s-1 do begin
      help, *(ap[i])
    end
end

widget_control, /reset 
close, /all 
heap_gc, VERBOSE = verbose 
ptr_free, ptr_valid()
retall

end