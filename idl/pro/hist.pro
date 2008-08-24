; histogram h of x with nbin (default 100) samples
; i values of x , with xmin, xmax 
   pro hist, x, i,h, nbin=nbin,xmin=xmin,xmax=xmax
   if keyword_set(nbin)then begin
         bin=nbin
    endif else begin
         bin=100
    endelse
   m=min(x)
   mm=max(x)
   if keyword_set(xmin)then m=xmin
   if keyword_set(xmax)then mm=xmax
   b=(mm-m)/bin
    h=histogram(x,min=m,max=mm,bin=b)
   s=size(h)
   n=s(1)
   i=findgen(n)*b
   i=i+m
   end
