pro bicoh2d,an,amp,rabc,nxh=nxh,nyh=nyh,verbose=verbose      
ss=size(an)
nx=ss(1)
nz=ss(2)
ny=ss(2)
 if not(keyword_set(nxh))then nxh=nx/2
 if not(keyword_set(nyh))then nyh=nz/2
 if not(keyword_set(verbose))then verbose=0
xnyi=1./float(ny)
xnx=1./sqrt(2*!pi*float(nx)*float(nz)
bic=complexarr(nxh,nxh,nyh,nyh)
xn=fltarr(nxh,nxh,nyh,nyh)
amp=xn
rabc=xn
for j=0,ny-1 do begin
  if(verbose eq 1) print,j
  a=reform(fft(an(*,j),1))/xnx  
print,'starting j=',j
    for ia=0,nxh-1 do begin
    for ib=0,nxh-ia-1 do begin
    for iay=0,nyh-1 do begin
    for iby=0,nyh-iay-1 do begin
      ai=a(ia,iay)
      bi=a(ib,iby)
      ic=ia+ib
      icy=iay+iby
      ci=a(ic,icy) 
      amp(ia,ib,iay,iby)=amp(ia,ib,iay,iby) $
         +abs(ai)^samp(0)*abs(bi)^samp(1)*abs(ci)^samp(2)
      com=ai*bi*conj(ci)
      bic(ia,ib,iay,iby)=bic(ia,ib,iay,iby)+com
      xn(ia,ib,iay,iby)=xn(ia,ib,iay,iby)+abs(com)     
    endfor
    endfor
    endfor
  endfor
endfor
bic=bic*xnyi
xn=xn*xnyi
amp=amp*xnyi
bic=abs(bic)
for ia=0,nxh-1 do begin
  for ib=0,nxh-ia-1 do begin
    for iay=0,nyh-1 do begin
    for iby=0,nyh-iay-1 do begin
    rabc(ia,ib)=bic(ia,ib)/xn(ia,ib)     
   endfor
   endfor
  endfor
endfor      
end
