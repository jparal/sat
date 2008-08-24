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
strput,filename,fil1,1
nnn=0
npcl=fltarr(num+1)
for i=0, num do begin
unbug=i
 strput,filename,String(i*step),len + 5
 openr, i, strcompress(filename,/remove_all), /get_lun
readf, i,ns
n1=fltarr(ns)
 n2=n1
 readf, i,n1,n2
close,i
free_lun,i
i=unbug
nn=n2(ns-1)
npcl(i)=nn
print, 'finished ', strcompress(filename,/remove_all)
if (nn gt nnn) then nnn=nn
endfor
cx=fltarr(num+1,nnn)
cy=cx
cz=cx
cvx=cx
cvy=cx
cvz=cx
fil1='r3'+fil
len= strlen(fil1)
filename='                                      .idl'
strput,filename,fil1,1
for i=0, num do begin
 unbug=i 
  j=i+1                                 
 strput,filename,String(i*step),len + 5 
 openr, i, strcompress(filename,/remove_all), /get_lun                             
 nn=npcl(i)
 x=fltarr(nn)
 y=x
 z=x
 readf, i,x,y,z
 close,i                                               
 free_lun, i
 i=unbug
for j=0,nn-1 do begin
cx(i,j)=x(j)
cy(i,j)=y(j)
cz(i,j)=z(j)
endfor
 Print, 'Finished ', strcompress(filename,/remove_all)
 endfor
fil1='v3'+fil
len= strlen(fil1)
filename='                                      .idl'
strput,filename,fil1,1
for i=0, num do begin
 unbug=i               
 strput,filename,String(i*step),len + 5
 openr, i, strcompress(filename,/remove_all), /get_lun                         
 nn=npcl(i)
 vx=fltarr(nn)
 vy=vx
 vz=vx
 readf, i, vx, vy, vz
 close, i                                               
 free_lun, i
 i=unbug
for j=0,nn-1 do begin
cvx(i,j)=vx(j)
cvy(i,j)=vy(j)
cvz(i,j)=vz(j)
endfor
 Print, 'Finished ', strcompress(filename,/remove_all)
 endfor
Print, 'The End' 
end 

