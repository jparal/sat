pro rd4u,file,a
iunit=9
if(fexist(file,first=first))then begin
 n1=1l
 n2=1l
 n3=1l
 n4=1l
  openr,iunit,first,/compress 
  readu,iunit,n1,n2,n3,n4
endif else begin
   return
endelse
a=fltarr(n1,n2,n3,n4)
readu,iunit,a
close,iunit
return
end
