;Input from h1cam for particles
num=0
step=0
fil='       '
i=9
j=10
read,'filename= ', fil
fil1='i1'+fil
len= strlen(fil1)
filename='                                      '
filename2='                                     '
strput,filename,fil1,1
nnn=0
; strput,filename,String(i*step),len + 5 
 openr, j, strcompress(filename,/remove_all), /get_lun 
 readf, j,ns
 n1=fltarr(ns)
 n2=n1
 readf, j,n1,n2
 close,j
 free_lun,j
fil1='p1'+fil
len= strlen(fil1)
strput,filename2,fil1,1
 openr, i, strcompress(filename2,/remove_all), /get_lun 
 nn=n2(0)-n1(0)+1
 x=fltarr(nn)
 vx=x
 vy=x
 vz=x
 print,'nn=', nn
 readf, i, x,vx, vy, vz                                               
close,i
 free_lun, i
if(ns gt 1) then begin
fil1='p2'+fil
len= strlen(fil1)
strput,filename2,fil1,1
 openr, i, strcompress(filename2,/remove_all), /get_lun
 nn=n2(1)-n1(1)+1   
 x2=fltarr(nn)
 vx2=x2
 vy2=x2
 vz2=x2
 print,'nn=', nn
 readf, i, x2,vx2, vy2, vz2
close,i
 free_lun, i
endif

Print, 'The End' 

end 
