
device, decomposed = 0

MaxColor = !D.Table_Size

LoadCT, 0, NColors = MaxColor -1 

TvLCT, r0, g0, b0, /get

for i = 0, MaxColor-1 do begin
   r1[i] = r0[MaxColor - 1 -i] 
   g1[i] = g0[MaxColor - 1 -i] 
   b1[i] = b0[MaxColor - 1 -i]  
end

TvLCT, r1, g1, b1

xloadct

end