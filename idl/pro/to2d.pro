; 1d arrays from whamp transformed to 2d arrays omega(kpe,kpa)
;        >steps k<  >1d arrays inp<  >outp 1dk & 2d omega<
pro to2d,dkpe,dkpa, kpe,kpa,or0,oi0, ikpe,ikpa, omer,omei
s=size(kpe)
n=s(1)
kpema=max(kpe)
kpama=max(kpa)
kpemi=min(kpe)
kpami=min(kpa)
nkpe=(kpema-kpemi)/dkpe+1
nkpa=(kpama-kpami)/dkpa+1
ikpe=findgen(nkpe)*dkpe+kpemi
ikpa=findgen(nkpa)*dkpa+kpami
omer=fltarr(nkpe,nkpa)
omei=omer
epspe=dkpe/3.
epspa=dkpa/3.
print,nkpe,nkpa
for i=0,nkpe-1 do begin
print,i
for j=0,nkpa-1 do begin
aug=where((abs(kpe-ikpe(i)) lt epspe) and $
          (abs(kpa-ikpa(j)) lt epspa) )
sau=size(aug)
if(sau(0) ge 1)then begin
oraug=or0(aug)
oiaug=oi0(aug)
omer(i,j)=oraug(0)
omei(i,j)=oiaug(0)
endif
endfor
endfor
return
end
