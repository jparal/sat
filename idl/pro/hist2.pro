; hist2D h of x,y with nbinx*nbiny (def 100*100) samples 
; ix and iy arrays of x,y values with min max keyword
   pro hist2, x,y, h, ix,iy,nbinx=nbinx,nbiny=nbiny, $
   xmin=xmin,xmax=xmax,ymin=ymin,ymax=ymax     
   if keyword_set(nbinx)then begin
         binx=nbinx
    endif else begin
         binx=100
    endelse
   if keyword_set(nbiny)then begin
         biny=nbiny
    endif else begin
         biny=100
    endelse    
   mx=min(x)
   mmx=max(x)
   my=min(y)
   mmy=max(y)
   if keyword_set(xmin)then mx=min([xmin,mx])
   if keyword_set(xmax)then mmx=max([xmax,mmx])
   if keyword_set(ymin)then my=min([ymin,my])
   if keyword_set(ymax)then mmy=max([ymax,mmy])
   bx=(mmx-mx)/binx
   by=(mmy-my)/biny
   sy=size(y)
   if(sy(0) eq 1) then begin
   ny=sy(1)
   h=fltarr(binx+1,biny+1)
   ix=findgen(binx+1)*bx
   ix=ix+mx
   iy=findgen(biny+1)*by
   iy=iy+my
     for j=0l, ny-1 do begin
       nnx=(x(j)-mx)/bx
       nny=(y(j)-my)/by
       h(nnx,nny)=h(nnx,nny)+1
     endfor 
   endif
   if (sy(0) eq 2) then begin 
   nx=sy(1)
   ny=sy(2)
   h=fltarr(binx+1,biny+1)
   ix=findgen(binx+1)*bx
   ix=ix+mx
   iy=findgen(biny+1)*by
   iy=iy+my   
   for i=0l,nx-1 do begin
     for j=0l,ny-1 do begin       
       nnx=(x(i,j)-mx)/bx
       nny=(y(i,j)-my)/by
       h(nnx,nny)=h(nnx,nny)+1   
     endfor  
   endfor
   endif 
   if (sy(0) eq 3) then begin
   nx=sy(1)
   ny=sy(2)
   nz=sy(3)
   h=fltarr(binx+1,biny+1)
   ix=findgen(binx+1)*bx
   ix=ix+mx
   iy=findgen(biny+1)*by
   iy=iy+my
   for i=0l,nx-1 do begin
     for j=0l,ny-1 do begin
       for k=0l,nz-1 do begin
         nnx=(x(i,j)-mx)/bx
         nny=(y(i,j)-my)/by
         h(nnx,nny)=h(nnx,nny)+1
       endfor
     endfor
   endfor
   endif
   end 
