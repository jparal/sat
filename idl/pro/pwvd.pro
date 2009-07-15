pro pwvd, x, res,l=l
ss=size(x)
n=ss(1)

if(not(keyword_set(l)))then l=n/2
res=complexarr(n,2*l+1)
for i=0,n-1 do begin
for k=-l,l do begin
  res(i,l+k)=0.
  for ii=-l,l do begin
    if((i+ii lt n) and (i-ii ge 0) and (i-ii lt n) and (i+ii ge 0) )then $
            res(i,l+k)=res(i,l+k)+x(i+ii)*conj(x(i-ii))*$
             exp(-complex(0.,1.)*4*!pi*float(k*ii)/float(n))
  endfor
endfor
endfor  
return
end
