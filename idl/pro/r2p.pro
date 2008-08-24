 iunit=6
read,' number of particles = ',num
x=ftlarr(num,/noerase)
y=x
au='    '
file= '  '
read,' filename = ',file
openr,iunit,file
readf,iunit,au
print,'au'
readf,iunit,x
read,'xmin, xmax ',xmin, xmax
readf,iunit,au
print,'au'
readf,iunit,y
read,'ymin, ymax ',ymin, ymax
y=where((x ge xmin) and (x le xmax) and (y ge ymin) and (y le ymax))

readf,iunit,au
print,'au'
readf,iunit,x
vx=x(y)
readf,iunit,au
print,'au'
readf,iunit,x
vy=x(y)
readf,iunit,au
print,'au'
readf,iunit,x
vz=x(y)
;
; beam
;
readf,iunit,au
print,'au'
readf,iunit,x
readf,iunit,au
print,'au'
readf,iunit,y
y=where((x ge xmin) and (x le xmax) and (y ge ymin) and (y le ymax))

readf,iunit,au
print,'au'
readf,iunit,x
vxb=x(y)
readf,iunit,au
print,'au'
readf,iunit,x
vyb=x(y)
readf,iunit,au
print,'au'
readf,iunit,x
vzb=x(y)
close,iunit
x=0
y=0
end
