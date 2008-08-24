; hist3D of x,y,z; samples nbinx*nbiny*nbinz (default 40^3)
; ix,iy,iz values of x,y,z
   pro hist3, x,y, z,h, ix,iy,iz, nbinx=nbinx,nbiny=nbiny,nbinz=nbinz     
   if keyword_set(nbinx)then begin
         binx=nbinx
    endif else begin
         binx=40
    endelse
   if keyword_set(nbinz)then begin
         binz=nbinz
    endif else begin
         binz=40
    endelse
   if keyword_set(nbiny)then begin
         biny=nbiny
    endif else begin
         biny=40
    endelse    
   mx=min(x)
   mmx=max(x)
   mz=min(z)
   mmz=max(z)
   my=min(y)
   mmy=max(y)
   bx=(mmx-mx)/binx
   by=(mmy-my)/biny
   bz=(mmz-mz)/binz
   sy=size(y)
   ny=sy(1)
   h=fltarr(binx+1,biny+1,binz+1)
   ix=findgen(binx+1)*bx
   ix=ix+mx
   iy=findgen(biny+1)*by
   iy=iy+my
   iz=findgen(binz+1)*bz
   iz=iz+mz
   if (ny lt 10000) then begin
     for j=0, ny-1 do begin
       nnx=(x(j)-mx)/bx
       nny=(y(j)-my)/by
       nnz=(z(j)-mz)/bz
       h(nnx,nny,nnz)=h(nnx,nny,nnz)+1
   endfor 
   endif else begin
   j=0L
kt:  nnx=(x(j)-mx)/bx
    nny=(y(j)-my)/by
    nnz=(z(j)-mz)/bz
    h(nnx,nny,nnz)=h(nnx,nny,nnz)+1
    j=j+1   
    if (j lt ny) then goto, kt
   endelse
   return
   end
