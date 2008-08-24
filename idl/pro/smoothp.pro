; smooths an array b(0:n-1) which is periodic
; i.e. b(0)=b(n-1) by smooth(b,sm)
function smoothp,b,sm
s=size(b)
if(s(0) eq 1) then begin
s1=s(1)
g=fltarr(s1+2*sm)
g(sm:(s1+sm-1))=b
;left
g(0:sm-1)=b(s1-sm:s1-1)
;right
g(s1+sm:s1+2*sm-1)=b(0:sm-1)
g=smooth(g,sm)
a=g(sm:(s1+sm-1))
endif 
if(s(0) eq 2) then begin
s1=s(1)
s2=s(2)
g=fltarr(s1+2*sm,s2+2*sm)
g(sm:(s1+sm-1),sm:(s2+sm-1))=b
;first index
g(0:(sm-1),sm:s2+sm-1)=b((s1-sm):(s1-1),*)
g((s1+sm):(s1+2*sm-1),sm:s2+sm-1)=b(0:sm-1,*)
; second index
g(sm:s1+sm-1,0:sm-1)=b(*,(s2-sm):(s2-1))
g(sm:s1+sm-1,(s2+sm):(s2+2*sm-1))=b(*,0:sm-1)
; four corners
g(0:sm-1,0:sm-1)=b((s1-sm):(s1-1),(s2-sm):(s2-1))
g((s1+sm):(s1+2*sm-1),(s2+sm):(s2+2*sm-1))=b(0:sm-1,0:sm-1)
g(0:sm-1,(s2+sm):(s2+2*sm-1))=b((s1-sm):(s1-1),0:sm-1)
g((s1+sm):(s1+2*sm-1),0:sm-1)=b(0:sm-1,(s2-sm):(s2-1))
;
g=smooth(g,sm)
a=g(sm:(s1+sm-1),sm:(s2+sm-1))
endif
if(s(0) eq 3) then begin
;wrong!
s1=s(1)
s2=s(2)
s3=s(3)
g=fltarr(s1+2,s2+2,s3+2)
g(sm:(s1+sm-1),sm:(s2+sm-1),sm:(s3+sm-1))=b
;first index
g(0:(sm-1),*,*)=b((s1-sm):(s1-1),*,*)
g((s1+sm):(s1+2*sm-1),*,*)=b(0:sm-1,*,*)
; second index
g(*,0:sm-1,*)=b(*,(s2-sm):(s2-1),*)
g(*,(s2+sm):(s2+2*sm-1),*)=b(*,0:sm-1,*)
; third index
g(*,*,0:sm-1)=b(*,*,(s3-sm):(s3-1))
g(*,*,(s3+sm):(s3+2*sm-1))=b(*,*,0:sm-1)
; eight corners
g(0:sm-1,0:sm-1,0:sm-1)=b((s1-sm):(s1-1),(s2-sm):(s2-1),(s3-sm):(s3-1))
g((s1+sm):(s1+2*sm-1),(s2+sm):(s2+2*sm-1),0:sm-1)= $
    b(0:sm-1,0:sm-1,(s3-sm):(s3-1))
g(0:sm-1,(s2+sm):(s2+2*sm-1),0:sm-1)=b((s1-sm):(s1-1),0:sm-1,(s3-sm):(s3-1))
g((s1+sm):(s1+2*sm-1),0:sm-1,0:sm-1)=b(0:sm-1,(s2-sm):(s2-1),(s3-sm):(s3-1))
;
g(0:sm-1,0:sm-1,(s3+sm):(s3+2*sm-1))=b((s1-sm):(s1-1),(s2-sm):(s2-1),0:sm-1)
g((s1+sm):(s1+2*sm-1),(s2+sm):(s2+2*sm-1),(s3+sm):(s3+2*sm-1))= $
 b(0:sm-1,0:sm-1,0:sm-1)
g(0:sm-1,(s2+sm):(s2+2*sm-1),(s3+sm):(s3+2*sm-1))= $
 b((s1-sm):(s1-1),0:sm-1,0:sm-1)
g((s1+sm):(s1+2*sm-1),0:sm-1,(s3+sm):(s3+2*sm-1))= $
 b(0:sm-1,(s2-sm):(s2-1),0:sm-1)
g=smooth(g,sm)
a=g(sm:(s1+sm-1),sm:(s2+sm-1),sm:(s3+sm-1))
endif
return,a
end
