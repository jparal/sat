pro wr,file,a,compress=compress
if not(keyword_set(compress))then begin
  compress=0
 if STREGEX(file,'.gz',/boo) then compress=1
endif
iunit=9
ss=size(a)
openw,iunit,file,compress=compress
printf,iunit,ss(1:ss(0))
printf,iunit,a
close,iunit
return
end
