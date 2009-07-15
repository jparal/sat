;---------------------------------------------------------------------
; !!! THIS FILE IS SHARED BETWEEN v.0.4 AND v.0.5 !!!
;
; !!! If you add some directory here, do not forget to add it also !!!
; !!! to the file "extidl/profix/start.template"                   !!!
;
; PATHS VISIBLE TO IDL ARE DEFINED HERE.
; WE NEED STW'S OWN START.PRO AS STW USES RICHER DIRECTORY TREE
;
; HISTORY:
;
;---------------------------------------------------------------------
 print, '  Using STW IDL package'
 print, '  Credits: Petr Hellinger, Pavel Travnicek'
 !path="/usr/local/stw/idl/pro:/usr/local/stw/idl/pro/textoidl:"+!path
 !path="/usr/local/stw/idl/pro/wavelet:"+$
  "/usr/local/stw/idl/pro/markwardt:"+$
  "/usr/local/stw/idl/pro/zamb:"+$
  "/usr/local/stw/idl/pro/zamb/analysis:"+$
  "/usr/local/stw/idl/pro/zamb/misc:"+$
  "/usr/local/stw/idl/pro/zamb/menus:"+$
  "/usr/local/stw/idl/pro/zamb/plot1d:"+$
  "/usr/local/stw/idl/pro/zamb/plot2d:"+$
  "/usr/local/stw/idl/pro/zamb/plot3d:"+$
  "/usr/local/stw/idl/pro/zamb/InputValues:"+$
  "/usr/local/stw/idl/prostw:"+$
  "/usr/local/stw/idl/stw:"+$
  "/usr/local/stw/idl/stw/dcom:"+"/usr/local/stw/idl/stw/io:"+$
  "/usr/local/stw/idl/stw/devel:"+$
  "/usr/local/stw/idl/stw/dprd:"+"/usr/local/stw/idl/stw/dtr:"+$
  "/usr/local/stw/idl/stw/plt:"+$
  "/usr/local/stw/idl/stw/viscom:"+$
  "/usr/local/stw/idl/stw/vispl:"+$
  "/usr/local/stw/src/idl/simul/herm:"+$
  !path

DEFSYSV, "!STW_HOME", "/usr/local/stw", 1
;WINDOW, /PIXMAP & WDELETE
;DEVICE, BYPASS_TRANSLATION=0
DEVICE,DECOMPOSED=0,RETAIN=2,TRUE_COLOR=24
