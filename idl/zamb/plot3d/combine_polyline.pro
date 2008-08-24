; combines two polylines (vertex + connectivity information) into one

pro combine_polyline, vert1, point1, vert2, point2

if N_Elements(vert1) eq 0 then begin
  if N_Elements(vert2) eq 0 then begin
    return
  end else begin
    vert1 = vert2
    point1 = point2
  end
end

; if the second polyline is empty then there's nothing to combine

if N_Elements(vert2) eq 0 then return

if N_Params() ne 4 then begin
  res = Error_Message('Invalid number of parameters.')
  return
end

s1 = size(vert1, /dimensions)
s2 = size(vert2, /dimensions)

if (s1[0] ne s2[0]) then begin
  res = Error_Message('The two polylines must be of points of the same dimensionality.')
  return
end

; Copy vertices into destination array

vert3 = FltArr(s1[0], s1[1]+s2[1])
vert3[*,0:s1[1]-1] = vert1
vert3[*,s1[1]:*] = vert2
vert1 = temporary(vert3)

; Copy connectivity and correct it

corr = s1[1]
s1 = N_Elements(point1)
s2 = N_Elements(point2)

idx = s1
idx_max = s1+s2
point3 = lonarr(idx_max)
point3[0:s1-1] = point1
point3[s1:*] = point2
point1 = temporary(point3)

while idx lt idx_max do begin
  nv = point1[idx]
  idx = idx + 1
  if (nv gt 0) then begin
    point1[idx:idx+nv-1] = point1[idx:idx+nv-1] + corr
    idx = idx+nv
  end
end

end