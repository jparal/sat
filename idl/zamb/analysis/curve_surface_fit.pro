; COMFIT( )	Gradient-expansion least squares fit to paired data.
; CURVEFIT( )	Non-linear least squares fit to a function.
; CRVLENGTH()	Compute the length of a curve with tabular representation.
; GAUSSFIT( )	Fit sum of a gaussian and a quadratic.
; LADFIT( )	Least absolute deviation fit to paired data.
; LINFIT( )	Minimal Chi-square fit to paired data.
; POLY_FIT( )	Polynomial least squares fit.
; POLYFITW( )	Weighted polynomial least squares fit.
; REGRESS( )	Multiple linear regression.
; SFIT( )		Determine a polynomial fit to a surface.
; SVDFIT( )	General least squares fit using SVD.


pro curve_surface_fit

; COMFIT DEMO

N = 200

x = findgen(N)/(N-1) * 10.0

a0 = 10.0
x0 = 2.75

w0 = 1.23

y = a0 * exp(-(x-x0)^2/(2*w0^2)) 

help, Max(y)

help, x*y

help, Mean(x*y)
help, Meanabsdev(x*y)

yft = gaussfit(x,y, coeff)

window, /free, title = 'gaussFIT() Demo'
plot, x, y

window, /free, title = 'gaussFIT() Demo'
plot, x, yft


end