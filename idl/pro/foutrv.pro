; fourier transformation of 2d array a as abs(fft a)
; with X =xmax and Y=ymax, output fta coordinates ix,iy 
pro foutrv,anx,any,anz,x,y,fta,ix,iy,upper=upper,full=full
if(n_params(0) eq 8)then begin
foutr,anx,x,y,ftx,ix,iy,upper=upper,full=full  
foutr,any,x,y,fty,ix,iy,upper=upper,full=full
foutr,anz,x,y,ftz,ix,iy,upper=upper,full=full
fta=sqrt(ftx^2+fty^2+ftz^2) 
endif
if(n_params(0) eq 4)then begin
foutr,anx,ftx,upper=upper,full=full
foutr,any,fty,upper=upper,full=full
foutr,anz,ftz,upper=upper,full=full
x=sqrt(ftx^2+fty^2+ftz^2)
endif
 
return
end
