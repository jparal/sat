function averageb, bx_gsm,by_gsm,bz_gsm,rm, npts ; code from Jonny's program

;-------------------------------------------------------------------------------------------------------------------
;running means
;-------------------------------------------------------------------------------------------------------------------
mean_bx	 = fltarr(npts)
mean_by	 = fltarr(npts)
mean_bz	 = fltarr(npts)
mean_bt	 = fltarr(npts)


FOR i=rm,npts-rm-1 DO BEGIN

	mean_Bx(i)=TOTAL(bx_gsm(i-rm:i+rm))/(2*rm+1)
	mean_By(i)=TOTAL(by_gsm(i-rm:i+rm))/(2*rm+1)
	mean_Bz(i)=TOTAL(bz_gsm(i-rm:i+rm))/(2*rm+1)
	mean_bt(i)=(mean_bx(i)^2+mean_by(i)^2+mean_bz(i)^2)^0.5

ENDFOR

mean_bx(0)=bx_gsm(0)
mean_by(0)=by_gsm(0)
mean_bz(0)=bz_gsm(0)
mean_bt(0)=(mean_bx(0)^2+mean_by(0)^2+mean_bz(0)^2)^0.5

mean_bx(npts-1)=bx_gsm(npts-1)
mean_by(npts-1)=by_gsm(npts-1)
mean_bz(npts-1)=bz_gsm(npts-1)
mean_bt(npts-1)=(mean_bx(npts-1)^2+mean_by(npts-1)^2+mean_bz(npts-1)^2)^0.5

FOR i=1,rm-1 DO BEGIN

	mean_bx(i)=TOTAL(bx_gsm(0:2*i))/(2*i+1)
	mean_by(i)=TOTAL(by_gsm(0:2*i))/(2*i+1)
	mean_bz(i)=TOTAL(bz_gsm(0:2*i))/(2*i+1)
	mean_bt(i)=(mean_bx(i)^2+mean_by(i)^2+mean_bz(i)^2)^0.5

ENDFOR

FOR i=npts-rm,npts-2 DO BEGIN
	m=npts-1-i

	mean_bx(i)=TOTAL(bx_gsm(npts-(2*m)-1:npts-1))/(2*m+1)
	mean_by(i)=TOTAL(by_gsm(npts-(2*m)-1:npts-1))/(2*m+1)
	mean_bz(i)=TOTAL(bz_gsm(npts-(2*m)-1:npts-1))/(2*m+1)
	mean_bt(i)=(mean_bx(i)^2+mean_by(i)^2+mean_bz(i)^2)^0.5
ENDFOR


	result={mean_bx:mean_bx,mean_by:mean_by,mean_bz:mean_bz,mean_bt:mean_bt}


	return,result


end