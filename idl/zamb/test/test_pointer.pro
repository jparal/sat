ap = ptr_valid()

s = size(ap)
  
if (s[0] ne 0) then begin
    for i=0, s[1]-1 do begin
      help, *(ap[i])
    end
end

ptr_free, ptr_valid()

end