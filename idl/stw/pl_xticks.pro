FUNCTION pl_xticks, axis, index, value
  if (fix(abs(value)) lt abs(value)) then begin
    return, string ("")
  endif else begin
    return, string (-value, format='(I3,"")')
  endelse
END
