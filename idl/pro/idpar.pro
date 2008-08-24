;Input from h1cam for particles
num=0
step=0
fil='       '
read,'Enter file root name', fil
fil1='i1'+fil
len= strlen(fil1)
filename='                                      .idl'
filename2='                                      .idl'
strput,filename,fil1,1
nnn=0
i=11
unbug=i
 openr, i, strcompress(filename,/remove_all), /get_lun 
readf, i,ns
n1=fltarr(ns)
 n2=n1
 readf, i,n1,n2
free_lun,i
i=unbug
nn=n2(0)
npcl=fltarr(num+1)
fil1='p1'+fil
len= strlen(fil1)
filename='                                      .idl'
strput,filename,fil1,1       
 openr, i, strcompress(filename,/remove_all), /get_lun 
 nn=n2(0)
 x1=fltarr(nn)
 vx1=x1
 vy1=x1
 vz1=x1
 print,'nn=', nn
 readf, i, x1,vx1, vy1, vz1                                               
 free_lun, i
if (ns eq 2) then begin
nn=n2(ns-1)-n2(ns-2)
fil1='p2'+fil
len= strlen(fil1)
filename='                                      .idl'
strput,filename,fil1,1
 openr, i, strcompress(filename,/remove_all), /get_lun
 x2=fltarr(nn)
 vx2=x2
 vy2=x2
 vz2=x2
 print,'nn=', nn
 readf, i, x2,vx2, vy2, vz2
 free_lun, i
endif
Print, 'The End' 
end 
