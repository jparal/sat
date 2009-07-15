function amax, a1,a2,a3,a4,a5,a6,a7,a8,a9,a10
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
if(ss(0) eq 2)then begin
  if (n_params(0) eq 2) then begin
    for j=0,ss(2)-1 do begin
       for i=0,ss(1)-1 do begin
         if(a(i,j) lt a2(i,j))then a(i,j)=a2(i,j) 
       endfor
    endfor
  endif
  if (n_params(0) eq 3) then begin
    for j=0,ss(2)-1 do begin
       for i=0,ss(1)-1 do begin
         a(i,j)=max([a1(i,j),a2(i,j),a3(i,j)])
       endfor
    endfor
  endif
  if (n_params(0) eq 4) then begin
    for j=0,ss(2)-1 do begin
      for i=0,ss(1)-1 do begin
        a(i,j)=max([a1(i,j),a2(i,j),a3(i,j),a4(i,j)])
      endfor
    endfor
  endif
  if (n_params(0) eq 5) then begin
    for j=0,ss(2)-1 do begin
      for i=0,ss(1)-1 do begin
        a(i,j)=max([a1(i,j),a2(i,j),a3(i,j),a4(i,j),a5(i,j)])
      endfor
    endfor
  endif
  if (n_params(0) eq 6) then begin
    for j=0,ss(2)-1 do begin
      for i=0,ss(1)-1 do begin
        a(i,j)=max([a1(i,j),a2(i,j),a3(i,j),a4(i,j),$
          a5(i,j),a6(i,j)])
       endfor
     endfor
  endif
  if (n_params(0) eq 7) then begin
    for j=0,ss(2)-1 do begin
       for i=0,ss(1)-1 do begin
         a(i,j)=max([a1(i,j),a2(i,j),a3(i,j),a4(i,j),$
          a5(i,j),a6(i,j),a7(i,j)])
       endfor
     endfor
  endif
  if (n_params(0) eq 8) then begin
    for j=0,ss(2)-1 do begin
      for i=0,ss(1)-1 do begin
        a(i,j)=max([a1(i,j),a2(i,j),a3(i,j),a4(i,j),$
          a5(i,j),a6(i,j),a7(i,j),a8(i,j)])
      endfor
    endfor
  endif
  if (n_params(0) eq 9) then begin
    for j=0,ss(2)-1 do begin
      for i=0,ss(1)-1 do begin
        a(i,j)=max([a1(i,j),a2(i,j),a3(i,j),a4(i,j),$
          a5(i,j),a6(i,j),a7(i,j),a8(i,j),a9(i,j)])
      endfor
    endfor
  endif
  if (n_params(0) eq 10) then begin
    for j=0,ss(2)-1 do begin
      for i=0,ss(1)-1 do begin
         a(i,j)=max([a1(i,j),a2(i,j),a3(i,j),a4(i,j),$
          a5(i,j),a6(i,j),a7(i,j),a8(i,j),a9(i,j),a10(i,j)])
      endfor
    endfor
  endif
endif
if(ss(0) eq 3)then begin
  if (n_params(0) eq 2) then begin
    for k=0,ss(3)-1 do begin
      for j=0,ss(2)-1 do begin
        for i=0,ss(1)-1 do begin
          if(a(i,j,k) lt a2(i,j,k))then a(i,j,k)=a2(i,j,k) 
        endfor
      endfor
    endfor
  endif
  if (n_params(0) eq 3) then begin
    for k=0,ss(3)-1 do begin
      for j=0,ss(2)-1 do begin
        for i=0,ss(1)-1 do begin
          a(i,j,k)=max([a1(i,j,k),a2(i,j,k),a3(i,j,k)])
        endfor
      endfor
    endfor
  endif
  if (n_params(0) eq 4) then begin
    for k=0,ss(3)-1 do begin
      for j=0,ss(2)-1 do begin
        for i=0,ss(1)-1 do begin
          a(i,j,k)=max([a1(i,j,k),a2(i,j,k),a3(i,j,k),a4(i,j,k)])
        endfor
      endfor
    endfor
  endif
  if (n_params(0) eq 5) then begin
    for k=0,ss(3)-1 do begin
      for j=0,ss(2)-1 do begin
        for i=0,ss(1)-1 do begin
          a(i,j,k)=max([a1(i,j,k),a2(i,j,k),a3(i,j,k),$
             a4(i,j,k),a5(i,j,k)])
        endfor
      endfor
    endfor
  endif
  if (n_params(0) eq 6) then begin
    for k=0,ss(3)-1 do begin
      for j=0,ss(2)-1 do begin
        for i=0,ss(1)-1 do begin
          a(i,j,k)=max([a1(i,j,k),a2(i,j,k),a3(i,j,k),a4(i,j,k),$
               a5(i,j,k),a6(i,j,k)])
        endfor
      endfor
    endfor
  endif
  if (n_params(0) eq 7) then begin
    for k=0,ss(3)-1 do begin
      for j=0,ss(2)-1 do begin
        for i=0,ss(1)-1 do begin
          a(i,j,k)=max([a1(i,j,k),a2(i,j,k),a3(i,j,k),a4(i,j,k),$
            a5(i,j,k),a6(i,j,k),a7(i,j,k)])
        endfor
      endfor
    endfor
  endif
  if (n_params(0) eq 8) then begin
    for k=0,ss(3)-1 do begin
      for j=0,ss(2)-1 do begin
        for i=0,ss(1)-1 do begin
          a(i,j,k)=max([a1(i,j,k),a2(i,j,k),a3(i,j,k),a4(i,j,k),$
              a5(i,j,k),a6(i,j,k),a7(i,j,k),a8(i,j,k)])
        endfor
      endfor
    endfor
  endif
  if (n_params(0) eq 9) then begin
    for k=0,ss(3)-1 do begin
      for j=0,ss(2)-1 do begin
        for i=0,ss(1)-1 do begin
          a(i,j,k)=max([a1(i,j,k),a2(i,j,k),a3(i,j,k),a4(i,j,k),$
            a5(i,j,k),a6(i,j,k),a7(i,j,k),a8(i,j,k),a9(i,j,k)])
        endfor
      endfor
    endfor
  endif
  if (n_params(0) eq 10) then begin
    for k=0,ss(3)-1 do begin
      for j=0,ss(2)-1 do begin
        for i=0,ss(1)-1 do begin
          a(i,j,k)=max([a1(i,j,k),a2(i,j,k),a3(i,j,k),a4(i,j,k),$
           a5(i,j,k),a6(i,j,k),a7(i,j,k),a8(i,j,k),a9(i,j,k),a10(i,j,k)])
        endfor
      endfor
    endfor
  endif
endif
return,a
end
