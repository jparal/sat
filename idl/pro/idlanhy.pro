;Input program from 3D id; reads ex,ey,ez
; bx,by,bz,ux,uy,uz,dn,pe
; .r
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
ex=fltarr(nx1,ny1,nz1)
ey=ex
ez=ex
readf,iunit,ex,ey,ez
bx=fltarr(nx,ny,nz)
by=bx
bz=bx
ux=bx
uy=bx
uz=bx
dn=bx
pe=bx
readf,iunit,bx,by,bz,ux,uy,uz,dn,pe
free_lun, iunit
end 

 
