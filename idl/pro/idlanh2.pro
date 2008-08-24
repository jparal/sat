;Input2 from 2D id inicialised by idlanh.pro; reads
; bex,... bpe
; .r
num=0
step=0
num0=0
fil='       '
read,'Enter root name +t', fil
fil=strcompress(fil,/remove_all)
Read,'Enter number, step and zeroth number ',num,step,num0
bex=fltarr(num+1,nx1,ny1)
bey=bex
bez=bex
bex(0,*,*)=ex
bey(0,*,*)=ey
bez(0,*,*)=ez
bbx=fltarr(num+1,nx,ny)
bby=bbx
bbz=bbx
bux=bbx
buy=bbx
buz=bbx
bdn=bbx
bpe=bbx
bbx(0,*,*)=bx
bby(0,*,*)=by
bbz(0,*,*)=bz
bux(0,*,*)=ux
buy(0,*,*)=uy
buz(0,*,*)=uz
bdn(0,*,*)=dn
bpe(0,*,*)=pe
len= strlen(fil)
filename='                                     '
strput,filename,fil,1
for i=1, num do begin
 unbug=i                                  
 strput,filename,String(num0+i*step),len+5          
 Print, 'Started ', strcompress(filename,/remove_all)
 openr, i, strcompress(filename,/remove_all)
 readf, i, bns,bnwr, bncx,bncy,bdx,bdy,bdt                                 
 readf, i, ex, ey, ez                   
 readf, i, bx, by, bz                   
 readf, i, ux, uy, uz                   
 readf, i, dn, pe                            
 close, i
 i=unbug
bex(i,*,*)=ex
bey(i,*,*)=ey
bez(i,*,*)=ez
bbx(i,*,*)=bx
bby(i,*,*)=by
bbz(i,*,*)=bz
bux(i,*,*)=ux
buy(i,*,*)=uy
buz(i,*,*)=uz
bdn(i,*,*)=dn
bpe(i,*,*)=pe                                          
 Print, 'Finished ', strcompress(filename,/remove_all)
 endfor
ex=0
ey=0
ez=0
bx=0
by=0
bz=0
ux=0
uy=0
uz=0
pe=0
Print, 'The End' 
end 


 
