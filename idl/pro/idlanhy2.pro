;Input2 from 3D id inicialised by idlan.pro; reads
; cex,... cpe
; .r
num=0
step=0
fil='       '
read,'Enter root name +t', fil
fil=strcompress(fil,/remove_all)
Read,'Enter number and step ',num,step
cex=fltarr(num+1,nx1,ny1,nz1)
cey=cex
cez=cex
cex(0,*,*,*)=ex
cey(0,*,*,*)=ey
cez(0,*,*,*)=ez
cbx=fltarr(num+1,nx,ny,nz)
cby=cbx
cbz=cbx
cux=cbx
cuy=cbx
cuz=cbx
cdn=cbx
cpe=cbx
cbx(0,*,*,*)=bx
cby(0,*,*,*)=by
cbz(0,*,*,*)=bz
cux(0,*,*,*)=ux
cuy(0,*,*,*)=uy
cuz(0,*,*,*)=uz
cdn(0,*,*,*)=dn
cpe(0,*,*,*)=pe
len= strlen(fil)
filename='                                      .idl'
strput,filename,fil,1
for i=1, num do begin
 unbug=i                                  
 strput,filename,String(i*step),len + 5          
 openr, i, strcompress(filename,/remove_all), /get_lun 
 readf, i, cnwr, cncx,cncy,cncz,cdx,cdy,cdz,cdt                                 
 readf, i, ex, ey, ez                   
 readf, i, bx, by, bz                   
 readf, i, ux, uy, uz                   
 readf, i, dn, pe                            
 free_lun, i
 i=unbug
cex(i,*,*,*)=ex
cey(i,*,*,*)=ey
cez(i,*,*,*)=ez
cbx(i,*,*,*)=bx
cby(i,*,*,*)=by
cbz(i,*,*,*)=bz
cux(i,*,*,*)=ux
cuy(i,*,*,*)=uy
cuz(i,*,*,*)=uz
cdn(i,*,*,*)=dn
cpe(i,*,*,*)=pe                                          
 Print, 'Finished ', strcompress(filename,/remove_all)
 endfor
Print, 'The End' 
end 


 
