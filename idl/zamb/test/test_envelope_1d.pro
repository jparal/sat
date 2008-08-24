; 1D testing

pro test_envelope_1d

LX = 10.
LP = 3.
wavelength = 0.5
k = 2*!PI/(wavelength)

NX = 1000
x = findgen(NX)*LX/(NX-1)


;y = ptr_new( cos(k*x)*(exp(-(x-3*LX/4)^2/ (LP/4)^2) + $
;             0.5*exp(-(x-LX/4)^2/ (LP/4)^2)) )

y =  cos(k*(x-0.1))*(0.5*(exp(-((x)^2)/ (2*LP/4)^2))  + $
             exp(-(x-3*LX/4)^2/ (LP/4)^2)) 

py = ptr_new(y)

window, /free

plot, x,(*py), TITLE = 'Laser Pulse'

envelope, py, /mirror, kmin = 100

oplot, x,(*py) & oplot, x,-(*py)


end