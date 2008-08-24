c=complex(-.74543,-.11301) 
i=complex(0.,1.)
xmi=-1.8
ymi=-1.1
xma=1.8
yma=1.1 
m=100
k=80
dx=.004
dy=.003
nx=(xma-xmi)/dx+1
ny=(yma-ymi)/dy+1
ff=fltarr(nx,ny)
for ix=0,nx-1 do begin
print,ix,nx
for iy=0,ny-1 do begin
x=complex(xmi+ix*dx,ymi+iy*dy)
ik=0
kkk: x=x^2+c
ik=ik+1
r=abs(x)^2
if(r le m and ik lt k)then goto, kkk
if(r gt m) then ff(ix,iy)=ik
if(k eq ik) then ff(ix,iy)=0
endfor
endfor
ix=findgen(nx)*dx+xmi
iy=findgen(ny)*dy+ymi
imco,alog(ff+1),ix,iy,/nodata
end
