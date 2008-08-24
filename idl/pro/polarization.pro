pro polarization, image,image1, sx = sx, sy = sy, wsize = wsize, order = order
;+
; NAME:
;	POLARIZATION
;
; PURPOSE:
;	Interactively draw row or column polarization of two images 
;       in a separate window.
;
; CATEGORY:
;	Image analysis.
;
; CALLING SEQUENCE:
;	POLARIZATION, Image, Image1 [, SX = sx, SY = sy]
;
; INPUTS:
;	Image:	The variable that represents the horizontal axis,
;               displayed in current window.
;	        This data need not be scaled into bytes.
;		The profile graphs are made from this array.
;	Image1:	The second variable that represents the vertical
;               axis. This data need not be scaled into bytes.
;		The profile graphs are made from this array.
;
; KEYWORD PARAMETERS:
;	SX:	Starting X position of the image in the window.  If this 
;		keyword is omitted, 0 is assumed.
;
;	SY:	Starting Y position of the image in the window.  If this
;		keyword is omitted, 0 is assumed.
;
;	WSIZE:	The size of the POLARIZATION window as a fraction or multiple 
;		of 640 by 512.
;
;	ORDER:	Set this keyword param to 1 for images written top down or
;		0 for bottom up.  Default is the current value of !ORDER.
;
; OUTPUTS:
;	No explicit outputs.
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	A new window is created and used for the polarizations.  When done,
;	the new window is deleted.
;
; RESTRICTIONS:
;	None.
;
; PROCEDURE:
;	A new window is created and the mouse location in the original
;	window is used to plot polarization in the new window.  Pressing the
;	left mouse button toggles between row and column profiles.
;	The right mouse button exits.
;
; EXAMPLE:
;	Create and display an image and use the polarization routine on it.
;	Create and display the image by entering:
;
;		Ax = BYTSCL(sin(DIST(256)/5.)*DIST(256))
;		Ay = BYTSCL(cos(DIST(256)/5.)*DIST(256))
;		TV, Ax
;
;	Run the PROFILES routine by entering:
;
;		POLARIZATION, Ax,Ay
;
;	The POLARIZATION window should appear.
;       Move the cursor over the original
;	image to see the profile at the cursor position.  Press the left mouse
;	button to toggle between row and column profiles.  Press the right
;	mouse button (with the cursor over the original image) to exit the
;	routine.
;
; MODIFICATION HISTORY:
;	PH, 1995  
;-
on_error,2                              ;Return to caller if an error occurs
if n_elements(sx) eq 0 then sx = 0	;Default start of image
if n_elements(sy) eq 0 then sy = 0
if n_elements(wsize) eq 0 then wsize = .75
s = size(image)
maxv = max(image) 			;Get extrema
minv = min(image)
maxv1 = max(image1) 			
minv1 = min(image1)
orig_w = !d.window
nx = s(1)				;Cols in image
ny = s(2)				;Rows in image
tvcrs,sx+nx/2,sy+ny/2,/dev
tickl = 0.1				;Cross length
print,'Left mouse button to toggle between rows and columns.'
print,'Right mouse button to Exit.'
window,/free ,xs=wsize*640, ys=wsize*512,title='Polarization' ;Make new window
new_w = !d.window
old_mode = -1				;Mode = 0 for rows, 1 for cols
old_font = !p.font			;Use hdw font
!p.font = 0
mode = 0
if n_elements(order) eq 0 then order = !order	;Image order

while 1 do begin
	wset,orig_w		;Image window
	cursor,x,y,2,/dev	;Read position

	if !err eq 1 then begin
		mode = 1-mode	;Toggle mode
		repeat cursor,x,y,0,/dev until !err eq 0
		endif

	x = x - sx		;Remove bias
	y = y - sy
	wset,new_w		;Graph window

	if !err eq 4 then begin		;Quit
		wset,orig_w
		tvcrs,nx/2,ny/2,/dev	;curs to old window
		tvcrs,0			;Invisible
		wdelete, new_w
		!p.font = old_font
		return
		endif
	if mode ne old_mode then begin
		old_mode = mode
		first = 1
		if mode then begin	;Columns?
			plot,[minv,maxv],[minv1,maxv1],$
/nodat,title='Column Profile'
			crossx = [-tickl, tickl]*(maxv-minv)
			crossy = [-tickl, tickl]*(maxv1-minv1)
		end else begin
			plot,[minv,maxv],[minv1,maxv1],$
/nodata,title='Row Profile'
			crossx = [-tickl, tickl]*(maxv-minv)
			crossy = [-tickl, tickl]*(maxv1-minv1)
		endelse
	endif

	if (x lt nx) and (y lt ny) and $
		(x ge 0) and (y ge 0) then begin	;Draw it
		
		if order then y = (ny-1)-y	;Invert y?
		if first eq 0 then begin	;Erase?
			plots, vecx, vecy, col=0	;Erase graph
			plots, old_x, old_y, col=0	;Erase cross
			plots, old_x1, old_y1, col=0
			xyouts,.1,0,/norm,value,col=0	;Erase text
			empty
		  endif else first = 0
;;;;		value = string([x,y],format="('(',i4,',',i4,')')")
;;;;		value = strtrim(x,2) + string(y)
		value = strmid(x,8,4)+strmid(y,8,4)
		ixy = image(x,y)		;Data value
		if mode then begin		;Columns?
			vecx = image(x,*)	;get column
			vecy = image1(x,*)	;get column
			old_x = crossx + ixy
			old_y = [y,y]
			old_x1 = [ixy, ixy]
			old_y1 = crossy + y
		  endif else begin
			vecy = image1(*,y)	;get row
			vecx = image(*,y)	;get row
			old_x = [ x,x]
			old_y = crossy + ixy
			old_x1 = crossx + x
			old_y1 = [ixy,ixy]
		  endelse
		xyouts,.1,0,/norm,value	;Text of locn
		plots,vecx,vecy		;Graph
		plots,old_x, old_y	;Cross
		plots,old_x1, old_y1
		endif
endwhile
end
