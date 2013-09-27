pro plod
fname="no091195.day2"
get_lun,in1

openr,in1,fname
num_points=86400

h=fltarr(num_points) & d=fltarr(num_points) & z=fltarr(num_points)
dummy=fltarr(3)
ht=0.0 & dt=0.0 & zt=0.0

print,"Begun reading data"
for k = 0L, num_points-1 do begin
  readf,in1,dummy
  h(k)=dummy(0) & d(k)=dummy(1) & z(k)=dummy(2)
endfor

print,"Done reading data"

dssec=0 
desec=num_points-1
ssec=-1
while ssec lt dssec or ssec gt desec do $
begin
  print,"Start time (hours,mins,seconds)"
  read,shour,smin,ssec
  ssec=ssec+60*smin+3600*shour
endwhile
esec=desec+1
while esec gt desec or esec lt ssec do $
begin
  print,"Data length (minutes) (",fix((1+desec-ssec)/60.)," mins maximum)"
  read,lmin
  lsec=lmin*60
  esec=ssec+lsec-1
endwhile
print, ssec,lsec,esec
num_points_plot=lsec
h=h(ssec:esec)
d=d(ssec:esec)
z=z(ssec:esec)

hm=(moment(h))(0)
dm=(moment(d))(0)
zm=(moment(z))(0)

t=findgen(num_points_plot)
t=t+ssec

titlestring=fname
!p.charsize = 2.0

!p.multi = [0,1,3]

jsplot,t,h-hm, title=titlestring
xyouts,num_points_plot/20,1,"H"
jsplot,t,d-dm
xyouts,num_points_plot/20,1,"D"
jsplot,t,z-zm
xyouts,num_points_plot/20,1,"Z"
close,in1
free_lun,in1
return
end

