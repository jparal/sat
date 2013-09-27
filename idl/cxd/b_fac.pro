; Prepare output file
	OpenW, lun, 'idlcxd.txt', /GET_LUN, /APPEND
	PrintF, lun, 'Running Complex Demodulation on ', data_file
	PrintF, lun, FORMAT='("Start time ", (I2.2), ":", (I2.2)," UT  Duration: ", I6)', hour, min, nmins

	time=Findgen(Ndata)
	time=time/(60/T)
	data_time=time 		;Save for plotting later

	; Prepare data for FFT
	hdata=hdata-mean(hdata)
	ddata=ddata-mean(ddata)
	print, 'Enter high-pass filter cut-off (seconds) '
	read, hicut
	print, 'Enter low-pass filter cut-off (seconds) '
	read, lowcut 
	hdata=sam_filter(hdata, lowcut, hicut, T )
	ddata=sam_filter(ddata, lowcut, hicut, T )
	lendat=Ndata/2
	lentap=lendat*9/10.
	taper=costap_func(lentap, lendat, 2)
	hdata=hdata*taper
	ddata=ddata*taper

	;Plot data window
	Window,0,RETAIN=2
	fsd_h=max(hdata)
	fsd_d=max(ddata)
	fsd=max([fsd_h, fsd_d])
	
	plot, time, hdata, Yrange=[(-1.*fsd), fsd], /NODATA
	oplot, time, hdata, color=col_h
	oplot, time, ddata, color=col_d
	
	; Get power spectrum and choice of filter
	; Need to copy because sam_power overwrites the original! 
	
	filt_comp=''
	print, 'Choose component for filter design (H or D):'
	read, filt_comp
	

	CASE filt_comp OF
		
		'H': pow_data=hdata
		
		'D': pow_data=ddata
		
		ELSE: pow_data=hdata
	ENDCASE
	 
		       
	power_arr=sam_power(pow_data, T)
	
	power = power_arr(*,0)
	freq  = power_arr(*,1)
	period= power_arr(*,2)
LOOP:
	window,1,RETAIN=2
	plot, freq, power, Xrange=[0,0.01]
plot, freq, power
	print, 'Choose region for expanded plot'
	cursor, x1, y1, /DOWN
	cursor, x2, y2, /DOWN
	plot, freq, power, Xrange=[x1,x2]

	print,' Choose central frequency with mouse:'
	cursor, x3, y3, /DOWN
	
	f0=FIX(x3*Ndata*T) + 1
	print, 'Choose central frequency:'
	FOR fi = f0-3, f0+3 DO BEGIN
		fmid=freq(fi)
		tmid=1./fmid
		print, '	frequency ',fi, ' : Tmid = ', tmid, ' : Power = ', power(fi)
	ENDFOR
	read, f0
	tmid=1./freq(f0)
	
	; Locate 3dB points
	f_low=f0-1
	f_high=f0+1
	halfpow=power(f0)/2.0
	while (power(f_low)  GT halfpow )  DO f_low = f_low  - 1
	while (power(f_high) GT halfpow )  DO f_high= f_high + 1
	if (f0 - f_low) ge (f_high - f0) THEN fw=f0-f_low ELSE fw=f_high-f0

	print, ' 3dB points are at ', f_low, f_high
	print, ' Filter half-width = ' , fw

	if ((f0-fw) LT 0) OR ((f0+fw) GT Ndata/2) THEN BEGIN
		print, ' INVALID PEAK SELECTION - please try again'
		GOTO, LOOP
	ENDIF 

	plot, freq, power, Xrange=[x1,x2]
	filt = power[f0-fw:f0+fw]
	freq2= freq[f0-fw:f0+fw]
	oplot, freq2, filt, color=green
			  

	dist1 = f0-fw
	dist2 = (Ndata/2) - 1 - (f0+fw)
	maxw = min(dist1, dist2)	; maximum width of taper
	print, ' Max Taper width = ', maxw

; The total filter width is Nf=(2*FFW + 1) points. When transformed to the time domain it
; must be of length (Ndata - 1)*T (i.e. the same length as the original time series).
; 
;	=>	Length = [ (2FFW + 1) - 1] * DDT
;
;		DDT = Length/(2*FFW)
;
;		DDT = [(Ndata - 1)*T]/(2*FFW)
;

; Find the total filter width which gives ddt >= tmid

	for i=1, maxw do begin
		ffw1=fw+i
		ddt1=((Ndata-1)*T)/(2.0*ffw1)
		print, 'ddt = ', ddt1, ' ffw= ', ffw1
		if ddt1 ge tmid THEN ddt=ddt1 
		if ddt1 ge tmid THEN ffw=ffw1
	endfor
		
	print, ' Choose Option:'
	print, '		(1) Phase Analysis'
	print, '		(2) Auto Filter Design'
	print, '		(3) Manual Filter design'
	read, option

	CASE option OF

		1 :	BEGIN ; narrow band cosine taper
			taper = costap_func(fw, ffw, 0) 	
			END

		2 :	BEGIN ; boxcar + cosine taper
			taper = costap_func(fw, ffw, 1) 	
			END

		ELSE:	BEGIN ; manual filter design
			cont='y'
			WHILE cont NE 'n' DO BEGIN
			  print, ' Enter filter width ,taper width'
			  read, fw, tw
			  ffw=fw+tw
			  taper=costap_func(fw, ffw, 1)
			  ;taper=costap(fw, ffw, 0)
			  sig=taper*power[f0-ffw:f0+ffw]
			  freq2=freq[f0-ffw:f0+ffw]
			  plot, freq, power, Xrange=[x1,x2]
			  oplot, freq2, sig, color=green
			  ddt=((Ndata-1)*T)/(2.0*ffw)
			  print, 'ddt= ', ddt			  
			  print,' Choose another filter (y/n) ?'
			  read, cont
			 
			ENDWHILE
			END
	ENDCASE

	print, ' Final ddt is ', ddt	
	print, ' Final ffw is ', ffw
	print, ' Final tmid is ', tmid

	Hspectrum=fft(hdata, -1)	; Forward FFT of data series
	Dspectrum=fft(ddata, -1)
	
	phcol=[dk_green, green, white, red, purple]
	
	if option EQ 1 THEN BEGIN ; phase analysis on f0 +/- 2 adjacent frequencies
		window, 0,RETAIN=2
		f1 = f0-2
		f2 = f0-1
		f3 = f0
		f4 = f0+1
		f5 = f0+2
		FOR fn=f1,f5 DO BEGIN
		  Hspec=Hspectrum[(fn-ffw):(fn+ffw)]
		  Hdemods=cxdemod(Hspec, taper, ffw, lun)
  		phase = atan(imaginary(Hdemods), real_part(Hdemods))		 
 ;phase = atan(Hdemods)
		  phase = phase/!DTOR
		  ;phase = smooth3(phase)
		  time=findgen(2*ffw+1) * ddt/60.0
		  if fn EQ f1 THEN plot, time, phase, title='Phase', /nodata
		  oplot, time, phase, color=phcol(fn-f1)
		  xyouts, 60, 15*(fn-f0), period(fn), color=phcol(fn-f1)
		  
		ENDFOR
	STOP

	ENDIF

	Hspec=Hspectrum[(f0-ffw):(f0+ffw)]  
	Dspec=Dspectrum[(f0-ffw):(f0+ffw)]  
	
	print, 'Filter periods:', (Ndata*T)/(f0-ffw), (Ndata*T)/(f0-fw), $
				  (Ndata*T)/(f0+fw),  (Ndata*T)/(f0+ffw)
	


	; Now do the complex demodulation with chosen filter
	
	Hdemods=cxdemod(Hspec, taper, ffw, lun) 
	Ddemods=cxdemod(Dspec, taper, ffw, lun) 


	; Extract the amplitude, phase and polarisation parameters
	
	Hamp = 2.0 * abs(Hdemods)
;	Hamp = smooth3(Hamp)
	Damp = 2.0 * abs(Ddemods)
;	Damp = smooth3(Damp)
	
	Hphase = atan(imaginary(Hdemods), real_part(Hdemods))
	;Hphase = atan(Hdemods)
	Hphase = Hphase/!DTOR
;	Hphase = smooth3(Hphase)
	;Dphase = atan(Ddemods)
	Dphase = atan(imaginary(Ddemods), real_part(Ddemods))
	Dphase = Dphase/!DTOR
;	Dphase = smooth3(Dphase)

	pol_params = pol_par(Hamp, Damp, Hphase*!DTOR, Dphase*!DTOR)
	ellip = pol_params(*,0)
	pol_angle= pol_params(*,1)
;	ellip = smooth3(ellip)
	
	time=findgen(N_ELEMENTS(Hdemods)) * ddt/60
;	help, time
	printf, lun, $
	FORMAT='("CXD Parameters: Tmid = ", (F6.1), ", DDT = ", (F6.1), ", FW = ", I3, ", FFW = ", I3)',$ 
		tmid, ddt, fw, ffw

	FOR i=0, N_ELEMENTS(Hdemods)-1 DO PrintF, lun, $
		FORMAT='(i3, 7(f8.2))', $
	 i, time[i], Hamp[i], Hphase[i], Damp[i], Dphase[i], ellip[i],pol_angle[i]
