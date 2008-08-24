; fourier transformation of 2d array a as abs(fft a)
; with X =xmax and Y=ymax, output fta coordinates ix,iy 
pro foutr3,an,x,y,z,fta,ix,iy,iz 
;,upper=upper,full=full
;if not(keyword_set(upper)) then upper=0
;if not(keyword_set(full)) then full=0
a=an-mean(an)
s=size(a)
if(s(0) eq 3) then begin
  s1=s(1)
  s2=s(2)
  s3=s(3)
  f=abs(fft(a,1))/sqrt(1.*s1*s2*s3)
  s1h=s1/2
  s2h=s2/2
  s3h=s3/2
;  if(full eq 0) then begin
;    if(upper eq 0) then begin
      fta=shift(f(0:s1h,*,*),0,s2h,s3h)
      ix=findgen(s1h+1)*2*!pi/x
      iy=(findgen(s2)-s2h)*2*!pi/y
      iz=(findgen(s3)-s3h)*2*!pi/z  
;    endif else begin
;      fta=f(0:s1h,0:s2h)
;      ix=findgen(s1h+1)*2*!pi/x
;      iy=(findgen(s2h+1))*2*!pi/y
;    endelse
;  endif else begin
;    fta=shift(f,s1h,s2h)
;    ix=(findgen(s1)-s1h)*2*!pi/x  
;    iy=(findgen(s2)-s2h)*2*!pi/y
;  endelse
;endif
endif
return
end
