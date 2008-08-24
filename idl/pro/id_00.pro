;Input program from d3cam
file_nam='               '
read, 'Enter input file name', file_nam
iunit=1
openr,iunit,file_nam ,/get_lun
readf,iunit,nwr, ncx,ncy,ncz,dx,dy,dz,dt
nx=ncx+1
ny=ncy+1
nz=ncz+1
nx1=nx+1
ny1=ny+1
nz1=nz+1
;
ex=fltarr(nx1,ny1,nz1,/nozero)
readf,iunit,ex
d2,ex,au,x=1
ex=au
;
ey=fltarr(nx1,ny1,nz1,/nozero)
readf,iunit,ey
d2,ey,au,x=1
ey=au
;
ez=fltarr(nx1,ny1,nz1,/nozero)
readf,iunit,ez
d2,ez,au,x=1
ez=au
;
bx=fltarr(nx,ny,nz,/nozero)
readf,iunit,bx
d2,bx,au,x=1
bx=au
;
by=fltarr(nx,ny,nz,/nozero)
readf,iunit,by
d2,by,au,x=1
by=au
;
bz=fltarr(nx,ny,nz,/nozero)
readf,iunit,bz
d2,bz,au,x=1
bz=au
;
free_lun, iunit
close,iunit

end 

 
