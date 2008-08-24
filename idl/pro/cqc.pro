pro cqc, qx,qy
i=0l
qx1=qx
qy1=qy
ss=size(qx)
ss=ss(1)
toto:
g=where((qx ne qx1(i)) or (qy ne qy1(i)))
qx=qx(g)
qy=qy(g)
s=size(qx)
i=i+1l
print,i,s(1),ss-s(1)
qx1(i)=qx(0)
qy1(i)=qy(0)
if (s(1) gt 1) then goto,toto
qx1=qx1(0:i)
qy1=qy1(0:i)
qx=qx1
qy=qy1
return
end
