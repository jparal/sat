pro lis2, a,b
c0=1./8.
c1=1./16.
c2=1./32.
c3=1./64.
b=a*c0+c1*shift(a,1,0,0) + c1*shift(a,-1,0,0) $
+c1*shift(a,0,1,0) + c1*shift(a,0,-1,0) $
+c1*shift(a,0,0,1) + c1*shift(a,0,0,-1) $
+c2*shift(a,1,1,0) + c2*shift(a,-1,1,0) $
+c2*shift(a,1,-1,0) + c2*shift(a,-1,-1,0) $
+c2*shift(a,0,1,1) + c2*shift(a,0,-1,1) $
+c2*shift(a,0,1,-1) + c2*shift(a,0,-1,-1) $
+c2*shift(a,1,0,1) + c2*shift(a,-1,0,1) $
+c2*shift(a,1,0,-1) + c2*shift(a,-1,0,-1) $
+c3*shift(a,1,1,1) + c3*shift(a,-1,-1,-1) $
+c3*shift(a,1,-1,1) + c3*shift(a,-1,1,-1) $
+c3*shift(a,1,1,-1) + c3*shift(a,-1,-1,1) $
+c3*shift(a,-1,1,1) + c3*shift(a,1,-1,-1)
return
end
