iunit=8
file='  '
read,'filename = ',file
openr, iunit, file
readf,iunit, nx, it
dn=fltarr(nx,it,/nozero)
bx=fltarr(nx,it,/nozero)
by=fltarr(nx,it,/nozero)
bz=fltarr(nx,it,/nozero)
readf,iunit, dn,bx,by,bz
close,iunit

read,'number of files ',nf
dnt=fltarr(nx,nf*it,/nozero)
byt=dnt
bzt=dnt
dnt(*,0:it-1)=dn
byt(*,0:it-1)=by
bzt(*,0:it-1)=bz

for i=1,nf-1 do begin
iunit=8
file='  '
read,'filename = ',file
openr, iunit, file
readf,iunit, nx, it
readf,iunit, dn,bx,by,bz
close,iunit

smi=it*i
sma=smi+it-1
dnt(*,smi:sma)=dn
byt(*,smi:sma)=by
bzt(*,smi:sma)=bz
endfor
end
