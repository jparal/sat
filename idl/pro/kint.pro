pro kint, ff,ix,iy,sp,k,spt,th,nth=nth
if(not(keyword_set(nth)))then nth=181
sf=size(ff) 
kmax=sqrt(max(ix)^2+max(iy)^2)
nk=sf(2)
dk=kmax/(nk-2)*1.0001  
k=findgen(nk)*dk 
sp=fltarr(nk,sf(3))
th=findgen(nth)*180./(nth-1)-90.
dth=180./(nth-1)
spt=fltarr(nth,sf(3)) 
for i=0,sf(1)-1 do begin
for j=0,sf(2)-1 do begin
  kij=sqrt(ix(i)^2+iy(j)^2)
  nkij=fix(kij/dk)
  a2=kij/dk-nkij
  a1=1.-a2
  sp(nkij,*)=sp(nkij,*)+a1*ff(i,j,*)
  sp(nkij+1,*)=sp(nkij+1,*)+a2*ff(i,j,*)
  if(kij gt 0.)then begin
    thi=180*atan(iy(j),ix(i))/!pi
    thi=thi+90.
    ntij=fix(thi/dth)
    a2=thi/dth-ntij
    a1=1.-a2
    if(ntij ge 0 and ntij lt nth-1)then begin
        spt(ntij,*)=spt(ntij,*)+a1*ff(i,j,*)
        spt(ntij+1,*)=spt(ntij+1,*)+a2*ff(i,j,*)
    endif
    if(ntij eq nth-1)then begin
        spt(ntij,*)=spt(ntij,*)+a1*ff(i,j,*)
    endif
  endif
endfor
endfor   
return
end
