; Assuming 3D simulation plot a cutt in (x,y) plane
; of the simulation domain
;
; Example:    plotexy, 'test', 'i0'

pro plotexy, name, time

rd3, 'Ex'+name+time, ex
rd3, 'Ey'+name+time, ey
rd3, 'Ez'+name+time, ez

loadct,13
ee = sqrt (ex*ex+ey*ey+ez*ez)
ss = size(ee)
im, ee (*, *, ss (3)/2)

end
