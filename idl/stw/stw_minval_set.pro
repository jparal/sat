;--------------------------------------------------------------------;
;--------------------------------------------------------------------;
pro stw_minval_set, tardata, minval, srcdata=srcdata, replval=replval

  if not(stw_keyword_set(replval)) then replval=minval
  if not(stw_keyword_set(srcdata)) then src=tardata else src=srcdata

  ssrc=size(src)
  if (ssrc(1) eq 0) then return
  star=size(tardata)
  if (star(1) eq 0) then return

  ndx=where(src lt minval, cnt)
  if (cnt gt 0) then tardata (ndx) = replval

return
end
