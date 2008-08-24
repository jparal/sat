pro rdisp,name,om,k,theta, dim=dim
if not(keyword_set(dim))then dim=1
if (dim eq 1) then begin
rd1,'Omega'+name,om,/dou,/co
rd1,'Kvect'+name,k
endif
if (dim eq 2) then begin  
rd2,'Omega'+name,om,/dou,/co
rd1,'Kvect'+name,k
rd1,'Theta'+name,theta    
endif  
return
end
