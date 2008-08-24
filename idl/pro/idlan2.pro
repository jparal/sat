;Input2 from 1D id inicialised by idlan.pro; reads
; aex,... ape
; .r
num=0
step=0
fil='       '
read,'Enter root name +t', fil
fil=strcompress(fil,/remove_all)
Read,'Enter number and step ',num,step
aex=fltarr(num+1,nx1)
aey=aex
aez=aex
aex(0,*)=ex
aey(0,*)=ey
aez(0,*)=ez
abx=fltarr(num+1,nx)
aby=abx
abz=abx
aux=abx
auy=abx
auz=abx
adn=abx
ape=abx
abx(0,*)=bx
aby(0,*)=by
abz(0,*)=bz
aux(0,*)=ux
auy(0,*)=uy
auz(0,*)=uz
adn(0,*)=dn
ape(0,*)=pe
len= strlen(fil)
filename='                                      .idl'
strput,filename,fil,1
for i=1, num do begin  
 unbug=i                                  
 strput,filename,String(i*step),len+5       
 openr, i, strcompress(filename,/remove_all), /get_lun 
 readf, i, ancx, anx, adx                                 
 readf, i, ex, ey, ez                   
 readf, i, bx, by, bz                   
 readf, i, ux, uy, uz                   
 readf, i, dn, pe                            
 free_lun, i
 close,i
 i=unbug 
aex(i,*)=ex
aey(i,*)=ey
aez(i,*)=ez
abx(i,*)=bx
aby(i,*)=by
abz(i,*)=bz
aux(i,*)=ux
auy(i,*)=uy
auz(i,*)=uz
adn(i,*)=dn
ape(i,*)=pe                                          
 Print, 'Finished ', strcompress(filename,/remove_all)
 endfor
Print, 'The End' 
end 


 
