pro lis,c0, a,b
c1=(1.-c0)/7.
c2=c1/4.
c3=-c2
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
