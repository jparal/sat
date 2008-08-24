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
ex=fltarr(nx1,ny1,nz1,/nozero)
ey=ex
ez=ex
readf,iunit,ex,ey,ez
bx=fltarr(nx,ny,nz,/nozero)
by=bx
bz=bx
ux=bx
uy=bx
uz=bx
dn=bx
pe=bx
ux1=bx
ux2=bx
uy1=bx
uy2=bx
uz1=bx
uz2=bx
dn1=bx
dn2=bx
readf,iunit,bx,by,bz,ux,uy,uz,dn,pe,ux2,uy2,uz2,ux1,uy1,uz1,dn1,dn2
free_lun, iunit
close, iunit
end  
