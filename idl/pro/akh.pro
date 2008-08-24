; equation (5.1.5.1) p221 of 
; Akhiezer & comp.
pro akh, om,theta,k2p,k2m
theta1=theta*!pi/180.
eps1=-om^2/(om^2-1)
eps2=-om/(om^2-1)
ct2=cos(theta1)^2
uct=1+ct2
k2p=.5/ct2*(eps1*ct2+sqrt(eps1^2*ct2-4*(eps1^2-eps2^2)*ct2 ))
k2m=.5/ct2*(eps1*ct2-sqrt(eps1^2*ct2-4*(eps1^2-eps2^2)*ct2 ))
return
end
