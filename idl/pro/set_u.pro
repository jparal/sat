;
pro set_u, u0, u1, u,dn,ux,uy,uz,p,bx,by,bz
aug=u0+ (u1-u0)/100.*findgen(101)
umin=fltarr(101)
mm=1e20
for i=0,100 do begin
rh1, aug(i),dn,ux,uy,uz,p,bx,by,bz,ff
ff=ff-shift(ff,1,0,0)
ff= reform(ff(1:*,*,*))
umin(i)=max(abs(ff))
if (umin(i) lt mm) then begin
mm=umin(i)
u=aug(i)
endif
endfor
plot, aug, umin
return
end
