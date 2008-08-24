 FUNCTION get_devices
;+
; NAME:
;	GET_DEVICES
;
;
; PURPOSE:
;	Get all available devices and return them in a string array
;
;
; CATEGORY:
;	Utilities
;
;
; CALLING SEQUENCE:
;	devices = get_devices()
;
; OUTPUTS:
;	Returnes a string array. 
;	If there was no device found or not an applicable os_family 
;	[''] is returned.
;
;
; RESTRICTIONS:
;	Only for Windows, OpenVMS and unix machines
;	vms:	Result of 'show device d' is interpreted
;	unix:	Result of 'df -P' is interpreted
;	Windows:External routine DIREXIST used, written from PMW,
;		found in news
;
;
; MODIFICATION HISTORY:
;
;       Wed Jul 16 11:35:35 1997, Karsten Rodenacker
;       <iliad@janus.gsf.de>
;
;-

 CASE !version.os_family OF
  'vms':BEGIN
     spawn,"show device d",t
     st=size(t)
     d1=[strtrim(strmid(t(3),0,14))]
     FOR i=4,st(1)-1 DO BEGIN
       xxx=strtrim(strmid(t(i),0,14))
       IF strlen(xxx) NE 0 THEN d1=[d1,xxx]
     ENDFOR
    END

  'unix':BEGIN
      spawn, 'df -P', t
      FOR i= 0, n_elements(t) - 1 DO BEGIN 
         percent =  strpos(t[i],'%')
         IF percent NE -1 THEN BEGIN
            IF n_elements(d1) EQ 0 THEN $
             d1 =  [strmid(t[i],strpos(t[i],'/',percent),50)] $
            ELSE d1 = [d1,strmid(t[i],strpos(t[i],'/',percent),50)]
         ENDIF        
      ENDFOR
    END

  'Windows': BEGIN
     d='A:'
     FOR i=66,90 DO d=[d, string(byte(i))+':']
     e=direxist(d)
     first=1
     FOR i=0, 25 DO IF e[i] THEN IF n_elements(d1) EQ 0 THEN d1=d[i] $
     ELSE d1=[d1, d[i]]
    END

  ELSE:BEGIN
    END
  ENDCASE
  IF n_elements(d1) EQ 0 THEN return, [''] ELSE return,d1
 END
