

;-------------------------------------------------------------
;+
; NAME:
;       pro_spher
; PURPOSE:
;       Applies a prolate spheroidal data window. 
; CATEGORY:
; CALLING SEQUENCE:
;       pro_spher(x,n_data,n_terms,dt,df)
; INPUTS:
;	x	data
;	n_data	number of original data points
;	n_terms	total number of data points in this array
;	dt	sample time interval
;	df	1/dt*n_terms
; KEYWORD PARAMETERS:
; OUTPUTS:
;       x	x has a prolate spheroidal data window applied to it
;
;
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Bunting, 9 Jul 1996
;
; Copyright (C) 1996, York University Space Geophysics Group
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro pro_spher,x,n_data,n_terms,dt,df,help=hlp
        
        if keyword_set(hlp) then $
          begin
          print,''
          print,'NAME:'
          print,'      pro_spher'
          print,'PURPOSE:'
          print,'      Applies a prolate spheroidal data window. '
          print,'CATEGORY:'
          print,'CALLING SEQUENCE:'
          print,'      pro_spher(x,n_data,n_terms,dt,df)'
          print,'INPUTS:'
          print,'	x	data'
          print,'	n_data	number of original data points'
          print,'	n_terms	total number of data points in this array'
          print,'	dt	sample time interval'
          print,'	df	1/dt*n_terms'
          print,' KEYWORD PARAMETERS:'
          print,' OUTPUTS:'
          print,'       x	x has a prolate spheroidal data window applied to it'
          print,''
        endif

     ;   if n_elements(lm) eq 0 or lm eq 0 then $
     ;     begin
     ;     print,'lanczos.pro: Wrong length or no length of filter'
     ;     return,0.
     ;   endif
     

	ntrm=20
	h=5.08125548147497D-01
	a=[4.2904633140034110D-05, 1.5672417352380246D-03, $
	1.4476509897632850D-02, 5.9923940532892353D-02, $
	1.4041394473085307D-01, 2.1163435697968192D-01, $
	2.2242525852102708D-01, 1.7233583271499150D-01, $
	1.0252816895203814D-01, 4.8315671140720506D-02, $
	1.8482388295519675D-02, 5.8542015072142441D-03, $
	1.5607376779150113D-03, 3.5507361197109845D-04, $
	6.9746276641509466D-05, 1.1948784162527709D-05, $
	1.8011359410323110D-06, 2.4073904863499725D-07, $
	2.8727486379692354D-08, 3.0793023552299688D-09, $
	2.9812025862125737D-10, 2.6197747176990866D-11, $
	2.0990311910903827D-12, 1.5396841106693918D-13, $
	1.0378004856905766D-14, 6.4468886153746655D-16, $
	3.6732920587994387D-17, 1.6453834571404080D-18, $
	-2.1474104369670976D-19, -2.9032658209519280D-19]

     	nti=abs(n_terms)
     	ndi=min([nti,n_data])
     	dnd=ndi
     	dz=2./dnd
     	zbase=-(1.+dz/2.)
     	nh=(ndi+1)/2
     	ndp=ndi+1
     	fntrf=nti
     	delf=1./(dt*fntrf)
     	crct=sqrt(2./h)
     	for n=1L, nh do $
     	begin
     		dn=n
     		z=zbase+dz*dn
     		q=1-z*z
     		cu=a(0)
     		pr=1D0
     		for j=1L, ntrm do $
     		begin
     			pr=pr*q
     			if j gt 9 and pr lt 1e-8 then goto, OUTLOOP
     			cu=cu+a(j-1)*pr
     		endfor
     		OUTLOOP:
     		cu=cu*crct
     		n1=ndp-n
     		if n_terms lt 0 then begin
     			x(n-1)=cu
     			x(n1-1)=cu
     		endif else begin
     			x(n-1)=x(n-1)*cu
     			if n ne n1 then begin
     				x(n1-1)=x(n1-1)*cu
     			endif
     		endelse
     	endfor
     	
     	end
     	
     	
