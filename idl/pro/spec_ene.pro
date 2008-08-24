pro spec_ene, a1,a2,a3,a4,r1,r2,r3,r4, o, k, p
oi=1./o
i=complex(0,1)
vt=[[1,0,0], $
    [0,1,0], $
    [0,0,1], $
    [0,       -k(2)*oi, k(1)*oi  ], $
    [k(2)*oi,  0,      -k(0)*oi  ], $
    [-k(1)*oi, k(0)*oi, 0        ]]
h=fltarr(6,24)
e1=exp(-i*total(k1*r1))
e2=exp(-i*total(k2*r2))
e3=exp(-i*total(k3*r3))
e4=exp(-i*total(k4*r4))
for i=0,5 do begin
  h(i,i)=e1
  h(i,i+6)=e2
  h(i,i+12)=e3
  h(i,i+18)=e4
endfor
a=fltarr(24)
for i=0,5 do begin
  a(i)=a1(i)
  a(i+6)=a2(i)
  a(i+12)=a3(i)
  a(i+18)=a4(i)
endfor
s= a#a
ht=conj(transpose(h))
v=transpose(vt)
p=trace(vt*inverse(v*ht*inverse(s)*h*vt)*v)
return
end
