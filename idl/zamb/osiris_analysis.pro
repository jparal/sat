
;
;  Program:
;
;  Osiris_Analysis
;
;  Description:
;
;  Opens data output from the osiris code and plots it
;


PRO Osiris_Analysis,_EXTRA=extrakeys, FILE = FileName, DX = UseDX, PATH = filepath

if Keyword_Set(UseDX) then filter = '*.dx' else filter = '*.hdf'

if N_Elements(FileName) eq 0 then begin
  filename=Dialog_Pickfile(FILTER= filter, get_path = filepath)
  if (filename eq '') then return
end

; Get File Info

osiris_open_data, FILE = Filename, PATH = FilePath, DIM = Dims

case Dims of
  1 : Osiris_Analysis_1D, _EXTRA=extrakeys, FILE = Filename, PATH = FilePath, DX = UseDX
  2 : Osiris_Analysis_2D, _EXTRA=extrakeys, FILE = Filename, PATH = FilePath, DX = UseDX
  3 : Osiris_Analysis_3D, _EXTRA=extrakeys, FILE = Filename, PATH = FilePath, DX = UseDX
  else:
endcase


END
