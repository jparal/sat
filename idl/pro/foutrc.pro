; fourier transformation of 2d complex array a as Re(fft a)
; with X =xmax and Y=ymax, output fta coordinates ix,iy 
pro foutrc,an,bn,x,y,fta,ftb,ix,iy,upper=upper,full=full
if not(keyword_set(upper)) then upper=0
if not(keyword_set(full)) then full=0
s=size(aN)
I=complex(0.,1.)
if(s(0) eq 2) then begin
  s1=s(1)
  s2=s(2)
  a=pfft(AN,1,/tra)
  b=pfft(BN,1,/tra)
  c=a+I*b
  fta=abs(Pfft(c,1))
  c=a-i*b
  ftb=abs(Pfft(c,1))
  s1h=s1/2
  s2h=s2/2
  if(full eq 0) then begin
    if(upper eq 0) then begin
      fta=shift(fta(0:s1h,*),0,s2h)
      ftb=shift(ftb(0:s1h,*),0,s2h)
      ix=findgen(s1h+1)*2*!pi/x
      iy=(findgen(s2)-s2h)*2*!pi/y
    endif else begin
      fta=fta(0:s1h,0:s2h)
      ftb=ftb(0:s1h,0:s2h)
      ix=findgen(s1h+1)*2*!pi/x
      iy=(findgen(s2h+1))*2*!pi/y
    endelse
  endif else begin
    fta=shift(fTa,s1h,s2h)
    ftb=shift(ftb,s1h,s2h)
    ix=(findgen(s1)-s1h)*2*!pi/x  
    iy=(findgen(s2)-s2h)*2*!pi/y
  endelse
endif
return
end
