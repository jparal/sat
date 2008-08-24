function plotsym, circle=circle, triangle=triangle, diamond=diamond, $
                  angle=angle, box=box, line=line, scale=scale, $
                  _extra=extra
;+
; NAME:
;  plotsym
; PURPOSE:
;  function to make plotting symbols much easier.
; Usage:
;   plot,x,y,psym=plotsym(/circle,scale=2,/fill)
;
; CATEGORY:
;   Graphics.
;
; Keywords:
;  circle =  circle symbol
;  triangle = triangle symbol
;  diamond = diamond symbold
;  box = box symbol
;  line = line symbol
;  scale = scales the symbol
;  angle = angle the symbol should be rotated
;  _extra = extra keywords for usersym.  These are thick, color and fill
;
; Written by:
; Ronn Kling
; Kling Research and Software
; 7038 Westmoreland Dr.
; Warrenton, VA 20187
; ronn@rlkling.com
;
; LICENSE
;
; This software is OSI Certified Open Source Software.
; OSI Certified is a certification mark of the Open Source Initiative.
;
; Copyright © 1997-2001 Kling Research and Software.
;
; This software is provided "as-is", without any express or
; implied warranty. In no event will the authors be held liable
; for any damages arising from the use of this software.
;
; Permission is granted to anyone to use this software for any
; purpose, including commercial applications, and to alter it and
; redistribute it freely, subject to the following restrictions:
;
; 1. The origin of this software must not be misrepresented; you must
;    not claim you wrote the original software. If you use this software
;    in a product, an acknowledgment in the product documentation
;    would be appreciated, but is not required.
;
; 2. Altered source versions must be plainly marked as such, and must
;    not be misrepresented as being the original software.
;
; 3. This notice may not be removed or altered from any source distribution.
;
; For more information on Open Source Software, visit the Open Source
; web site: http://www.opensource.org.
;-


if not keyword_set(scale) then scale=1.0
if not keyword_set(angle) then angle=0.0

if keyword_set(circle) then begin
  theta = findgen(30)/29.*360.
endif else if keyword_set(triangle) then begin
  theta = [-30.,90.,210., -30.]
endif else if keyword_set(diamond) then begin
  theta = [0.,90.,180.,270.,0.]
endif else if keyword_set(box) then begin
  theta = [315.,45.,135.,225.,315.]
endif else if keyword_set(line) then begin
  theta = [-180.,0.]
endif

theta = theta + angle
x = cos(theta * !dtor) * scale
y = sin(theta * !dtor) * scale

usersym, x,y, _extra=extra
return,8
end