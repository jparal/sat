pro bicoherence_red,an,xn,rabc,nxh=nxh,nyh=nyh,verbose=verbose,ic,icy,$
ix=ix,iy=iy
ss=size(an)
nx=ss(1)
ny=ss(2)
if not(keyword_set(verbose))then verbose=0
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
bic=complexarr(2*nxh+1,2*nyh+1)
xn=fltarr(2*nxh+1,2*nyh+1)
rabc=xn
ix=fltarr(2*nxh+1)
for ia=-nxh,nxh do ix(ia+nxh)=ia
iy=fltarr(2*nyh+1)
for ib=-nyh,nyh do iy(ib+nyh)=ib
for j=0,nz-1 do begin
  if(verbose eq 1)then print,j
  a=shift(reform(fft(an(*,*,j),1)),nxhh,nyhh)
  ci=a(ic+nxhh,icy+nyhh)
  for ia=-nxh,nxh do begin
       for iay=-nyh,nyh do begin
           ai=a(ia+nxhh,iay+nyhh)
           ib=ic-ia
           iby=icy-iay
           if(ib ge (-nxhh) and ib le nxhh and $
              iby ge (-nyhh) and ib le nyhh )then begin
           bi=a(ib+nxhh,iby+nyhh)
           com=ai*bi*conj(ci)
           bic(ia+nxh,iay+nyh)= com + $
                    bic(ia+nxh,iay+nyh)
           xn(ia+nxh,iay+nyh)=abs(com)+$
                    xn(ia+nxh,iay+nyh)
           endif else begin
             xn(ia+nxh,iay+nyh)=1.            
           endelse
        endfor
   endfor
endfor
rabc=abs(bic)/xn
endif
end
