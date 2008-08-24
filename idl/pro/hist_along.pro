; produces a 1d histogram along a scalar product k.v/k
; of vectors (vx,vy,vz) and (kx,ky,kz)
pro hist_along, vx,vy,vz,kx,ky,kz,h,i,nbin=nbin
if(not(keyword_set(nbin)))then nbin=100
k=sqrt(kx^2+ky^2+kz^2)
vk=(vx*kx+vy*ky+vz*kz)
hist,vk,h,i,nbin=nbin
h=h/k
return
end
