pro listfonts

 print, "---------------------------"
 print, " Available True-Type Fonts " 
 print, "---------------------------"
 Device, Font = '*', Get_Fontnames = fontnames, /TT_Font
 for j=0, N_Elements(fontnames)-1 do begin
       !P.Font = 1
       device, set_font=fontnames[j], /TT_Font
       
       cap = ', none'
       if (!D.Flags and 4096) NE 0 then cap = ',  Accepts embedded formating'
       print, fontnames[j],cap
 end
 print, "--------------------------"
 print, " Available Hardware Fonts " 
 print, "--------------------------"
 Device, Font = '*', Get_Fontnames = fontnames
 for j=0, N_Elements(fontnames)-1 do begin
       !P.Font = 0
       device, set_font=fontnames[j]
       
       cap = ', none'
       if (!D.Flags and 4096) NE 0 then cap = ',  Accepts embedded formating'
       print, fontnames[j],cap
          
 end
 
end