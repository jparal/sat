; calculates a histogram "h" in 3D of "vx,vy,vz" and finds out
; value of resonance "r = om - k.v" 
pro reson,vx,vy,vz,om,kx,ky,kz,h,r,nbinx=nbinx,nbiny=nbiny, $
nbinz=nbinz
if(not(keyword_set(nbinx)))then nbinx=30
if(not(keyword_set(nbiny)))then nbiny=30
if(not(keyword_set(nbinz)))then nbinz=30
hist3,vx,vy,vz,h,ix,iy,iz,nbinx=nbinx,nbiny=nbiny, $
nbinz=nbinz
r=fltarr(nbinx+1,nbiny+1,nbinz+1,/nozero)
for i=0,nbinx do begin
  for j=0,nbiny do begin
    for k=0,nbinz do begin
      r(i,j,k)=om-(kx*ix(i)+ky*iy(j)+kz*iz(k))
    endfor
  endfor
endfor
return
end       
