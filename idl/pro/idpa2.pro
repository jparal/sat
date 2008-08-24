;Input from h3cam for particles
num=0
step=0
fil='       '
iunit=11
read,'Enter root name +t', fil
Read,'Enter number and step ',num,step
fil1='p3'+fil
len= strlen(fil1)
filename='                                      .idl'
filename2='                                      .idl'
strput,filename,fil1,1
strput,filename,String(num*step),len + 5 
 openr, iunit, strcompress(filename,/remove_all), /get_lun 
readf, iunit,ns
n1=fltarr(ns)
 n2=n1
 readf, iunit,n1,n2
free_lun,iunit
nnn=n2(ns-1)
cx=fltarr(num+1,nnn)
cy=cx
cz=cx
cvx=cx
cvy=cx
cvz=cx
fil1='r3'+fil
fil2='p3'+fil
len= strlen(fil1)
filename='                                      .idl'
filename2='                                      .idl'
strput,filename,fil1,1
strput,filename2,fil2,1
for i=0, num do begin
 unbug=i 
  j=i+1                                 
 strput,filename,String(i*step),len + 5 
 strput,filename2,String(i*step),len + 5         
 openr, i, strcompress(filename,/remove_all), /get_lun                             
 openr, j, strcompress(filename2,/remove_all), /get_lun        
 readf, j,ns
 n1=fltarr(ns)
 n2=n1
 readf, j,n1,n2
 free_lun,j
 nn=n2(ns-1)-1
 readf, i, x(0:nn), y(0:nn), z(0:nn)                                               
 free_lun, i
 i=unbug
cx(i,*)=x
cy(i,*)=y
cz(i,*)=z
 Print, 'Finished ', strcompress(filename,/remove_all)
 endfor
fil1='v3'+fil
fil2='p3'+fil
len= strlen(fil1)
filename='                                      .idl'
filename2='                                      .idl'
strput,filename,fil1,1
strput,filename2,fil2,1
for i=0, num do begin
 unbug=i               
  j=i+1
 strput,filename,String(i*step),len + 5
 strput,filename2,String(i*step),len + 5
 openr, i, strcompress(filename,/remove_all), /get_lun                         
 openr, j, strcompress(filename2,/remove_all), /get_lun
 readf, j,ns
 n1=fltarr(ns)
 n2=n1
 readf, j,n1,n2
 free_lun,j
 nn=n2(ns-1)-1                                               
 readf, i, vx(0:nn), vy(0:nn), vz(0:nn)                                               
 free_lun, i
 i=unbug
cvx(i,*)=vx
cvy(i,*)=vy
cvz(i,*)=vz
 Print, 'Finished ', strcompress(filename,/remove_all)
 endfor
Print, 'The End' 
end 

