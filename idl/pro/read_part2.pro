 iunit=6
read,' number of particles = ',num
x=fltarr(num)
y=x
vx=x
vy=x
vz=x
au='    '
file= '  '
read,' filename = ',file
openr,iunit,file
readf,iunit,au
print,au
readf,iunit,format='(5g15.8)',x
readf,iunit,au
print,au
readf,iunit,format='(5g15.8)',y

readf,iunit,au
print,au
readf,iunit,format='(5g15.8)',vx
readf,iunit,au
print,au
readf,iunit,format='(5g15.8)',vy
readf,iunit,au
print,au
readf,iunit,format='(5g15.8)',vz
end
