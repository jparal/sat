FUNCTION Exponent, axis, index, number

  IF number EQ 0 THEN RETURN, '0' ;; Special case

  ex = String(number, Format='(e8.0)') ; Assuming multiples of 10 with format.
  pt = StrPos(ex, '.')

  first = StrMid(ex, 0, pt)
  sign = StrMid(ex, pt+2, 1)
  thisExponent = StrMid(ex, pt+3)

  ;; Shave off leading zero in exponent

  WHILE StrMid(thisExponent, 0, 1) EQ '0' DO thisExponent = StrMid(thisExponent, 1)

  ;; Fix for sign and missing zero problem.
  IF (Long(thisExponent) EQ 0) THEN BEGIN
      sign = ''
      thisExponent = '0'
  ENDIF

  if (strcompress(first,/remo) eq '1')then begin
  IF sign EQ '-' THEN   RETURN, '10!A' + sign + thisExponent $
     ELSE               RETURN, '10!A' + thisExponent
  endif else begin
    IF sign EQ '-' THEN   RETURN, first + 'x10!A' + sign + thisExponent $
     ELSE               RETURN, first + 'x10!A' + thisExponent

  endelse

END
