pro test_fonts, FONTNUMBER = fontnumber, TRUETYPE = truetype

if (Keyword_Set(truetype)) then Font = 1$
else Font = -1

if (N_Elements(fontnumber) eq 0) then fontnumber = 9
if (fontnumber lt 3) or (fontnumber gt 20) then begin
  print, 'Test_Fonts, invalid font number'
  return
end


SampleText = StrArr(8)

SampleText[0] = '!!@#$%^&*()_+'
SampleText[1] = '1234567890-='
SampleText[2] = 'QWERTYUIOP{}|'
SampleText[3] = 'qwertyuiop[]\'
SampleText[4] = 'ASDFGHJKL:"'
SampleText[5] = "asdfghjkl;'"
SampleText[6] = 'ZXCVBNM<>?'
SampleText[7] = 'zxcvbnm,./'

if (fontnumber lt 10) then fontnumber = String(FORMAT='(I1)',fontnumber) $
else fontnumber = String(FORMAT='(I2)',fontnumber)

SampleText[0] = '!'+fontnumber+SampleText[0]
SampleText[7] = SampleText[7]+'!X'

erase

for i= 0, 7 do begin
   print, SampleText[i]
   XYOutS, 0.5,1.0-0.1*(1+i), /Normal, SampleText[i], Alignment = 0.5, $
           Charsize = 4, FONT = font
end

end