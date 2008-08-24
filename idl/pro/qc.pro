pro gene, g
s=size(g)
i=0
toto: 
g(0)=g(0)+1
for i=0,s(1)-2 do begin
if(g(i) eq 2) then begin
g(i)=0
g(i+1)=g(i+1)+1
endif
endfor
if(g(s(1)-1) eq 2 )then return
a=0
for i=0, s(1)-2 do begin
a=g(i)*g(i+1)+a
endfor
if(a gt 0)then goto, toto
return
end

pro qc, n, qx,qy
t=(sqrt(5)+1)/2.
tau=t^indgen(n)
ph=2*!pi/5.
a1=1.
b1=0.
a2=cos(ph)
a3=cos(2*ph)
a4=cos(3*ph)
a5=cos(4*ph)
b2=sin(ph)
b3=sin(2*ph)
b4=sin(3*ph)
b5=sin(4*ph)
g1=intarr(n)
n0=0l
ott:
n0=n0+1l
gene,g1
if(g1(n-1) lt 2)then goto, ott 
g1=intarr(n)
g2=intarr(n)
g3=intarr(n)
g4=intarr(n)
g5=intarr(n)
print,n0,n0^5
qx=fltarr(n0^5,/nozero)
qy=qx
qx(0)=0
qy(0)=0
for i=1l,n0^5-1l do begin
gene,g1
if (g1(n-1) eq 2) then begin
g1=intarr(n)
gene,g2
if (g2(n-1) eq 2) then begin
g2=intarr(n)
gene,g3
if (g3(n-1) eq 2) then begin
g3=intarr(n)
gene,g4
if (g4(n-1) eq 2) then begin
g4=intarr(n)
gene,g5
if (g5(n-1) eq 2) then g5=intarr(n)
endif
endif
endif
endif


qx(i)=a1*total(g1*tau) + $
      a2*total(g2*tau) + $
      a3*total(g3*tau) + $
      a4*total(g4*tau) + $
      a5*total(g5*tau) 
qy(i)=b1*total(g1*tau) + $
      b2*total(g2*tau) + $
      b3*total(g3*tau) + $
      b4*total(g4*tau) + $
      b5*total(g5*tau) 
endfor
return
end
