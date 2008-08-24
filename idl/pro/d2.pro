; find a mean of a (dim(a)=3) over
;  (x + 1)th index 
   pro d2, a, b, x=x
   if(not(keyword_set(x)))then x=1
   k= size(a)
   if (x eq 1) then begin
     ni=1./(k(1))
     b=fltarr(k(2),k(3),/nozero)
     for i=0, k(2)-1 do begin
       for l=0,k(3)-1 do begin
         b(i,l)=total(a(*,i,l))*ni
       endfor
     endfor
   endif
   if (x eq 2) then begin
     ni=1./(k(2))
     b=fltarr(k(1),k(3),/nozero)
     for i=0, k(1)-1 do begin
       for l=0,k(3)-1 do begin
         b(i,l)=total(a(i,*,l))*ni
       endfor
     endfor
   endif
   if (x eq 3) then begin
     ni=1./(k(3))
     b=fltarr(k(1),k(2),/nozero)
     for i=0, k(1)-1 do begin
       for l=0,k(2)-1 do begin
         b(i,l)=total(a(i,l,*))*ni
       endfor
     endfor
   endif
     return
    end
