pro mybicoh3,an,bn,cn,amp,rabc       
ss=size(an)
nx=ss(1)
ny=ss(2)
xnyi=1./float(ny)
nxh=nx/2
xnx=1./sqrt(2*!pi*float(nx))
bic=complexarr(nxh,nxh)
xn=fltarr(nxh,nxh)
amp=xn
rabc=xn
for j=0,ny-1 do begin
  a=reform(fft(an(*,j),1))/xnx  
  b=reform(fft(bn(*,j),1))/xnx  
  c=reform(fft(cn(*,j),1))/xnx  
  for ia=1,nxh-1 do begin
    for ib=1,nxh-ia-1 do begin
      ai=a(ia)
      bi=b(ib)
      ic=ia+ib
      ci=c(ic) 
      amp(ia,ib)=amp(ia,ib)+abs(ai)*abs(bi)*abs(ci)
      com=ai*bi*conj(ci)
      bic(ia,ib)=bic(ia,ib)+com/abs(com)
      xn(ia,ib)=xn(ia,ib)+abs(com)     
    endfor
  endfor
endfor
bic=bic*xnyi
xn=xn*xnyi
amp=amp*xnyi
rabc=abs(bic)
;for ia=1,nxh-1 do begin
;  for ib=1,nxh-ia-1 do begin
;    rabc(ia,ib)=bi(ia,ib)/xn(ia,ib)     
;  endfor
;endfor      
end
