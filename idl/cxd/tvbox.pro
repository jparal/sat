;-------------------------------------------------------------
;+
; NAME:
;       TVBOX
; PURPOSE:
;       Draw or erase a box on the image display.
; CATEGORY:
; CALLING SEQUENCE:
;       tvbox, x, y, dx, dy, clr
; INPUTS:
;       x = Device X coordinate of lower left corner of box.  in
;       y = Device Y coordinate of lower left corner of box.  in
;       dx = Box X size in device units.                      in
;       dy = Box Y size in device units.                      in
;       clr = box color.                                      in
;          -1 to just erase last box (only last box).
;          -2 for dotted outline.  Useful if box must cover an
;             unknown range of colors.
; KEYWORD PARAMETERS:
;       Keywords:
;         /NOERASE  causes last drawn box not to be erased first.
;         /COPY  use first time to set screen copy mode.  Good for
;           windows on slow machines.  Uses an internal copy of the
;           screen image instead of tvrd (tvrd is up to 16 times
;           slower than tv on some machines).  Avoid for large
;           windows.  Unneeded on fast machines.
;        /NOCOPY  unsets the COPY mode.
; OUTPUTS:
; COMMON BLOCKS:
;       box_com
; NOTES:
;       Notes: /COPY and /NOCOPY should be used with no
;         other parameters.
; MODIFICATION HISTORY:
;       R. Sterner, 25 July, 1989
;       R. Sterner, 1994 Jan 11 --- Added copy mode.
;       R. Sterner, 1994 Aug 31 --- Added dotted outline.
;       R. Sterner, 1994 Nov 27 --- Changed dotted colors from 0,255
;       to darkest, brightest.
;
; Copyright (C) 1989, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
 
	pro tvbox, x, y, dx, dy, clr, noerase=noeras, $
	  copy=copy, nocopy=nocopy, help=hlp 
 
	common box_com, xc, yc, dxc, dyc, bb, bl, bt, br, cmode, img
	;  box_com: values needed to erase the old box.
	;	xc, yc, dxc, dyc = old box position and size.
	;	bb, bl, bt, br = image under box bottom, left, top, right.
	;	cmode = copy mode flag. 0: use tvrd, 1:use screen copy image.
	;	img = copy of screen image.
	;-------------------------------------------------------------
 
	if keyword_set(hlp) then begin
	  print,' Draw or erase a box on the image display.'
	  print,' tvbox, x, y, dx, dy, clr'
  	  print,'   x = Device X coordinate of lower left corner of box.  in'
  	  print,'   y = Device Y coordinate of lower left corner of box.  in'
	  print,'   dx = Box X size in device units.                      in' 
	  print,'   dy = Box Y size in device units.                      in' 
	  print,'   clr = box color.                                      in'
	  print,'      -1 to just erase last box (only last box).'
	  print,'      -2 for dotted outline.  Useful if box must cover an
          print,'         unknown range of colors.'
	  print,' Keywords:'
	  print,'   /NOERASE  causes last drawn box not to be erased first.'
	  print,'   /COPY  use first time to set screen copy mode.  Good for'
	  print,'     windows on slow machines.  Uses an internal copy of the'
	  print,'     screen image instead of tvrd (tvrd is up to 16 times'
	  print,'     slower than tv on some machines).  Avoid for large'
	  print,'     windows.  Unneeded on fast machines.''
	  print,'  /NOCOPY  unsets the COPY mode.'
	  print,' Notes: /COPY and /NOCOPY should be used with no'
	  print,'   other parameters.'
	  return
	endif
 
	if keyword_set(copy) then begin		; Start copy mode.
	  img = tvrd()				; Read screen image.
	  cmode = 1				; Copy mode flag.
	  return
	endif
 
	if keyword_set(nocopy) then begin	; End copy mode.
	  img = 0				; Delete screen copy.
	  cmode = 0				; No copy mode.
	  return
	endif
 
	if n_elements(cmode) eq 0 then cmode=0
 
	if not keyword_set(noeras) then begin 	; Not NOERASE.
	  if n_elements(bb) ne 0 then begin	; Something to erase?
  	    x2 = xc + dxc - 1
	    y2 = yc + dyc - 1
	    tv, bb, xc, yc		        ; Restore parts of image
	    tv, bl, xc, yc		        ; beneath box.
	    tv, bt, xc, y2
	    tv, br, x2, yc
	    if clr eq -1 then return	        ; Only erase old box.
	  endif
	endif  ; not noerase.
 
	x2 = x + dx - 1			        ; Box corner.
	y2 = y + dy - 1
 
	if cmode then begin			; Copy mode.
	  bb = img(x:x2,y)
	  bl = img(x,y:y2)
	  bt = img(x:x2,y2)
	  br = img(x2,y:y2)
	endif else begin			; No copy mode.
	  bb = tvrd(x, y, dx,1)	                ; Save image beneath box.
	  bl = tvrd(x, y, 1, dy)
	  bt = tvrd(x, y2,dx,1)
	  br = tvrd(x2,y, 1, dy)
	endelse
 
	xc = x & yc = y & dxc = dx & dyc = dy   ; Save box position and size.
 
	if clr eq -2 then begin
	  tvlct,/get,r_curr,g_curr,b_curr
	  ;-----  4 lines lefted from ct_luminance (userslib)  ----
 	  lum= (.3 * r_curr) + (.59 * g_curr) + (.11 * b_curr)
	  bright = max(lum, min=dark)
	  c1 = where(lum eq bright)
	  c2 = where(lum eq dark)
	  c1 = c1(0) & c2 = c2(0)
	  xx = [maken(x,x2,dx),maken(x2,x2,dy),maken(x2,x,dx),maken(x,x,dy)]
	  yy = [maken(y,y,dx),maken(y,y2,dy),maken(y2,y2,dx),maken(y2,y,dy)]
	  cc = c1+((indgen(n_elements(xx)) mod 6) lt 3)*(c2-c1)
	  plots,xx,yy,/dev,color=cc
	endif else begin
	  plots,[x,x2,x2,x,x],[y,y,y2,y2,y],/device,color=clr
	endelse
 
	return
 
	end
