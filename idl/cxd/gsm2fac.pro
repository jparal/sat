Function gsm2fac,data_file,lnum
;-------------------------------------------------------------------;
; Coordinate trinsformation from GSM to FAC                         ;
;-------------------------------------------------------------------;

Re = 6356.750 ; Earth radius
rm = 20.


   data = readgoes(data_file,lnum)



	day = data.col0
	month = data.col1
	year = data.col2	
	hr = data.col3
	mm = data.col4
	ss = data.col5
	bx_gsm= data.col6
	by_gsm = data.col7
	bz_gsm = data.col8
	pos_bx = data.col9
	pos_by = data.col10
	pos_bz = data.col11
	pos_bx = pos_bx/Re
	pos_by = pos_by/Re
	pos_bz = pos_bz/Re


;------------------------------------------------------------------;
; 2) Average data                                                  ;
;                                                                  ;
;------------------------------------------------------------------;

; ;number of data
npts = n_elements(bx_gsm)

; ;time 
b_time = hr + mm/60.+ss/60./60.
; ;call function for mean B_field
avdata = averageb(bx_gsm,by_gsm,bz_gsm,rm,npts)
	
	mean_bx=avdata.mean_bx
	mean_by=avdata.mean_by
	mean_bz=avdata.mean_bz
	mean_bt=avdata.mean_bt


; ;  /* calculate FAC rotation matrix */
; ;unit vectors in direction of B field B||
	zi=mean_bx/mean_bt
    	zj=mean_by/mean_bt
    	zk=mean_bz/mean_bt
 
   	y1=mean_by*pos_bz-mean_bz*pos_by
  	y2=mean_bz*pos_bx-mean_bx*pos_bz
    	y3=mean_bx*pos_by-mean_by*pos_bx
    	yt=sqrt(y1^2 + y2^2 + y3^2)
; ;eastward unit vectors
    	yi=y1/yt
    	yj=y2/yt
    	yk=y3/yt
; ;radial unit vectors
    	xi=yj*zk - yk*zj
    	xj=yk*zi - yi*zk
    	xk=yi*zj - yj*zi

; ;/* rotate */
    	bx_fac=bx_gsm*xi+by_gsm*xj+bz_gsm*xk
    	by_fac=bx_gsm*yi+by_gsm*yj+bz_gsm*yk
    	bz_fac=bx_gsm*zi+by_gsm*zj+bz_gsm*zk
; ;  /* rotate position data */
    	x_fac=pos_bx*xi+pos_by*xj+pos_bz*xk
    	y_fac=pos_bx*yi+pos_by*yj+pos_bz*yk
    	z_fac=pos_bx*zi+pos_by*zj+pos_bz*zk

	result={Bx_fac:bx_fac,By_fac:by_fac,Bz_fac:bz_fac,bx_gsm:bx_gsm,by_gsm:by_gsm,bz_gsm:bz_gsm, b_time:b_time}
	
	return, result

END