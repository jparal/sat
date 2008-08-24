;Input program from d3cam+par!
file_nam='               '
read, 'Enter input file name', file_nam
iunit=1
openr,iunit,'p3'+file_nam ,/get_lun
readf,iunit,ns
n1=fltarr(ns)
n2=n1
readf,iunit,n1,n2
openr,iunit,'p3'+file_nam ,/get_lun
readf,iunit,ns
free_lun, iunit
nnn=n2(ns-1)
x=fltarr(nnn)
y=x
z=x
vx=x
vy=x
vz=x
openr,iunit,'r3'+file_nam ,/get_lun
readf,iunit,x,y,z
free_lun, iunit
openr,iunit,'v3'+file_nam ,/get_lun
readf,iunit,vx,vy,vz
free_lun, iunit

end 

 
