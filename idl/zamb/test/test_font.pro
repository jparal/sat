pro test_font, fontname

if (N_Elements(fontname) eq 0) then fontname = 'helvetica'

oView = OBJ_NEW('IDLgrView')
oModel = OBJ_NEW('IDLgrModel')
oWindow = OBJ_NEW('IDLgrWindow')


oFont = OBJ_NEW('IDLgrFont', fontname, SIZE = 25.0)

oLabel = OBJ_NEW('IDLgrText', 'The quick brown fox')
oLabel -> SetProperty, FONT = oFont

oModel -> Add, oLabel
oView -> Add, oModel
oWindow -> Draw, oView

end