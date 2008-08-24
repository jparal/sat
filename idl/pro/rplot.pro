pro rplot,x,y, _EXTRA=extra
if (n_params(0)eq 1) then plot, x/x(0)-1,_EXTRA=extra
if (n_params(0)eq 2) then plot, x,y/y(0)-1,_EXTRA=extra
return 
end
