; find a parameters for !p.region
; to have two plots side by side
pro toto,x,y
ya=0
x=.2
y=.8
z=.3
toto:
!p.region=[0.,x,1.,1.]
a=randomn(seed,100)
plot,a
!p.region=[0.,0.,1.,y]
a=randomn(seed,100)
plot,a,/noerase
set_plot,'ps'
!p.region=[0.,x,1.,1.]
a=randomn(seed,100)
plot,a
!p.region=[0.,0.,1.,y]
a=randomn(seed,100)
plot,a,/noerase
device,/close
set_plot,'x'
read,' overlay yes=1, no =-1, ok =0',ya
if(ya eq 0)then goto, tete
if(ya eq 1)then begin
x=x+z
y=y-z
z=z/2
endif else begin
x=x-z
y=y+z
z=z/2
endelse
print,x,y
goto, toto
tete:
print,x,y
return
end
