; dispersion funcion of whistlers
; get out 'aic.ps' 
;.r
a=' '
bb=' '
iunit=9
openr,iunit,'an.dat'
readf,iunit,nn
ant=fltarr(nn)
gamax=ant
readf,iunit,ant,gamax
close,iunit
atc=100
for i=0,nn-1 do begin
if(atc gt abs(gamax(i)-1.067))then begin
atc= abs(gamax(i)-1.067)
inn=i
endif
endfor
kkk:
read,' output to files (y) ',a

!p.charsize=1.5
!p.charthick=2
!p.thick=2
if (a eq 'y') then begin
set_plot,'ps'
device,filename='aic.ps'
endif else begin
set_plot,'x'
endelse
dxp=.03
dyp=0.
!p.region=[0.-dxp,0.-dyp,1./2.+dxp,1.+dyp]
!p.title='!8 '
plot,ant,gamax, xrange=[2.,30.],yrange=[0.,2.],/xst,/yst,$
xtitle='T!Bperp!N / T!Bpar!N', $
ytitle='!N!7c!8!Bmax!N!7 / X!b!8i!n'
oplot,[2.,30.],[1.,1.]*gamax(inn),linestyle=2
oplot,[1.,1.]*ant(inn),[0.,2.],linestyle=2
xyouts,3,1.1,'!N!7c!8!Bcr!N',charsize=2
xyouts,14,0.15,'!NA!8!Bcr!N',charsize=2 
;
!p.region=[1./2.-2*dxp,0.-dyp,1.,1.+dyp]

      xd=25. 
      dti=.1
an=fltarr(13)
sm=an
dis=an
;
      na=0
      an(na)=10.85182
      sm(na)=2.
      dis(na)=11.48620
;
      na=na+1
      an(na)=15.01189
      sm(na)=2.5
      dis(na)=9.600883
;
      na=na+1
      an(na)=12.11965
      sm(na)=3.
      dis(na)=7.857854
;
      na=na+1
      an(na)=10.53487
      sm(na)=3.5
      dis(na)=6.150398
;
      na=na+1
      an(na)=12.31775 
      sm(na)=4.
      dis(na)= 4.514087 
; 
      na=na+1
      an(na)=4.710777
      sm(na)=1.5
      dis(na)=12.69565
;
      na=na+1
      an(na)=6.929477
      sm(na)=1.75
      dis(na)=12.23321
; 
      na=na+1
      an(na)=13.58558
      sm(na)=2.25
      dis(na)=10.49018 
; 
      na=na+1
      an(na)=13.98178
      sm(na)=2.75
      dis(na)=8.747154
;
      na=na+1
      an(na)= 10.77258 
      sm(na)=3.25
      dis(na)= 6.932982 
;
      na=na+1
      an(na)=10.69334
      sm(na)=3.75
      dis(na)=5.261098
; 
      na=na+1
      an(na)=14.25911
      sm(na)=4.25
      dis(na)=16.00206
; 
      na=na+1
      an(na)= 16.12124  
      sm(na)=4.5
      dis(na)=14.98826
;
      for i=0, na do begin
        xdi=xd
        if(sm(i) gt 4.) then xdi=37.5
        sm(i)=sm(i)+ dti*(xdi-dis(i))
      endfor
 

!p.title='!8 '
plot,sm,an, xrange=[2.,8.],yrange=[0.,20.],$
xtitle='!8!N M!BA!N',thick=2,/xst,/yst,psym=2, $
ytitle='!N!8max(T!Bperp!N / T!Bpar!N)', /noerase

;
if (a eq 'y') then begin
device,/close
endif
read,' Finir? ',bb
if (bb ne 'y') then goto, kkk
;
end
;.r