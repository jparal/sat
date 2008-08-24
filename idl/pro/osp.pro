; res abs(det(g)) over arrays k1,omr,omi
; 
 pro osp, k1,omr,omi, phi,  g
 s1=size(k1)
 s2=size(omr)
 s3=size(omi)
 i=complex(0,1)
 g=fltarr(s1(1),s2(1),s3(1))
 for i=0,s1(1)-1 do begin
 for j=0,s2(1)-1 do begin
 for k=0,s3(1)-1 do begin
 dispf,k1(i),0,omr(j),omi(k),0, phi, g1
 g(i,j,k)=g1
 endfor
 endfor
 endfor
 return
 end
