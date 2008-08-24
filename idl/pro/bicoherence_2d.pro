pro bicoherence_2d,an,amp,xn,nxh=nxh,verbose=verbose,x=x, ix=ix
ss=size(an)
if not(keyword_set(x) )then x=1
if not(keyword_set(verbose))then verbose=0
if(ss(0) eq 3) then begin
nx=ss(1)
ny=ss(2)
nz=ss(3)
if(x eq 1)then begin
xnyi=1./float(nx)
if not(keyword_set(nxh))then nxh=nx/2
xnx=1./sqrt(2*!pi*float(nx))
bic=complexarr(2*nxh+1,2*nxh+1)
xn=fltarr(2*nxh+1,2*nxh+1)
ix=fltarr(2*nxh+1)
for ia=-nxh,nxh do ix(ia+nxh)=ia
for j=0,ny-1 do begin
if(verbose eq 1)then print,j
for j2=0,nz-1 do begin
  a=shift(fft(reform(an(*,j,j2)),1)/xnx,nxh)
    for ia=-nxh,nxh do begin
    for ib=-nxh,nxh do begin
      ai=a(ia+nxh)
      bi=a(ib+nxh)
      ic=ia+ib
      if(ic ge (-nxh) and ic le nxh)then begin
        ci=a(ic+nxh)
        com=ai*bi*conj(ci)
        bic(ia+nxh,ib+nxh)=bic(ia+nxh,ib+nxh)+com
        xn(ia+nxh,ib+nxh)=xn(ia+nxh,ib+nxh)+abs(com)
      endif else begin
        xn(ia+nxh,ib+nxh)=1
      endelse
    endfor
    endfor
endfor
endfor
xn=abs(bic)/xn
endif
if(x eq 2) then begin
xnyi=1./float(ny)
if not(keyword_set(nxh))then nxh=ny/2
xnx=1./sqrt(2*!pi*float(ny))
bic=complexarr(2*nxh+1,2*nxh+1)
xn=fltarr(2*nxh+1,2*nxh+1)
ix=fltarr(2*nxh+1)
for ia=-nxh,nxh do ix(ia+nxh)=ia
for j=0,nx-1 do begin
if(verbose eq 1)then print,j
 for j2=0,nz-1 do begin
  a=shift(fft(reform(an(j,*,j2)),1)/xnx,nxh)
    for ia=-nxh,nxh do begin
    for ib=-nxh,nxh do begin
      ai=a(ia+nxh)
      bi=a(ib+nxh)
      ic=ia+ib
      if(ic ge (-nxh) and ic le nxh)then begin
        ci=a(ic+nxh)
        com=ai*bi*conj(ci)
        bic(ia+nxh,ib+nxh)=bic(ia+nxh,ib+nxh)+com
        xn(ia+nxh,ib+nxh)=xn(ia+nxh,ib+nxh)+abs(com)
      endif else begin
        xn(ia+nxh,ib+nxh)=1
      endelse
    endfor
  endfor
endfor
endfor
xn=abs(bic)/xn
endif
endif
end
