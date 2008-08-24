pro anime, data, MAGNIFY=magnify, FILE=file, RES=res, TINDEX=tindex
;
; ANIME   (SAT IDL Library Copyright)
;
; Generate animation from array of data.
;
; SYNTAX:
;
;  ANIME, data [,MAGNIFY=value] [,FILE=value] [,RES=value] [,TINDEX=value]
;
; GRAPHICS KEYWORDS:
;
;
; ARGUMENTS:
;
; data
;   Data array of size 3 (currently) where one of the indexes is time
;
; KEYWORDS:
;
; MAGNIFY: Single value or array of integers for each of the dimensions
;   specifying magnification of the given axis.
;
; FILE: Prefix of the file names of the pictures needed for movie generation.
;   Currently only PNG files are supported.
;
; RES: Resolution of the output canvas (see IDL manual for SET_RESOLUTION)
;
; TINDEX: Which index of the array is the time index. (Doesn't work now. Assume
;   that time index is the third one)
;
; AUTHORS:
;  Jan Paral <jparal@seznam.cz>
;
; HISTORY:
;  12 Sept 2005 - Created
;
if(not(keyword_set(TINDEX)))then tindex=3
if(not(keyword_set(MAGNIFY)))then magnify=1
if(not(keyword_set(FILE)))then file=' '

s1=size(magnify)
s=size(data)
n=s(3)
sx=s(1)
sy=s(2)

if(s1(0)eq 0) then begin
    sx=magnify*sx
    sy=magnify*sy
endif else begin
   sx=magnify(0)*sx
   sy=magnify(1)*sy
endelse

fmin=min(data)
fmax=max(data)
if(file eq ' ')then begin
    XINTERANIMATE, SET = [sx, sy, n]
    for i=0,n-1 do begin
        XINTERANIMATE,IMAGE=rebin(255*(reform(data(*,*,i))-fmin)/(fmax-fmin), $
                                  sx,sy), frame=i
    endfor
    XINTERANIMATE,/KEEP_PIXMAPS
;XINTERANIMATE,/close
endif else begin
    if(keyword_set(RES))then device,SET_RESOLUTION=RES
    for i=0,n-1 do begin
        imb,255*(reform(data(*,*,i))-fmin)/(fmax-fmin)
        write_png,string(file,i,'.png',format='(A,I5.5,A)'),tvrd(true=1)
    endfor
    print,'To encode the pitures into the movie run:'
    print,'mencoder "mf://*.png" -mf fps=24 -o output.avi -ovc lavc -lavcopts vcodec=mpeg2video:vbitrate=10000:vhq'
endelse
return
end
