; produces a 1d histogram along a vector k
; of vector (vx,vy,vz)
pro hist_along, vx,vy,vz,kx,ky,kz,h,i,nbin=nbin
if(not(keyword_set(nbin))then nbin=100

