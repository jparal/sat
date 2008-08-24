pro plotdnxy, name, time, b=b, planet=planet,sp=sp
;
; PLOTDNXY   (SAT IDL Library Copyright)
;
; Plot density in equatorial plane, profile of magnetic field and planet
;
; SYNTAX:
;
;  PLOTDNXY, NAME, TIME, [,/B] [,PLANET=[5]] [,SP=NUM]
;
; GRAPHICS KEYWORDS:
;
;
; ARGUMENTS:
;
;  NAME: Name of the simulation run
;
;  TIME: Time of the data (including i or t and suffix)
;
; KEYWORDS:
;
; B: Overplot profile of magnetic field
;
; PLANET: Array specifing position of the planet where:
;  PLANET(0) - relative x position (typicaly <=0.5)
;  PLANET(1) - relative y position (typicaly 0.5)
;  PLANET(2) - radius of the planet in Lin
;  PLANET(3) - resolution on the x-axis  (dx)
;  PLANET(4) - resolution on the y-axis  (dx)
;
; SP: Number of specie (in the case of missing we expect to be total density)
;
; AUTHORS:
;  Jan Paral <jparal@gmail.cz>
;
; HISTORY:
;  10 July 2006 - Created
;
if keyword_set(sp) then begin
    dnfile = string('Dn',sp,name,time,format='(A,I1.1,A,A)')
endif else begin
    dnfile = string('Dn',name,time)
endelse

rd3, dnfile, dn
if keyword_set(b) then begin
    rd3, 'Bx'+name+time, bx
    rd3, 'By'+name+time, by
    rd3, 'Bz'+name+time, bz
    bb = sqrt (bx*bx+by*by+bz*bz)
endif

ss = size(dn)

loadct,13

im, dn (*, *, ss (3)/2)

if keyword_set(b) then begin
    oplot, 5*alog10 (bb (*, ss (2)/2, ss (3)/2))+ss (2)/2,color=25
endif

if keyword_set(planet) then begin
    sp = size (planet)
    r = planet(2)
    d = findgen(100)
    oplot, r*sin(d/10)/planet(3) + ss(1)*planet(0), r*cos(d/10)/planet(4)+ss(2)*planet(1),thick=2.0
endif

end
