function amax2, a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,index=index
if (n_params(0) gt 10 or n_params(0) lt 2)then begin
print,'error n param'
return,0
endif
a=a1
ss=size(a1)
if(ss(0) lt 2 or ss(0) gt 3)then begin
print,'error size'
return,0
endif
index=intarr(ss(1),ss(2))*0+1
if(ss(0) eq 2)then begin
  if (n_params(0) ge 2) then begin
    for j=0,ss(2)-1 do begin
       for i=0,ss(1)-1 do begin
         if(a(i,j) lt a2(i,j))then begin
            a(i,j)=a2(i,j) 
            index(i,j)=2
         endif
       endfor
    endfor
  endif
  if (n_params(0) ge 3) then begin
    for j=0,ss(2)-1 do begin
       for i=0,ss(1)-1 do begin
         if(a(i,j) lt a3(i,j))then begin
            a(i,j)=a3(i,j)
            index(i,j)=3
         endif
       endfor
    endfor
  endif
  if (n_params(0) ge 4) then begin
    for j=0,ss(2)-1 do begin
      for i=0,ss(1)-1 do begin
         if(a(i,j) lt a4(i,j))then begin
            a(i,j)=a4(i,j)
            index(i,j)=4
         endif
      endfor
    endfor
  endif
  if (n_params(0) ge 5) then begin
    for j=0,ss(2)-1 do begin
      for i=0,ss(1)-1 do begin
         if(a(i,j) lt a5(i,j))then begin
            a(i,j)=a5(i,j)
            index(i,j)=5
         endif
      endfor
    endfor
  endif
  if (n_params(0) ge 6) then begin
    for j=0,ss(2)-1 do begin
      for i=0,ss(1)-1 do begin
         if(a(i,j) lt a6(i,j))then begin
            a(i,j)=a6(i,j)
            index(i,j)=6
         endif
       endfor
     endfor
  endif
  if (n_params(0) eq 7) then begin
    for j=0,ss(2)-1 do begin
       for i=0,ss(1)-1 do begin
         if(a(i,j) lt a7(i,j))then begin
            a(i,j)=a7(i,j)
            index(i,j)=7
         endif
       endfor
     endfor
  endif
  if (n_params(0) eq 8) then begin
    for j=0,ss(2)-1 do begin
      for i=0,ss(1)-1 do begin
         if(a(i,j) lt a8(i,j))then begin
            a(i,j)=a8(i,j)
            index(i,j)=8
         endif
      endfor
    endfor
  endif
  if (n_params(0) eq 9) then begin
    for j=0,ss(2)-1 do begin
      for i=0,ss(1)-1 do begin
         if(a(i,j) lt a9(i,j))then begin
            a(i,j)=a9(i,j)
            index(i,j)=9
         endif
      endfor
    endfor
  endif
  if (n_params(0) eq 10) then begin
    for j=0,ss(2)-1 do begin
      for i=0,ss(1)-1 do begin
         if(a(i,j) lt a10(i,j))then begin
            a(i,j)=a10(i,j)
            index(i,j)=10
         endif
      endfor
    endfor
  endif
endif

return,a
end
