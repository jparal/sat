;Input program from 2D id; reads files ex,ey,ez
; bx,by,bz,ux,uy,uz,dn,pe,ux1,uy1,uz1,dn1,ux2,uy2,uz2,dn2
; .r
file_nam='             '
read, 'Enter input file name', file_nam 
iunit=1
openr,iunit, file_nam
readf,iunit,ns,nwr, ncx,ncy,dx,dy,dt
nx=ncx+1
ny=ncy+1
nx1=nx+1
ny1=ny+1
ex=fltarr(nx1,ny1,/nozero)
ey=ex
ez=ex
readf,iunit,ex,ey,ez
bx=fltarr(nx,ny,/nozero)
by=bx
bz=bx
ux=bx
uy=bx
uz=bx
dn=bx
pe=bx
dn1=bx
ux1=bx
uy1=bx
uz1=bx
dn2=bx
ux2=bx
uy2=bx
uz2=bx
readf,iunit,bx,by,bz,ux,uy,uz,dn,pe,ux1,uy1,uz1,dn1, $
ux2,uy2,uz2,dn2
close, iunit
end 

 
