i=findgen(100)
k1=exp(-(i-50)^2/80)
k2=exp(-(i-75)^2/30)
l=sin(2*!pi*i/40) + $
1.42*sin(2*!pi*i/14-2.1)
plot,l 
