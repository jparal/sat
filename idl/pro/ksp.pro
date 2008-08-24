; res abs(det(g)) over arrays k1, k2, k3, for one k0
; 
 pro ksp, k1, k2,k3, k0,om, phi, ma, v1,v2,al, g
 phi=phi*!pi/180.
 s1=size(k1)
 s2=size(k2)
 s3=size(k3)
 g=fltarr(s1(1),s2(1),s3(1))
 for i=0,s1(1)-1 do begin
 for j=0,s2(1)-1 do begin
 for k=0,s3(1)-1 do begin
 disp, k1(i), k2(j), k3(k),k0,om, phi, ma, v1,v2,al, g1
 g(i,j,k)=g1
 endfor
 endfor
 endfor
 return
 end
