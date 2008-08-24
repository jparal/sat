function stw_cross_prd, veca, vecb

sa=size(veca,/type)
if (sa(0) eq 0) then return, -1
sb=size(vecb,/type)
if (sb(0) eq 0) then return, -1
sa=size(veca) & sb=size(vecb)

dim=sa(0)-1
if (dim ne sb(0)-1) then return, -1

if (sa(0) ne 4 or sb(0) ne 4) then return, -1
if (sa(4) ne 3 or sb(4) ne 3) then return, -1
nx=sa(1)
ny=sa(2)
nz=sa(3)
if (nx ne sb(1) or ny ne sb(2) or nz ne sb(3)) then return, -1

vec = fltarr(nx,ny,nz,3)

vec(*,*,*,0)=veca(*,*,*,1)*vecb(*,*,*,2)-veca(*,*,*,2)*vecb(*,*,*,1)
vec(*,*,*,1)=veca(*,*,*,2)*vecb(*,*,*,0)-veca(*,*,*,0)*vecb(*,*,*,2)
vec(*,*,*,2)=veca(*,*,*,0)*vecb(*,*,*,1)-veca(*,*,*,1)*vecb(*,*,*,0)

return, vec
end
