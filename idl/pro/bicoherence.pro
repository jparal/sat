pro bicoherence,an,xn,rabc,nxh=nxh,nyh=nyh,verbose=verbose,$
ix=ix,iy=iy
ss=size(an)
nx=ss(1)
ny=ss(2)
if not(keyword_set(verbose))then verbose=0
if(ss(0) eq 2)then begin
if not(keyword_set(nxh))then nxh=nx/2-1
nxhh=nx/2-1
xnyi=1./float(ny)
xnx=1./sqrt(2*!pi*float(nx))
nxq=nxh/2
bic=complexarr(2*nxh+1,2*nxh+1)
xn=fltarr(2*nxh+1,2*nxh+1)
ix=fltarr(2*nxh+1)
for ia=-nxh,nxh do ix(ia+nxh)=ia
rabc=xn
for j=0,ny-1 do begin
  a=shift(reform(fft(an(*,j),1))/xnx,nxhh)  
   if(verbose eq 1)then print,j
    for ia=-nxh,nxh do begin
    for ib=-nxh,nxh do begin
      ai=a(ia+nxhh)
      bi=a(ib+nxhh)
      ic=ia+ib
      if(ic ge (-nxhh) and ic le nxhh)then begin
      ci=a(ic+nxhh)
      com=ai*bi*conj(ci)
      bic(ia+nxh,ib+nxh)=bic(ia+nxh,ib+nxh)+com
      xn(ia+nxh,ib+nxh)=xn(ia+nxh,ib+nxh)+abs(com)     
      endif else begin
       xn(ia+nxh,ib+nxh)=1
      endelse
    endfor
  endfor
endfor
rabc=abs(bic)/xn
endif
if(ss(0) eq 3) then begin
nx=ss(1)
ny=ss(2)
nz=ss(3)
xnyi=1./float(nz)
if not(keyword_set(nxh))then nxh=nx/2-1
if not(keyword_set(nyh))then nyh=ny/2-1
nxhh=nx/2-1
nyhh=ny/2-1
xnx=1./sqrt(2*!pi*float(nx))
bic=complexarr(2*nxh+1,2*nxh+1,2*nyh+1,2*nyh+1)
xn=fltarr(2*nxh+1,2*nxh+1,2*nyh+1,2*nyh+1)
rabc=xn
ix=fltarr(2*nxh+1)
for ia=-nxh,nxh do ix(ia+nxh)=ia
ix=fltarr(2*nxh+1)
for ib=-nyh,nyh do ix(ib+nyh)=ib
for j=0,nz-1 do begin
  if(verbose eq 1)then print,j
  a=shift(reform(fft(an(*,*,j),1)),nxhh,nyhh)
  for ia=-nxh,nxh do begin
    for ib=-nxh,nxh do begin 
       for iay=-nyh,nyh do begin
         for iby=-nyh,nyh do begin
           ai=a(ia+nxhh,iay+nyhh)
           bi=a(ib+nxhh,iby+nyhh)
           ic=ia+ib
           icy=iay+iby
           if(ic ge (-nxhh) and ic le nxhh and $
              icy ge (-nyhh) and ic le nyhh )then begin
           ci=a(ic+nxhh,icy+nyhh)
           com=ai*bi*conj(ci)
           bic(ia+nxh,ib+nxh,iay+nyh,iby+nyh)= com + $
                    bic(ia+nxh,ib+nxh,iay+nyh,iby+nyh)
           xn(ia+nxh,ib+nxh,iay+nyh,iby+nyh)=abs(com)+$
                    xn(ia+nxh,ib+nxh,iay+nyh,iby+nyh)
           endif else begin
             xn(ia+nxh,ib+nxh,iay+nyh,iby+nyh)=1.            
           endelse
           endfor
        endfor
    endfor
  endfor
endfor
rabc=abs(bic)/xn
endif
end
