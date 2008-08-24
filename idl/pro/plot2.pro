pro plot2,x, y1,y2,psym=psym
if not(keyword_set(psym))then psym=[0,0]
nn=n_params(0)
if(nn lt 2)then begin
message,' Not enough parameters lt 2 plot2,[x,] y1,y2'
return
endif
if(nn eq 2)then begin
yy1=x
yy2=y1
s=size(yy1)
xx=findgen(s(1))
endif else begin
xx=x
yy1=y1
yy2=y2
endelse
;
x0=0.417969    
y0= 0.582031
g=replicate(' ',30)
!p.region=[0.,x0,1.,1.]
plot,xx,yy1,xtickname=g,psym=psym(0)
!p.region=[0.,0.,1.,y0]
plot,xx,yy2,/noerase,psym=psym(1)
!p.region=[0.,0.,1.,1.]
return
end
