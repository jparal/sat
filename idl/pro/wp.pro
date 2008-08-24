;
  file='               '
  read,' filename = ',file
  iunit=4
  openw, iunit,file
  printf,iunit,nsn
  for i=0L,nsn-1 do begin
  printf,iunit,vx(i),vy(i),vz(i)
  endfor
  close,iunit
  end
