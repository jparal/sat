;+
; NAME:
;    OSIRIS_GEN_ENVELOPE
;
; PURPOSE:
;
;    The purpose of this function is to get the envelope of all the laser data stored
;    in a directory. This routine uses ENVELOPE to generate the envelopes.
;
; AUTHOR:
;
;   Ricardo Fonseca
;   E-mail: zamb@physics.ucla.edu
;
; CATEGORY:
;
;    Osiris Analysis.
;
; CALLING SEQUENCE:
;
;     osiris_gen_envelope
;
; INPUTS:
;
; KEYWORDS:
;
;    DIRNAME: Set this keyword to the name (path) of the directory you want to analyse. If
;       not specified the routine will prompt the user for the directory name. 
;
;    DX: Setting this keyword will cause the filter for file selection to be set to '*.dx', 
;       allowing the routine to work with the old OSIRIS dx format files. The default is to
;       look for HDF format files (extension '*.hdf')
;
;    In addition all ENVELOPE keywords are passed on to the envelope routine. Check ENVELOPE.PRO
;    for details
;    
; OUTPUTS:
;
;    The envelope of each file 'filename' will be saved as 'env_filename'. The output format
;    is HDF
;
; RESTRICTIONS:
;
;    This routine only works with sets of files that are the same type (dx or hdf). If you have
;    both type of files in a directory you need to run this routine twice, one with the /DX 
;    keyword and one without
;
; EXAMPLE:
;
;    To generate the envelope of all the hdf files in 'uclapic10:Desktop Folder:Zamb:misc:' 
;    passing the KMIN and MIRROR keywords to envelope :
;
;    osiris_gen_envelope, DIRNAME = 'uclapic10:Desktop Folder:Zamb:misc:', KMIN = 10, /MIRROR
;
; MODIFICATION HISTORY:
;
;    Written by: Ricardo Fonseca, 19 April 2000.
;    Changed the behaviour of _EXTRA keyword (now works properly), 11 Sep 2000. zamb 
;-
;###########################################################################

pro osiris_gen_envelope, DIRNAME = DirName, _EXTRA = extrakeys, DX = UseDX

  if N_Elements(DirName) eq 0 then begin  
    DirName = Dialog_PickFile(/Directory)
    if (DirName eq '') then return
  end
  
  cd, dirname

  if KeyWord_Set(UseDX) then begin
    filter = '*.dx'
  end else begin
    filter = '*.hdf'
  end

  Files = FindFile(filter, Count = NFiles)
  
  if (NFiles le 0) then print, 'Osiris_Gen_Envelope, no files found '

  for i=0, NFiles -1 do begin
    print, 'Opening file ', Files[i]

    
    Osiris_Open_Data, pData, FILE = Files[i], /IGNORE_DIFF, $
                             PATH = dirname, $
                             XAXIS = XAxisData, YAXIS = YAxisData, ZAXIS = ZAxisData, $
                             TIMEPHYS = time, TIMESTEP = timestep, $
                             DATATITLE = DataName, DATAFORMAT = format, DATALABEL = Label, DATAUNITS = Units, $
                             XNAME = x1name, XFORMAT = x1format, XLABEL = x1label, XUNITS = x1unit, $
                             YNAME = x2name, YFORMAT = x2format, YLABEL = x2label, YUNITS = x2unit, $
                             ZNAME = x3name, ZFORMAT = x3format, ZLABEL = x3label, ZUNITS = x3unit

    envelope, pData,  _EXTRA = extrakeys    
    
    filesave = 'env_'+files[i] 

    s = strlen(filesave)
    ext = strmid(filesave,s-2,2)
    print, 'File extension ', ext
    if ((ext eq 'dx') or (ext eq 'DX')) then begin
      filesave = strmid(filesave,0,s-2) + 'hdf'
    end
    print, 'Saving file ',filesave

    Osiris_Save_Data, pData,  FILE = filesave, $
                             PATH = dirname, $
                             XAXIS = XAxisData, YAXIS = YAxisData, ZAXIS = ZAxisData, $
                             TIMEPHYS = time, TIMESTEP = timestep, $
                             DATATITLE = DataName, DATAFORMAT = format, DATALABEL = Label, DATAUNITS = Units, $
                             XNAME = x1name, XFORMAT = x1format, XLABEL = x1label, XUNITS = x1unit, $
                             YNAME = x2name, YFORMAT = x2format, YLABEL = x2label, YUNITS = x2unit, $
                             ZNAME = x3name, ZFORMAT = x3format, ZLABEL = x3label, ZUNITS = x3unit

    ptr_free, pData

  
  end
  


end
