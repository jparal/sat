pro bicoher,an,xn,rabc,nxh=nxh,nyh=nyh,verbose=verbose      
ss=size(an)
nx=ss(1)
ny=ss(2)
if not(keyword_set(verbose))then verbose=0
if(ss(0) eq 2)then begin
 if not(keyword_set(nxh))then nxh=nx/2
xnyi=1./float(ny)
xnx=1./sqrt(2*!pi*float(nx))
nxq=nxh/2
bic=complexarr(nxh,nxh+1)
xn=fltarr(nxh,nxh+1)
rabc=xn
for j=0,ny-1 do begin
  a=reform(fft(an(*,j),1))/xnx  
   if(verbose eq 1)then print,j
    for ia=0,nxh-1 do begin
    iam=min([ia,nxh-ia])
    for ib=-iam,iam do begin
      ai=a(ia)
      if(ib ge 0)then bi=a(ib)
      if(ib lt 0)then bi=conj(a(-ib))
      ic=ia+ib
      if(ic ge 0)then ci=a(ic)
      if(ic lt 0)then ci=conj(a(-ic)) 
      com=ai*bi*conj(ci)
      bic(ia,ib+nxq)=bic(ia,ib+nxq)+com
      xn(ia,ib+nxq)=xn(ia,ib+nxq)+abs(com)     
    endfor
  endfor
endfor
for ia=0,nxh-1 do begin
  iam=min([ia,nxh-ia])
    for ib=-iam,iam do begin
    rabc(ia,ib+nxq)=abs(bic(ia,ib+nxq))/xn(ia,ib+nxq)     
  endfor
endfor      
for ia=0,nxh-1 do begin
  for ib=ia+1,nxq do begin
    rabc(ia,ib+nxq)=rabc(ib,ia+nxq)
    xn(ia,ib+nxq)=xn(ib,ia+nxq)
  endfor
  for ib=-nxq,-ia-1 do begin
    rabc(ia,ib+nxq)=rabc(-ib,-ia+nxq)
    xn(ia,ib+nxq)=xn(-ib,-ia+nxq)
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
xnx=1./sqrt(2*!pi*float(nx))
bic=complexarr(nxh,nxh+1,nyh,nyh+1)
xn=fltarr(nxh,nxh+1,nyh,nyh+1)
nxq=nxh/2
nyq=nyh/2
amp=xn
rabc=xn
for j=0,nz-1 do begin
  if(verbose eq 1)then print,j
  a=reform(fft(an(*,*,j),1))
  for ia=0,nxh-1 do begin
    iam=min([ia,nxh-ia])
    for ib=-iam,iam do begin 
       for iay=0,nyh-1 do begin
         iamy=min([iay,nyh-iay])
         for iby=-iamy,iamy do begin
      ai=a(ia,iay)
      if(ib ge 0)then begin
        if(iby ge 0) then begin 
           bi=a(ib,iby)
        endif else begin
           bi=conj(a(ib,-iby))
        endelse
      endif else begin
        if(iby ge 0) then begin
           bi=conj(a(-ib,iby))
        endif else begin
           bi=a(-ib,-iby)
        endelse
      endelse
      ic=ia+ib
      icy=iay+iby
      if(ic ge 0)then begin
        if(icy ge 0) then begin
           ci=a(ic,icy)
        endif else begin
           ci=conj(a(ic,-icy))
        endelse
      endif else begin
        if(ibc ge 0) then begin
           ci=conj(a(-ic,icy))
        endif else begin
           ci=a(-ic,-icy)
        endelse
      endelse
      ci=a(ic,icy)
      com=ai*bi*conj(ci)
      bic(ia,ib+nxq,iay,iby+nyq)=bic(ia,ib+nxq,iay,iby+nyq)+com
      xn(ia,ib+nxq,iay,iby+nyq)=xn(ia,ib+nxq,iay,iby+nyq)+abs(com)
           endfor
        endfor
    endfor
  endfor
endfor
for ia=0,nxh-1 do begin
  iam=min([ia,nxh-ia])
  for ib=-iam,iam do begin
     for iay=0,nyh-1 do begin
       iamy=min([iay,nyh-iay])
        for iby=-iamy,iamy do begin
          rabc(ia,ib+nxq,iay,iby+nyq)=$ 
          abs(bic(ia,ib+nxq,iay,iby+nyq))/xn(ia,ib+nxq,iay,iby+nyq)
        endfor
     endfor
  endfor
endfor
endif
end
