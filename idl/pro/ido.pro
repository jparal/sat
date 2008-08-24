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
bx=fltarr(nx,ny,nz)
by=bx
bz=bx
dn=bx
readf,iunit,bx,by,bz,dn
free_lun, iunit
end 

 
