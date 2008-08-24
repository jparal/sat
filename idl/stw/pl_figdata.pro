;--------------------------------------------------------------------;
; BASIC PROCEDURE FOR PLOTTING PLANETARY DATA FROM 3D SIMULATIONS    ;
;                                                                    ;
; Developed for analysis of Mercury data simulations.                ;
;                                                                    ;
; HISTORY:                                                           ;
;                                                                    ;
; - 28/08/2006, v.0.4.141: Cloned/extracted from "pl_figani.pro".    ;
;--------------------------------------------------------------------;
pro pl_figdata, $
  data, $
  dataxy=dataxy, dataxz=dataxz, datayz=datayz, $
  dx=dx, dy=dy, dz=dz, $
  xc=xc, yc=yc, zc=zc, $
  radius=radius, $
  minx=minx, maxx=maxx, $
  miny=miny, maxy=maxy, $
  minz=minz, maxz=maxz, $
  mina=mina, maxa=maxa, $
  plotxy=plotxy, plotxz=plotxz, plotyz=plotyz,pamin=pamin

;--------------------------------------------------------------------;
; FIX PARAMETERS NEEDED FOR THE PREPARATION OF DATA                  ;
;--------------------------------------------------------------------;
if not(stw_keyword_set(radius)) then radius=1.0

if not(stw_keyword_set(dx)) then dx=1.0
if not(stw_keyword_set(dy)) then dy=1.0
if not(stw_keyword_set(dz)) then dz=1.0

if not(stw_keyword_set(xc)) then xc=0.5
if not(stw_keyword_set(yc)) then yc=0.5
if not(stw_keyword_set(zc)) then zc=0.5

ss=size(ani)

if (ss(1) eq 3) then begin

  ;-------------------------------------------------------;
  ; This shall be done only once when data was reloaded!  ;
  ;-------------------------------------------------------;
  if (ss(0) gt 2) then begin
    pl_gennul3, ss(1), ss(2), ss(3), dx, dy, dz, xc, radius, ani0
  endif

  mnul, ani0, ani, level=0.01, value=0.0

endif

;--------------------------------------------------------------------;
return
end
