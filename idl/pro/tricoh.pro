pro bicoh,an,amp,rabc,samp=samp,nxh=nxh      
ss=size(an)
nx=ss(1)
ny=ss(2)
if not(keyword_set(samp))then samp=[1,1,1,1]
 if not(keyword_set(nxh))then nxh=nx/2
xnyi=1./float(ny)
xnx=1./sqrt(2*!pi*float(nx))
bic=complexarr(nxh,nxh,nxh)
xn=fltarr(nxh,nxh,nxh)
amp=xn
rabc=xn
for j=0,ny-1 do begin
  a=reform(fft(an(*,j),1))/xnx  
print,'starting j=',j
    for ia=1,nxh-1 do begin
    for ib=1,nxh-ia-1 do begin
    for id=1,nxh-ia-ib-1
      ai=a(ia)
      bi=a(ib)
      di=a(id)
      ic=ia+ib+id
      ci=a(ic) 
      amp(ia,ib,id)=amp(ia,ib,id)+$ 
          abs(ai)^samp(0)*abs(bi)^samp(1)*abs(ci)^samp(2) $
          *abs(di)^samp(3)
      com=ai*bi*di*conj(ci)
      bic(ia,ib,id)=bic(ia,ib,id)+com
      xn(ia,ib,id)=xn(ia,ib,id)+abs(com)     
      endfor
    endfor
  endfor
endfor
bic=bic*xnyi
xn=xn*xnyi
amp=amp*xnyi
bi=abs(bic)
for ia=1,nxh-1 do begin
  for ib=1,nxh-ia-1 do begin
    for id=1,nxh-ia-ib-1
    rabc(ia,ib,id)=bi(ia,ib,id)/xn(ia,ib,id)     
    endfor
  endfor
endfor      
end
