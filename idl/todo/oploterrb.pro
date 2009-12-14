pro oploterrb,x,y,err,THICK=thick,BARSIZE=barsize,CIRCLESIZE=circlesize, $
              COLOR=color
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
  if(not(keyword_set(barsize))) then barsize=3
  if(not(keyword_set(circlesize))) then circlesize=0.01
  if(not(keyword_set(color))) then color='Black'
;; if(not(keyword_set(thick))) then thick=5

  clr = !P.COLOR
  !P.COLOR=FSC_COLOR(color)

  A = FINDGEN(17) * (!PI*2/16.)
  USERSYM, circlesize*COS(A), circlesize*SIN(A), THICK=thick

  OPLOTERR, x, y, err, 8

;Plot ticks on the error bars:
  USERSYM, [-barsize, barsize], [0, 0], THICK=thick
  OPLOT, x, y+err, PSYM=8
  OPLOT, x, y-err, PSYM=8

  !P.COLOR = clr

  return
end
