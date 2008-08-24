; find a mean over  second index (dim(a)=2) 
;     or second and third indices (dim(a)=3)
     pro d1, aa, b,transpose=transpose
a=aa
if keyword_set(transpose) then a=transpose(a)   
     k= size(a)
 if (k(0) eq 3)then begin
     ni=1./(k(2)*k(3))
     b=fltarr(k(1),/nozero)
     for i=0, k(1)-1 do begin
      b(i)=0
      for j=0,k(2)-1 do begin
       for l=0,k(3)-1 do begin
        b(i)=b(i)+a(i,j,l)
       endfor
      endfor
      b(i)=b(i)*ni
     endfor
endif
 if (k(0) eq 2)then begin
     ni=1./(k(2))
     b=fltarr(k(1),/nozero)
     for i=0, k(1)-1 do begin
      b(i)=0
      for j=0,k(2)-1 do begin
        b(i)=b(i)+a(i,j)
      endfor
      b(i)=b(i)*ni
     endfor
endif
     return
    end
