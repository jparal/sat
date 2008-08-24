;  output to filename of 4D array a(x,y,z,nvar) of 
; varibles named var(nvar) in a format for data visualizer
   pro to_wave, filename, a, var
   iunit=6
   ss=size(a)
   ix=ss(1)
   iy=ss(2)
   iz=ss(3)
   nvar=ss(4)

  openw, iunit, filename
  printf,iunit,'define mesh hyb_mesh'
  printf,iunit,' mesh_topology hyb_topy'
  printf,iunit,' mesh_grid hyb_grid'
  printf,iunit,'  '
  printf,iunit,'define reg_grid hyb_grid'
  printf,iunit,'  grid_samp ',ix,iy,iz
  printf,iunit,'  origin -3 -3 -3 '
  printf,iunit,'  step 0.2 0.2 0.2 '
  printf,iunit,'  '
  printf,iunit,'define reg_topology hyb_topy'
  printf,iunit,'   elem_samp ',ix-1,iy-1,iz-1
  printf,iunit,'  '
  for i=0, nvar-1 do begin
  printf,iunit,'define volume ',var(i)+'_w'
  printf,iunit,'    volume_mesh hyb_mesh '
  printf,iunit,'    volume_vdata ',var(i)
  printf,iunit,' '
  endfor
  printf,iunit,format=strcompress('(A,I,1x,'+string(nvar)+'(A,1x),I)') $
    ,'define vdata ',nvar,var,ix*iy*iz  
;
   for k=0, iz-1 do begin
     for j=0, iy-1 do begin
       for i= 0, ix-1 do begin 
         printf,Format=strcompress('('+string(nvar)+'F)'),$
                 iunit,a(i,j,k,*)
       endfor
     endfor
   endfor
   close, iunit
   return
   end                       
