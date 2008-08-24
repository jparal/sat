; ----------------------------------------------------- GetCTColors ---
; Gets the color table values from the system color table CT into the
; three variables r,g,b
; ---------------------------------------------------------------------

pro GetCTColors, CT, RED = r, GREEN = g, BLUE = b
   on_error, 2
   theColors = Obj_New('IDLgrPalette')
   theColors->LoadCT, abs(ct)
   theColors->GetProperty, Red=r, Green=g, Blue=b
   Obj_Destroy, theColors
   if (ct lt 0) then begin
     r = reverse(temporary(r))
     g = reverse(temporary(g))
     b = reverse(temporary(b))
   end
end
