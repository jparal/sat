;
  f1=fltarr(100,100)
  f2=f1
  f3=f1
  f4=f1
  f5=f1
  f6=f1
  f7=f1
  f8=f1
  f9=f1
  f10=f1
  f11=f1
  f12=f1
  f13=f1
  file='               '
  read,' filename = ',file
  iunit=4
  openr, iunit,file
;  for k=0,19 do begin
  for j=0,99 do begin
  for i=0,99 do begin
  readf,iunit,ff1,ff2,ff3,ff4,ff5,ff6, $
          ff7,ff8,ff9,ff10,ff11,ff12,ff13
  f1(i,j)=ff1
  f2(i,j)=ff2
  f3(i,j)=ff3
  f4(i,j)=ff4
  f5(i,j)=ff5
  f6(i,j)=ff6
  f7(i,j)=ff7
  f8(i,j)=ff8
  f9(i,j)=ff9
  f10(i,j)=ff10
  f11(i,j)=ff11
  f12(i,j)=ff12
  f13(i,j)=ff13
  endfor
;  endfor
  endfor
  close,iunit
  end
