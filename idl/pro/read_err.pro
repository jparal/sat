; reads output from quatsat
; n1,n2,xmin,xmax,ymin,ymax,f
;.r
file='errors'
iunit=42
openr,iunit,file
readf,iunit, n1,n2,xmin,xmax,ymin,ymax
f=fltarr(n1,n2)
readf,iunit,f
close, iunit
ix=findgen(n1)*(xmax-xmin)/(n1-1)+xmin
iy=findgen(n2)*(ymax-ymin)/(n1-1)+ymin
end
