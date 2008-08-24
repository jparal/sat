pro polyline, verts, POLY = poly, THICK = thick, COLOR = color
  if not Arg_Present(verts) then return
    
  s = size(verts)
  help, verts
  print, s
  
  if ((s[0] ne 2) or (s[1] ne 2) or (s[2] le 2)) then begin
    print, 'Polyline, verts must be an array in the form [2,npoints] with npoints greater '
    print, 'than 2'
    return
  end
  
  if N_Elements(Color) eq 0 then color = 0

  npoints = s[2]
  
  if N_Elements(poly) eq 0 then begin
    plots, verts, THICK = thick, COLOR = color, /data
  end else begin
    s = size(poly)
    if (s[0] ne 1) then begin
       print, 'Polyline, POLY must be a 1D array in the form [nv1,v11, v12, ...,v1nv1, nv2, ...]'
       return
    end

    jmax = s[1]-1
    j = 0  
    while (j lt jmax) do begin
      nv = poly[j]
      if (nv le 1) then begin
        j = j+1      
      end else begin
        jverts = verts[*,poly[j+1:j+nv]]
        plots, jverts, THICK = thick, COLOR = color, /data
        j = j + 1 + nv    
      end
    end 
  
  end
  
end
