pro adbic,an,bic,xn,nxh=nxh,nyh=nyh
ss=size(an)
nx=ss(1)
ny=ss(2)
if not(keyword_set(nxh))then nxh=nx/2-1
if not(keyword_set(nyh))then nyh=ny/2-1
  a=shift(reform(fft(an,1)),nxh,nyh)
  for ia=-nxh,nxh do begin
    for ib=-nxh,nxh do begin 
       for iay=-nyh,nyh do begin
         for iby=-nyh,nyh do begin
           ai=a(ia+nxh,iay+nyh)
           bi=a(ib+nxh,iby+nyh)
           ic=ia+ib
           icy=iay+iby
           if(ic ge (-nxh) and ic le nxh and $
              icy ge (-nyh) and ic le nyh )then begin
           ci=a(ic+nxh,icy+nyh)
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
end
