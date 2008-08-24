pro test_envelope

; 3D testing

Osiris_Open_Data, pData, ForceDims = 3, /dx

if (pData ne ptr_new()) then begin

  envelope, pData, /time , /mirror, filter = 0.5

  Plot3D, pData, /noproj

   ptr_free, pData
end

end