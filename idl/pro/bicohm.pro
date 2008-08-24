pro bicohm,an,amp,rabc,nxh=nxh,nyh=nyh,verbose=verbose         
ss=size(an)
if not(keyword_set(verbose))then verbose=0
if(ss(0) eq 2) then begin
nx=ss(1)
ny=ss(2)
xnyi=1./float(ny)
if not(keyword_set(nxh))then nxh=nx/2
xnx=1./sqrt(2*!pi*float(nx))
bic=complexarr(nxh,nxh)
xn=fltarr(nxh,nxh)
amp=xn
rabc=xn
for j=0,ny-1 do begin
  if(verbose eq 1)then print,j
  a=reform(fft(an(*,j),1))/xnx  
  for ia=1,nxh-1 do begin
    for ib=1,nxh-ia-1 do begin
      ai=a(ia)
      bi=a(ib)
      ic=ia+ib
      ci=a(ic) 
      amp(ia,ib)=amp(ia,ib)+abs(ai)*abs(bi)*abs(ci)
      com=ai*bi*conj(ci)
      bic(ia,ib)=bic(ia,ib)+com
      xn(ia,ib)=xn(ia,ib)+abs(com)     
    endfor
  endfor
endfor
bic=bic*xnyi
xn=xn*xnyi
amp=amp*xnyi
bi=abs(bic)
for ia=1,nxh-1 do begin
  for ib=1,nxh-ia-1 do begin
    rabc(ia,ib)=bi(ia,ib)/xn(ia,ib)     
  endfor
endfor      
endif

if(ss(0) eq 3) then begin
nx=ss(1)
ny=ss(2)
nz=ss(3)
xnyi=1./float(nz)
if not(keyword_set(nxh))then nxh=nx/2
if not(keyword_set(nyh))then nyh=ny/2
xnx=1./sqrt(2*!pi*float(nx*ny))
bic=complexarr(nxh,nxh,nyh)
xn=fltarr(nxh,nxh,nyh)
amp=xn
rabc=xn
for j=0,nz-1 do begin
  if(verbose eq 1)then print,j
  a=reform(fft(an(*,*,j),1))  
  for ia=0,nxh-1 do begin 
    for ib=0,nxh-ia-1 do begin
       for iay=0,nyh-1 do begin
       iby=ny-1-iay
      ai=a(ia,iay)
      bi=a(ib,iby)
      ic=ia+ib
      icy=iay+iby
      ci=a(ic,icy) 
      amp(ia,ib,iay)=amp(ia,ib,iay)+abs(ai)*abs(bi)*abs(ci)
      com=ai*bi*conj(ci)
      bic(ia,ib,iay)=bic(ia,ib,iay)+com
      xn(ia,ib,iay)=xn(ia,ib,iay)+abs(com)  
           endfor
    endfor
  endfor
endfor
bic=bic*xnyi
xn=xn*xnyi
amp=amp*xnyi
bi=abs(bic)
for ia=0,nxh-1 do begin
  for ib=0,nxh-ia-1 do begin
     for iay=0,nyh-1 do begin
           rabc(ia,ib,iay)=bi(ia,ib,iay)/xn(ia,ib,iay)
     endfor     
  endfor
endfor      
endif
end
