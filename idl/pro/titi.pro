
pro titi, vx,vy,vz 
   binx=30
   binz=30
   biny=30
   mx=min(vx)
   mmx=max(vx)
   mz=min(vz)
   mmz=max(vz)
   my=min(vy)
   mmy=max(vy)
print,'vx ',mx,mmx
print,'vy ',my,mmy
print,'vz ',mz,mmz 
   bx=(mmx-mx)/binx
   by=(mmy-my)/biny
   bz=(mmz-mz)/binz
   sy=size(vy)
   ny=sy(1)
   hm=fltarr(binx+1,biny+1,binz+1)
   if (ny lt 10000) then begin
     for j=0, ny-1 do begin
       nnx=(vx(j)-mx)/bx
       nny=(vy(j)-my)/by
       nnz=(vz(j)-mz)/bz
        hm(nnx,nny,nnz)=hm(nnx,nny,nnz)+1
   endfor 
   endif else begin
   j=0L
kt:  nnx=(vx(j)-mx)/bx
    nny=(vy(j)-my)/by
    nnz=(vz(j)-mz)/bz
       hm(nnx,nny,nnz)=hm(nnx,nny,nnz)+1   
    j=j+1   
    if (j lt ny) then goto, kt
   endelse
vx=0
vy=0
vz=0
;
  iunit=6
  filename='             '
  read,' filename =',filename
  openw, iunit, filename
  printf,iunit,'define mesh hyb_mesh'
  printf,iunit,' mesh_topology hyb_topy'
  printf,iunit,' mesh_grid hyb_grid'
  printf,iunit,'  '
  printf,iunit,'define reg_grid hyb_grid'
  printf,iunit,'  grid_samp ',binx+1,biny+1,binz+1
  printf,iunit,'  origin -3 -3 -3 '
  printf,iunit,'  step ', bx,by,bz
  printf,iunit,'  '
  printf,iunit,'define reg_topology hyb_topy'
  printf,iunit,'   elem_samp ',binx,biny,binz
  printf,iunit,'  '
  printf,iunit,'define volume  f_tot'
  printf,iunit,'    volume_mesh hyb_mesh'
  printf,iunit,'    volume_vdata  ftot'
  printf,iunit,'   '
  printf,iunit,'define vdata 1 ftot ',$
 (binx+1)*(biny+1)*(binz+1) 
;
   for k=0,binz do begin
     for j=0,biny do begin
       for i= 0,binx do begin 
 printf,Format='(1F)', iunit,hm(i,j,k)
       endfor
     endfor
   endfor
   return
   end
