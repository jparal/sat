; Assuming 3D simulation plot a cutt in (x,y) plane
; of the simulation domain
;
; Example:    plotbxy, 'test', 'i0'

pro plotbxy, name, time

rd3, 'Bx'+name+time, bx
rd3, 'By'+name+time, by
rd3, 'Bz'+name+time, bz

loadct,3
bb = sqrt (bx*bx+by*by)
ss = size(bb)
im, alog10(bb (*, *, ss (3)/2))

ss = size(bx)
loadct,13
bb = sqrt (bx*bx+by*by)
oplot, 20*alog10 (bb (*, ss (2)/2, ss (3)/2))+ss (2)/2,color=45
axb = fltarr (ss (1))
axb(*) = float(ss (2)/2)
help,axb
oplot, axb,color=0

end
