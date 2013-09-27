;----------------------------------------------------------------------------------
;
; IDLCXD.PRO v1.0
;
; Perform complex demodulation on time series data
; 
; Options for phase analysis or cxd with automated or manual filter design
;
; Output results as postscript plot (idl.ps) and text file (idlcxd.txt)
;
; 
; Author: 		Dave Milling 
; Last modified: 	29 July 2003 
;
;**********************************************************************************

FUNCTION costap_func, FWBOX, FW, Type
	
; Type=0
; return cosine taper window for phase analysis
; FWBOX = half-width of cosine taper
; FW = half width of entire filter (set to zero outside the taper region)
;
; Type=1
; return boxcar function with cosine taper for complex demodulation
; FWBOX = half-width of boxcar function
; FW = half-width of filter (boxcar + cosine taper)
;
; Type=2
; return boxcar function with cosine taper for pre-fft processing of time series
; returns even number of data points
; FWBOX = half-width of boxcar function
; FW = half-width of filter (boxcar + cosine taper)

	FWCOS=FW-FWBOX
	ndata=1 + 2*FW
	taper=fltarr(ndata)

	CASE Type OF

	0: BEGIN
	    taper[0:ndata-1]=0.0
	    for i = FW-FWBOX, FW DO taper[i] = 0.5 * (1.0 + cos(!PI * (i-FW)/FWBOX))
	    taper[FW+1:FW+FWBOX] = reverse( taper[FW-FWBOX:FW-1])	    
	   END
	
	1: BEGIN
	    taper[0:ndata-1]=1.0
	    for i = 0,(FWCOS-1) DO taper[i] = 0.5 * (1.0 + cos(!PI * (i-FWCOS)/FWCOS))
	    taper[FW+FWBOX+1:ndata-1]=reverse(taper[0:FWCOS-1])
	   END

	2: BEGIN
	     ndata=2*FW
	     taper=fltarr(ndata)
	     taper[0:ndata-1]=1.0
	     for i = 0,(FWCOS-1) DO taper[i] = 0.5 * (1.0 + cos(!PI * (i-FWCOS)/FWCOS))
	     taper[FW+FWBOX:ndata-1]=reverse(taper[0:FWCOS-1])
    	   END
	
	ENDCASE
	
	RETURN, taper
	END
	
;**************************************************************************************


FUNCTION smooth3, data

;smooth with hanning filter
	narray=N_ELEMENTS(data)
	smoothed=data
	a=data[0]
	smoothed[0]=a
	for i = 1, narray-2  do begin
	
		b=data[i]
		smoothed[i]=0.25*a + 0.5*b +0.25*data[i+1]
		a=b
	endfor
	smoothed[narray-1]=data[narray-1]

	return, smoothed

END

;************************************************

FUNCTION cxdemod, data, filter, ffw, lun

; apply the filter to the spectrum
	data2=data*filter

; shift the central frequency to zero
	data2=shift(data2,-ffw)
	
; inverse FFT and return the complex demodulates
	demods=fft(data2, 1)

	return, demods
END		

;************************************************

FUNCTION pol_par, Hamp, Damp, Hphase, Dphase

	narr=N_ELEMENTS(Hamp)
	ellip=fltarr(narr)
	pol_angle=fltarr(narr)
	
	for i=0, narr-1 do begin
		
		fnum=2.* Hamp(i) * Damp(i) * Cos(Dphase(i)-Hphase(i))
		pa=atan(fnum, (Hamp(i)^2 - Damp(i)^2))/2.0
		cpa=cos(pa)
		spa=sin(pa)
		cp2=cpa^2
		sp2=spa^2
		csp=cpa*spa
		fac=csp*fnum
		
		Hm = SQRT(Hamp(i)^2 * cp2 + Damp(i)^2 * sp2 + fac)
		Dm = SQRT(Hamp(i)^2 * sp2 + Damp(i)^2 * cp2 - fac)
		
		ellip(i) = Hm/Dm
		
;	Refer polarisation angle to 'North'
		
		if ellip(i) GT 1.0 THEN ellip(i)=1./ellip(i) $
			ELSE pa=pa+!pi/2.
		
		phi=(Hphase(i)/!DTOR) - (Dphase(i)/!DTOR)
;		print, 'phi', i, phi
		if phi GT 180.0 then phi=phi-360.
		if phi LT -180.0 then phi=phi+360.
		
		; The sign convention here is that -ve ellipticity
		; corresponds to Anticlockwise polarisation - this is
		; the physical polarisation looking along the field line.
		; Note that this is the opposite of the original
		; York group cxd program (unicxd).
		
		if phi LT 0.0 THEN ellip(i)= -1.0 * ellip(i)
			
		pa=pa/!DTOR
		if pa GT 90.0  then pa=pa - 180.0
		if pa LT -90.0 then pa=pa + 180.0
		pol_angle(i)=pa
		
	ENDFOR
		return_data=fltarr(narr,2)
		return_data(*,0)=ellip
		return_data(*,1)=pol_angle
		return, return_data
END

;*************************************************

FUNCTION make_blank_labels,axis,index,value
        return,''
        end
	
;*************************************************
PRO mvalueidlcxd

	; Set up colours
	Loadct,12
	red=112
	dk_green=16
	green=32
	blue=96
	red=192
	purple=128
	white=255
	col_h = red
	col_d = blue


;common dev_variables, stdev_os,dirstr,begstr,os
;common data,Datafile,Timefile,Sint,Points
;stdev_os WIN: 'win' UNIX:'x'
stdev_os = 'x'

;choose array name or instruments name. 
array_names=['CANOPUS','IMAGE','SAMNET','GOES','LANL','INTERMAG']

array_name_index= 5;2;4;2;1;4;1;3  ;*****change 1
array_name=array_names[array_name_index]
array=strlowcase(array_name)
day = '16'     ;*****change 2 
month = '07'   ;*****change 3
year = '2000'  ;*****change 4
event = year+month+day   
print, event
name_file ='mmb20000716d.min';abg20000716d.min';kev2000071600.col'
;name_file='a5000716.chd';brw20000716d.min';a5000716.mgd';zyk';mmb20000716d.min';a5000716.mgd';20000716_1994-084.sopaflux';kil2000071600.col';far20000716.txt';20000716_1989-046.sopaflux';1994-084.sopaflux';a5000716.zyk';kil2000071600.col';naq20000716d.min';a5000716.zyk';kil20000716.txt';20000716_1991-080.sopaflux';far20000716.txt';20000716ESKI.MAG';kev2000071600.col';G8_K0_CGM_SC.txt';20000716_1994-084.sopaflux';cmo20000716d.min';20000716_1989-046.sopaflux';20000716_1994-084.sopaflux';a5000716.zyk';20000716_1994-084.sopaflux';a5000716.zyk';zyk20000716.txt';20000716_1991-080.sopaflux';20000716GILL.MAG';G8_K0_CGM_SC.txt';20000716_1991-080.sopaflux';zyk20000716.txt';20000716ISLL.MAG';kil2000071600.col';G8_K0_CGM_SC.txt';MAG_15835.txt';irt20000716d.min';20000716.txt_1994-084.sopaflux';19900728GILL.MAG';kil1990072800.col';20000716_1994-084.sopaflux';G0_K0_MAG_10198.txt';lyc2000071600.col';20000716GILL.MAG';G8_K0_CGM_SC.txt';20000609_1994-084.sopaflux';20000716DAWS.MAG';kev2000071600.col';20000716_1994-084.sopaflux';bor20000716.txt' ;*****change 5
;name_file2 = 'a5000716.zyk';cmo20000716d.min';'irt20000716d.min';
name_file2 = 'bmt20000716d.min';a5000716.mcq';mgd';phu20000716d.min';lek2000071600.col'
Points =1440;8606;8640; 8065;8606; 1440;86400;6285;86400.;17280;8640;1440;8606;1440;8065;8606;6285;17280;1440; 6285;1440;8606;6285;1440;8469;606 
Points2 = 1440
;****change 6
data_path='~/work/data/sramp/2000/'
data_path2='~/work/data/'+array+'/'+event+'/'
data_file = data_path2+name_file
data_file2 = data_path2+name_file2

;Xstatn = utl_input_210(data_file,Points)  ; h-component 
Xstatn = utl_input_intermag(data_file,Points)

print, data_file
case strupcase(strtrim(array_name,1)) of
 'CANOPUS' :Xstatn=utl_input_canopus(data_file)
 'IMAGE' :Xstatn=utl_input_image(data_file,data_info)
 'SAMNET':Xstatn=utl_input_samnet(data_file) 
 'GOES' :Xstatn=utl_input_goes(data_file,Points)
 'LANL':Xstatn= utl_input_lanl(data_file,Points)
 'INTERMAG' : Xstatn2= utl_input_intermag(data_file2,Points2);210(data_file,Points);intermag(data_file,Points)	
;'INTERMAG' : Xstatn2= utl_input_210(data_file2,Points2)
endcase
;Xstatn2=utl_input_image(data_file2,data_info)

ans=''
print, 'is this data have x, y, z components?(yes = y, no = n)'
Read,ans

if ans EQ 'y' or ans EQ 'Y' then begin 
ttle_str=strarr(3)
!P.Multi = [0,1,3]
set_plot,stdev_os
windw0=0
Window,windw0, Xsize=650,Ysize=680,title='Wave fields'
for jj=0, 2 do $
    begin
Sint = 60

TimeFile = findgen(Points)*SInt
;ttle_str[jj] =' L :'+string(data_info.lval,format='(F7.2)')+$
;       ' SInt:'+strtrim(long(Xstatn.Sint),1)+'sec'+'  '+Xstatn.STal+' '+compxyz[jj]+' '+Xstatn.Date
;plot,Xstatn.TimeFile/60./60.,Xstatn.Datafile[jj,*],XStyle=1,xticks=3,ystyle=1,xtitle ='Time (UT)',$
plot,TimeFile/60./60.,Xstatn2.Datafile[jj,*],XStyle=1,xticks=3,ystyle=1,xtitle ='Time (UT)',$
ytitle='Amplitude (nT)';,title=ttle_str[jj]

end
!P.Multi = 0
Print,'Please enter the data component you wish to view (X-comp=0, Y-comp=1,Z-comp=2): '
Read,ii
case ii of 
0: comp = 'X/H'
1: comp = 'Y/D'
2: comp = 'Z/Z'
endcase

wdelete,windw0
;critical variables
Sint = Xstatn.Sint    ;float - Data sample rate
;DataFile=Xstatn.datafile[ii,*]  ;float array - Magnetic Data
Points=Xstatn.Points          ;long array - total number of data points
	;h=dataFile;[0:*];a.data_vals.h
	;d=dataFile;[1:*];a.data_vals.d

	h=Xstatn.dataFile[ii,*];a.data_vals.h
	d=Xstatn2.dataFile[ii,*];a.data_vals.d
;h = h*2.	
;d = d*4.
endif else begin
ii = 3
Sint = Xstatn.Sint    ;float - Data sample rate
DataFile=Xstatn.Ydatafile[ii,*]  ;float array - Magnetic Data
Points=Xstatn.Points          ;long array - total number of data points
h=dataFile;a.data_vals.h
	d=dataFile/mean(dataFile);a.data_vals.d
endelse
	; Read ascii data from file
	
	print,' Enter start time (hrs, mins): '
	read, hour, min
	print, ' Enter duration (mins):'
	read, nmins

	T = Xstatn.Sint; a.data_params.samp_int	; sampling interval in seconds
	print, 'Sample interval = ', T
	

	; Work out data range to read in
	datum1=LONG(hour*60*60/T + min*60/T)
	datum2=LONG(datum1 + nmins*60/T)-1
	Ndata=datum2-datum1+1
	print, 'Processing ',Ndata,' points with range ',datum1,':',datum2
	

	hdata=h[datum1:datum2]
	ddata=d[datum1:datum2]

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
	hdata=sam_filter(hdata, 0, hicut, T )
	ddata=sam_filter(ddata, 0, hicut, T )
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
	oplot, time, hdata, color=col_h;, linestyle = 2
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
	plot, freq, power ;, Xrange=[0,0.01]
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


SET_PLOT, 'ps'
Device, /color
Device, xsize=15.0, ysize=20.0, yoffset=2.0
!P.Multi=[0,1,6]
	
	fsd_h=max(hdata)
	fsd_d=max(ddata)
	fsd=max(fsd_h, fsd_d)
	
	plot,  data_time, hdata, Ytitle='H signal', /NODATA, $
		xstyle=1, xtickformat='make_blank_labels',ymargin=[1,0]
	oplot, data_time, hdata, color=col_h

	plot,  data_time, ddata, Ytitle='D signal', /NODATA, $
		xstyle=1, xtickformat='make_blank_labels',ymargin=[1,0]
	oplot, data_time, ddata, color=col_d

;	xyouts, 0.9,0.95, 'H', color=col_h, /NORMAL
;	xyouts, 0.95,0.95, 'D', color=col_d, /NORMAL
	
	; extend the cxd parameter time scales to match the data panels.	
;	time=[time, max(data_time)]

	max_H=max(Hamp)
	max_D=max(Damp)
	fsd=max([max_H, max_D])
;	print, 'fsd= ', fsd
	plot, time, Hamp, Ytitle='Amplitude', Yrange=[0,fsd],/NODATA, $
	xstyle=1, ystyle=1, xtickformat='make_blank_labels',ymargin=[1,0]
	oplot, time, Hamp, color=col_h
	oplot, time, Damp, color=col_d
	
	plot, time, Hphase, Ytitle=' Phase', Yrange=[-180.,180.],/NODATA, $
	xstyle=1, ystyle=1, xtickformat='make_blank_labels',ymargin=[1,0]

	oplot, time, Hphase, color=col_h
	oplot, time, Dphase, color=col_d
	
	
	plot, time, ellip, Ytitle='Ellipticity (CW)', Yrange=[-1.0, 1.0], $
	xstyle=1, xtickformat='make_blank_labels',ymargin=[1,0]
	
	plot, time, pol_angle, Ytitle='Polarisation angle (from N)', Yrange=[-90.0, 90.0], $
			       Xtitle='Event time (minutes)', $
	xstyle=1, ystyle=1,ymargin=[4,0]

	line1=STRING(FORMAT='("Complex Demodulation of", (A))', data_file)
	line2=STRING(FORMAT='("Start time ", (I2.2), ":", (I2.2)," UT")', hour, min)
	line3=STRING(FORMAT='("CXD Parameters: Tmid = ", (F6.1), ", DDT = ", (F6.1), ", FW = ", I3, ", FFW = ", I3)',$ 
				tmid, ddt, fw, ffw)
	line4=STRING(FORMAT='("Filter periods: ", 4( F6.1, 2X))', $
				(Ndata*T)/(f0-ffw), (Ndata*T)/(f0-fw), $
				(Ndata*T)/(f0+fw), (Ndata*T)/(f0+ffw))
	  
	text=[line1, line2, line3, line4]
	text_x=[0,0,0,0]
	text_Y=[25000,24000,23000,22000]
	xyouts, text_x, text_y, text, /device
Device, /Close
set_plot, 'X'
!P.Multi=0
	answer='n'
        print, ' Another plot? (Y or N): '
        read, answer
        if answer EQ 'y' THEN GOTO, LOOP
	close, /all
	Free_LUN, lun
	

END
