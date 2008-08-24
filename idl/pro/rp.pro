;
  f1=fltarr(40,20,20)
  f2=f1
  f3=f1
  f4=f1
  f5=f1
  f6=f1
  f7=f1
  f8=f1
  f9=f1
  file='               '
  read,' filename = ',file
  iunit=4
  openr, iunit,file
  for k=0,19 do begin
  for j=0,19 do begin
  for i=0,39 do begin
  readf,iunit,ff1,ff2,ff3,ff4,ff5,ff6,ff7,ff8,ff9
  f1(i,j,k)=ff1
  f2(i,j,k)=ff2
  f3(i,j,k)=ff3
  f4(i,j,k)=ff4
  f5(i,j,k)=ff5
  f6(i,j,k)=ff6
  f7(i,j,k)=ff7
  f8(i,j,k)=ff8
  f9(i,j,k)=ff9
  endfor
  endfor
  endfor
  close,iunit
  end
