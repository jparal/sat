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
; Author:    Dave Milling
; Last modified:    29 July 2003
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
       ;  taper[FW+FWBOX:ndata-1]=reverse(taper[0:FWCOS-1])
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

;   Refer polarisation angle to 'North'

       if ellip(i) GT 1.0 THEN ellip(i)=1./ellip(i) $
         ELSE pa=pa+!pi/2.

       phi=(Hphase(i)/!DTOR) - (Dphase(i)/!DTOR)
;     print, 'phi', i, phi
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
PRO hil_mpacxd

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

    ; Read ascii data from file


; *****image***********
FILE:
;   home=GETENV('HOME')
;   file=dialog_pickfile(PATH=home)


path='/home/ealee/share/imsi/data/lanl/20000716/'
;path = '/home/ealee/work/lanl/data/mev/'

Ndata =1440

file=path+'mpavelocity.txt'


X0=dblarr(Ndata)
X1=dblarr(Ndata)
X2=dblarr(Ndata)
X3=dblarr(Ndata)


XX0=dblarr(Ndata)
XX1=dblarr(Ndata)
XX2=dblarr(Ndata)
XX3=dblarr(Ndata)


time=findgen(Ndata)
c = dblarr(Ndata)



openR, inlun1,file, /GET_LUN, ERROR=err

;loadct, 4


k=0L
j=0L

text = ''
for i=0,2 do begin
;for i=0,116 do begin
	ReadF,inlun1,text
end
text0=''
while not EOF(inlun1) do begin
; ReadF,inlun1,text0,text1,GX,GY,GZ,X,Y,Z,FORMAT='(A10,1X,A12,6F14.4)'
readf, inlun1, text0, hh,mm,ss,x,y,z,format='(A10,1X,1I2,1X,1I2,1X,F6.3,3F14.7)'
  ; readF , inlun1, dum0,text, text2, text3,dum1, dum2, dum3, dum4, dum5, dum6, dum7, dum8, dum9, dum10, dum11, dum12, dum13, dum14, dum15, dum16, dum17, dum18, dum19, dum20

    if x lt 999990 then begin

    time[j] = hh+mm/60. + ss/3600.; dum0
    X1[j] = x
    X2[j] = y;dum2
    X3[j] = z;dum3
   

    j = j +1

    endif else begin
    time[j] = !Values.D_NAN
    X1[j] = !Values.D_NAN
    X2[j] = !Values.D_NAN
    X3[j] = !Values.D_NAN
   
   
    j = j + 1
    endelse
endwhile
close, /all
CONTINUE:

t=10;0
;window,1

N = 360 
step = 60
t1 = 9
t2 = 10
u = findgen(ndata)*step
u = u/3600/6.+0.00253
;print, u
;xx1 = x1
xx1 = INTERPOL(x1, time, u)
xx2 = interpol(x2, time, u)
xx3 = interpol(x3, time, u)




    print,' Enter start time (hrs, mins): '
    read, hour, min
    print, ' Enter duration (mins):'
    read, nmins
;edit
    T = 60; 20; 5 ;a.data_params.samp_int  ; sampling interval in seconds
    print, 'Sample interval = ', T
    ;h=a.data_vals.h
    ;d=a.data_vals.d

    h = XX1
    d = XX2

;print, h, d
    ; Work out data range to read in
    datum1=LONG(hour*60*60/T + min*60/T)
    datum2=LONG(datum1 + nmins*60/T)-1
    Ndata=datum2-datum1+1
    print, 'Processing ',Ndata,' points with range ',datum1,':',datum2


    hdata=h[datum1:datum2]
    ddata=d[datum1:datum2]

    ; Prepare output file
    OpenW, lun, 'longitudewdc.txt', /GET_LUN, /APPEND
    PrintF, lun, 'Running Complex Demodulation on ', file
    PrintF, lun, FORMAT='("Start time ", (I2.2), ":", (I2.2)," UT  Duration: ", I6)', hour, min, nmins

    time=Findgen(Ndata)
    time=time/(60/T)
    data_time=time        ;Save for plotting later

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
    plot, freq, power , Xrange=[0,0.1]

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
       print, '  frequency ',fi, ' : Tmid = ', tmid, ' : Power = ', power(fi)
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
    maxw = min(dist1, dist2)   ; maximum width of taper
    print, ' Max Taper width = ', maxw

; The total filter width is Nf=(2*FFW + 1) points. When transformed to the time domain it
; must be of length (Ndata - 1)*T (i.e. the same length as the original time series).
;
;   =>    Length = [ (2FFW + 1) - 1] * DDT
;
;     DDT = Length/(2*FFW)
;
;     DDT = [(Ndata - 1)*T]/(2*FFW)
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
    print, '     (1) Phase Analysis'
    print, '     (2) Auto Filter Design'
    print, '     (3) Manual Filter design'
    read, option

    CASE option OF

       1 :   BEGIN ; narrow band cosine taper
         taper = costap_func(fw, ffw, 0)
         END

       2 :   BEGIN ; boxcar + cosine taper
         taper = costap_func(fw, ffw, 1)
         END

       ELSE: BEGIN ; manual filter design
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

    Hspectrum=fft(hdata, -1)   ; Forward FFT of data series
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
;   Hamp = smooth3(Hamp)
    Damp = 2.0 * abs(Ddemods)
;   Damp = smooth3(Damp)

    Hphase = atan(imaginary(Hdemods), real_part(Hdemods))
    Hphase = Hphase/!DTOR
;   Hphase = smooth3(Hphase)
    Dphase = atan(imaginary(Ddemods), real_part(Ddemods))
    Dphase = Dphase/!DTOR
;   Dphase = smooth3(Dphase)

    pol_params = pol_par(Hamp, Damp, Hphase*!DTOR, Dphase*!DTOR)
    ellip = pol_params(*,0)
    pol_angle= pol_params(*,1)
;   ellip = smooth3(ellip)

    time=findgen(N_ELEMENTS(Hdemods)) * ddt/60
;   help, time
    printf, lun, $
    FORMAT='("CXD Parameters: Tmid = ", (F6.1), ", DDT = ", (F6.1), ", FW = ", I3, ", FFW = ", I3)',$
       tmid, ddt, fw, ffw

    FOR i=0, N_ELEMENTS(Hdemods)-1 DO PrintF, lun, $
       FORMAT='(i3, 7(f8.2))', $
     i, time[i], Hamp[i], Hphase[i], $
    Damp[i], Dphase[i], ellip[i],pol_angle[i]


SET_PLOT, 'ps'
Device, /color
Device, xsize=15.0, ysize=20.0, yoffset=2.0
!P.Multi=[0,1,6]

    fsd_h=max(hdata)
    fsd_d=max(ddata)
    fsd=max(fsd_h, fsd_d)

    plot,  data_time, hdata, Ytitle='Z signal', /NODATA, $
       xstyle=1, xtickformat='make_blank_labels',ymargin=[1,0]
    oplot, data_time, hdata, color=col_h

    plot,  data_time, ddata, Ytitle='D signal', /NODATA, $
       xstyle=1, xtickformat='make_blank_labels',ymargin=[1,0]
    oplot, data_time, ddata, color=col_d

;   xyouts, 0.9,0.95, 'H', color=col_h, /NORMAL
;   xyouts, 0.95,0.95, 'D', color=col_d, /NORMAL

    ; extend the cxd parameter time scales to match the data panels.
;   time=[time, max(data_time)]

    max_H=max(Hamp)
    max_D=max(Damp)
    fsd=max([max_H, max_D])
;   print, 'fsd= ', fsd
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

    line1=STRING(FORMAT='("Complex Demodulation of", (A))', file)
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
