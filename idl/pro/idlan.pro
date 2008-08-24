;Input program from 1D id; reads ex,ey,ez
; bx,by,bz,ux,uy,uz,dn,pe
; .r
file_nam='               '
read,'Enter input file name', file_nam
iunit=1
openr,iunit,file_nam, /get_lun
readf,iunit,ncx,nx,dx
nx1=nx+1
ex=fltarr(nx1)
ey=ex
ez=ex
readf,iunit,ex,ey,ez
bx=fltarr(nx)
by=bx
bz=bx
ux=bx
uy=bx
uz=bx
dn=bx
pe=bx
readf,iunit,bx,by,bz,ux,uy,uz,dn,pe
free_lun,iunit
close, iunit
end 

 
