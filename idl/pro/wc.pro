pro wc, k1,k2,k3,bx,by,bz, bpa,bpe1,bpe2
l1=-k2
l2=k1
l3=0.
k=1./sqrt(k1^2+k2^2+k3^2)
k1=k*k1
k2=k*k2
k3=k*k3
l=1./sqrt(l1^2+l2^2+l3^2)
l1=l*l1
l2=l*l2
l3=l*l3
m1=k2*l3-l2*k3
m2=k3*l1-l3*k1
m3=k1*l2-l1*k2
bpa=k1*bx+k2*by+k3*bz
bpe1=l1*bx+l2*by+l3*bz
bpe2=m1*bx+m2*by+m3*bz
return
end
