FUNCTION MTH_LINEARWGT, val, min, max, $
  WEIGHT=weight, OUTMIN=outmin, OUTMAX=outmax

  IF (N_ELEMENTS(outmin) EQ 0) THEN outmin=0.
  IF (N_ELEMENTS(outmax) EQ 0) THEN outmax=1.

  ss=size(val)
  IF (ss(0) EQ 0) THEN BEGIN
     a = 1. / (max - min)
     b = -a * min
     RETURN, (outmax-outmin)*(val*a + b) + outmin
  ENDIF

  utl_check_size, min, max, ss=ss(0:1)

  IF (N_ELEMENTS(weight) EQ 0) THEN BEGIN
     weight=val
     weight(*) = 1./ss(1)
  ENDIF

  tmp = 0.
  FOR i=0,ss(1)-1 DO BEGIN
     a = 1. / (max[i] - min[i])
     b = -a * min[i]
     tmp = tmp + weight[i] * (a*val[i] + b)
  ENDFOR

  RETURN, (outmax-outmin)*tmp + outmin

END
