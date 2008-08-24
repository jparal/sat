pro shdisp,name
rd1,'Omega'+name,om,/dou,/co
rd1,'Kvect'+name,k
plot,k,float(om)
return
end
