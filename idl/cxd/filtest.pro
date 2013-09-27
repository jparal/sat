	pro filtest
	
	a=lanczos(60,1/20.)
	a=a/2400.
	
	res=findgen(200)
	x=res
	for i=0,199 do begin
	  r=76.833+i/32000.
	  df=digital_filter(0.,1/20.,r,60)
	  res(i)=(moment(abs(a-df)))(0)
	  oplot,abs(a-df)
	  x(i)=r
	endfor
	plot,x,res,/ynozero
	
	end
;	76.8345... appears to give the best fit!!
;	Error is of the order of 1x10e-5
