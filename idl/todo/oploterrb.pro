pro oploterrb,x,y,err,THICK=thick,BARSIZE=bsize,CIRCLESIZE=csize
;
; OPLOTEB   (SAT IDL Library Copyright)
;
; Overplot nicer error bars.
;
; SYNTAX:
;
;  OPLOTERRB,[x,] y, err[,BARSIZE=value] [,CIRCLESIZE=value]
;
; GRAPHICS KEYWORDS:
; [THICK=value]
;
; ARGUMENTS:
;
; x
;   data array of size n with x coordinates
; y
;   data array of size n with y coordinates
; err
;   error size so y value is in y+-error
;
; KEYWORDS:
;
; BARSIZE: Size of the bars which are on the end of error lines
;
; CIRCLESIZE: Size of the circles which are where bars and curve.
;
; AUTHORS:
;  Jan Paral <jparal@seznam.cz>
;
; HISTORY:
;  12 Sept 2005 - Created
;
if(not(keyword_set(bsize))) then bsize=3
if(not(keyword_set(csize))) then csize=1.3
if(not(keyword_set(thick))) then thick=5

A = FINDGEN(17) * (!PI*2/16.)
USERSYM, csize*COS(A), csize*SIN(A), THICK=thick

OPLOTERR, x, y, err, 8

;Plot ticks on the error bars:
USERSYM, [-bsize, bsize], [0, 0], THICK=thick
OPLOT, x, y+err, PSYM=8
OPLOT, x, y-err, PSYM=8

return
end
