; vector product of a and b
; return a complex value
function vect, a,b
   sa=size(a)
   sb=size(b)
   if(sa(0) eq 1 and sb(0) eq 1) then begin
    c=complexarr(3)
    c(0)= a(1)*b(2)-b(1)*a(2)
    c(1)= a(2)*b(0)-b(2)*a(0)
    c(2)= a(0)*b(1)-b(0)*a(1)
   endif
   if(sa(0) eq 2 and sb(0) eq 1) then begin
     c=complexarr(3,sa(2))
    c(0,*)= a(1,*)*b(2)-b(1)*a(2,*)
    c(1,*)= a(2,*)*b(0)-b(2)*a(0,*)
    c(2,*)= a(0,*)*b(1)-b(0)*a(1,*)
   endif
   if(sa(0) eq 1 and sb(0) eq 2) then begin
    c=complexarr(3,sb(2))
    c(0,*)= a(1)*b(2,*)-b(1,*)*a(2)
    c(1,*)= a(2)*b(0,*)-b(2,*)*a(0)
    c(2,*)= a(0)*b(1,*)-b(0,*)*a(1)
   endif
   if(sa(0) eq 2 and sb(0) eq 2) then begin
     c=complexarr(3,sa(2))
    c(0,*)= a(1,*)*b(2,*)-b(1,*)*a(2,*)
    c(1,*)= a(2,*)*b(0,*)-b(2,*)*a(0,*)
    c(2,*)= a(0,*)*b(1,*)-b(0,*)*a(1,*)
   endif
   return,c
   end
