X = FINDGEN(20, 20)	 ;Create array X.
Y = sin(X)*X	 ;Create array Y.


X = Dist(20)
Y = Sin(x)*100


;window, /free
;PLOT_FIELD, X, Y, TITLE = 'PLOT_FIELD'	 ;Create plot.

window, /free
VELOVECT, X, Y, TITLE = 'VELOVECT' 

window, /free

Help, X, y
VEL, X, Y, TITLE = 'VEL', NVECS = 500


;window, /free

;vx = RANDOMU(seed, 5, 5, 5)
;vy = RANDOMU(seed, 5, 5, 5)
;vz = RANDOMU(seed, 5, 5, 5)

;Scale3, xr = [0,4], yr = [0,4], zr = [0,4]
;Flow3, vx, vy, vz






END