pro bicoh_2d,an,xn,rabc,nxh=nxh,verbose=verbose,x=x,ix=ix,istart=istart
ss=size(an)
if not(keyword_set(x) )then x=1
if not(keyword_set(verbose))then verbose=0
if not(keyword_set(istart) )then istart=1
if(ss(0) eq 3) then begin
nx=ss(1)
ny=ss(2)
nz=ss(3)
if(x eq 1)then begin
xnyi=1./float(ny)
if not(keyword_set(nxh))then nxh=nx/2
xnx=1./sqrt(2*!pi*float(nx))
bic=complexarr(nxh,nxh)
xn=fltarr(nxh,nxh)
rabc=xn
ix=findgen(nxh)
for j=0,ny-1 do begin
 for j2=0,nz-1 do begin
  if(verbose eq 1)then print,j,j2
  a=fft(reform(an(*,j,j2)),1)/xnx  
  for ia=istart,nxh-1 do begin
    for ib=istart,nxh-ia-1 do begin
      ai=a(ia)
      bi=a(ib)
      ic=ia+ib
      ci=a(ic) 
      com=ai*bi*conj(ci)
      bic(ia,ib)=bic(ia,ib)+com
      xn(ia,ib)=xn(ia,ib)+abs(com)     
    endfor
  endfor
 endfor
endfor
for ia=istart,nxh-1 do begin
  for ib=istart,nxh-ia-1 do begin
    rabc(ia,ib)=abs(bic(ia,ib))/xn(ia,ib)     
  endfor
endfor      
endif
if(x eq 2) then begin
xnyi=1./float(nx)
if not(keyword_set(nxh))then nxh=nx/2
xnx=1./sqrt(2*!pi*float(ny))
bic=complexarr(nxh,nxh)
xn=fltarr(nxh,nxh)
rabc=xn
for j=0,nx-1 do begin
 for j2=0,nz-1 do begin
  if(verbose eq 1)then print,j,j2
  a=fft(reform(an(j,*,j2)),1)/xnx
  for ia=istart,nxh-1 do begin
    for ib=istart,nxh-ia-1 do begin
      ai=a(ia)
      bi=a(ib)
      ic=ia+ib
      ci=a(ic)
      com=ai*bi*conj(ci)
      bic(ia,ib)=bic(ia,ib)+com
      xn(ia,ib)=xn(ia,ib)+abs(com)
    endfor
  endfor
endfor
endfor
for ia=istart,nxh-1 do begin
  for ib=istart,nxh-ia-1 do begin
    rabc(ia,ib)=abs(bic(ia,ib))/xn(ia,ib)
  endfor
endfor
endif
endif

end
