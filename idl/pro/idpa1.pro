;Input from h1cam for particles
num=0
step=0
fil='       '
read,'Enter root name +t', fil
Read,'Enter number and step ',num,step
fil1='i1'+fil
len= strlen(fil1)
filename='                                      .idl'
filename2='                                      .idl'
strput,filename,fil1,1
nnn=0
for i=0, num do begin
unbug=i
 strput,filename,String(i*step),len + 5 
 openr, i, strcompress(filename,/remove_all), /get_lun 
readf, i,ns
n1=fltarr(ns)
 n2=n1
 readf, i,n1,n2
free_lun,i
i=unbug
nn=n2(ns-1)
if (nn gt nnn) then nnn=nn
endfor
npcl=fltarr(num+1)
cx=fltarr(num+1,nnn)
cvx=cx
cvy=cx
cvz=cx
fil1='p1'+fil
fil2='i1'+fil
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
 openr, j, strcompress(filename2,/remove_all), /get_lun        
 readf, j,ns
 n1=fltarr(ns)
 n2=n1
 readf, j,n1,n2
 free_lun,j
 openr, i, strcompress(filename,/remove_all), /get_lun 
 nn=n2(ns-1)
 x1=fltarr(nn)
 vx1=x1
 vy1=x1
 vz1=x1
 print,'nn=', nn
 readf, i, x1,vx1, vy1, vz1                                               
 free_lun, i
 i=unbug
for j=0,nn-1 do begin
cx(i,j)=x1(j)
cvx(i,j)=vx1(j)
cvy(i,j)=vy1(j)
cvz(i,j)=vz1(j)
endfor
npcl(i)=nn
 Print, 'Finished ', strcompress(filename,/remove_all)
 endfor
Print, 'The End' 
end 
