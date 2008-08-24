;Input program2 from h3cam inicialised by idlanhy.pro
num=0
n0=0
step=0
fil='       '
read,'Enter root name +t', fil
fil=strcompress(fil,/remove_all)
Read,'Enter number and step n0 ',num,step,n0
cbx=fltarr(num+1,nx,ny,nz,/nozero)
cby=cbx
cbz=cbx
cdn=cbx
cbx(0,*,*,*)=bx
cby(0,*,*,*)=by
cbz(0,*,*,*)=bz
cdn(0,*,*,*)=dn
len= strlen(fil)
filename='                                      .'
strput,filename,fil,1
for i=1, num do begin
 unbug=i                                  
 strput,filename,String(n0+i*step),len + 5          
 openr, i, strcompress(filename,/remove_all), /get_lun 
 readf, i, cnwr, cncx,cncy,cncz,cdx,cdy,cdz,cdt                                 
 readf, i, bx, by, bz                   
 readf, i, dn                     
 free_lun, i
 i=unbug
cbx(i,*,*,*)=bx
cby(i,*,*,*)=by
cbz(i,*,*,*)=bz
cdn(i,*,*,*)=dn
 Print, 'Finished ', strcompress(filename,/remove_all)
 endfor
Print, 'The End' 
end 


 
