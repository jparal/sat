pro rdpol,name,pol,elc, dim=dim
if not(keyword_set(dim))then dim=1
if (dim eq 1) then begin
   rd1,'Omega'+name,pol
   rd1,'Kvect'+name,elc
endif
if (dim eq 2) then begin  
   rd2,'Omega'+name,pol
   rd2,'Kvect'+name,elc   
endif  
return
end
