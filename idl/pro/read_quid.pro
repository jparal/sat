; reads output from quatsat
; m tt xx yy bb bbx -> num t x y bz bx
;.r
file='quid'
iunit=42
openr,iunit,file
m=0
readf,iunit,m
t=fltarr(m)
x=t
y=t
bz=t
bx=t
readf,iunit,t,x,y,bz,bx
close, iunit
end
