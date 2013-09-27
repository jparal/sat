;
; Auto Save File For ./spam3.pro
;
;  Mon Jan  8 17:28:36 GMT 1996
;



; CODE MODIFICATIONS MADE ABOVE THIS COMMENT WILL BE LOST.
; DO NOT REMOVE THIS COMMENT: BEGIN HEADER


; $Id: template.pro,v 1.3 1994/07/21 15:27:46 dave Exp $
;
; Copyright (c) 1994, Research Systems, Inc.  All rights reserved.
;	Unauthorized reproduction prohibited.
; (Of course, if you don't work for RSI, remove these lines or
;  modify to suit.)
;+
; NAME:
;	ROUTINE_NAME
;
; PURPOSE:
;	Tell what your routine does here.  I like to start with the words:
;	"This function (or procedure) ..."
;	Try to use the active, present tense.
;
; CATEGORY:
;	Put a category (or categories) here.  For example:
;	Widgets.
;
; CALLING SEQUENCE:
;	Write the calling sequence here. Include only positional parameters
;	(i.e., NO KEYWORDS). For procedures, use the form:
;
;	ROUTINE_NAME, Parameter1, Parameter2, Foobar
;
;	Note that the routine name is ALL CAPS and arguments have Initial
;	Caps.  For functions, use the form:
; 
;	Result = FUNCTION_NAME(Parameter1, Parameter2, Foobar)
;
;	Always use the "Result = " part to begin. This makes it super-obvious
;	to the user that this routine is a function!
;
; INPUTS:
;	Parm1:	Describe the positional input parameters here. Note again
;		that positional parameters are shown with Initial Caps.
;
; OPTIONAL INPUTS:
;	Parm2:	Describe optional inputs here. If you don't have any, just
;		delete this section.
;	
; KEYWORD PARAMETERS:
;	KEY1:	Document keyword parameters like this. Note that the keyword
;		is shown in ALL CAPS!
;
;	KEY2:	Yet another keyword. Try to use the active, present tense
;		when describing your keywords.  For example, if this keyword
;		is just a set or unset flag, say something like:
;		"Set this keyword to use foobar subfloatation. The default
;		 is foobar superfloatation."
;
; OUTPUTS:
;	Describe any outputs here.  For example, "This function returns the
;	foobar superflimpt version of the input array."  This is where you
;	should also document the return value for functions.
;
; OPTIONAL OUTPUTS:
;	Describe optional outputs here.  If the routine doesn't have any, 
;	just delete this section.
;
; COMMON BLOCKS:
;	BLOCK1:	Describe any common blocks here. If there are no COMMON
;		blocks, just delete this entry.
;
; SIDE EFFECTS:
;	Describe "side effects" here.  There aren't any?  Well, just delete
;	this entry.
;
; RESTRICTIONS:
;	Describe any "restrictions" here.  Delete this section if there are
;	no important restrictions.
;
; PROCEDURE:
;	You can describe the foobar superfloatation method being used here.
;	You might not need this section for your routine.
;
; EXAMPLE:
;	Please provide a simple example here. An example from the PICKFILE
;	documentation is shown below.
;
;	Create a PICKFILE widget that lets users select only files with 
;	the extensions 'pro' and 'dat'.  Use the 'Select File to Read' title 
;	and store the name of the selected file in the variable F.  Enter:
;
;		F = PICKFILE(/READ, FILTER = ['pro', 'dat'])
;
; MODIFICATION HISTORY:
; 	Written by:	Your name here, Date.
;	July, 1994	Any additional mods get described here.  Remember to
;			change the stuff above if you add a new keyword or
;			something!
;-



; DO NOT REMOVE THIS COMMENT: END HEADER
; CODE MODIFICATIONS MADE BELOW THIS COMMENT WILL BE LOST.


; CODE MODIFICATIONS MADE ABOVE THIS COMMENT WILL BE LOST.
; DO NOT REMOVE THIS COMMENT: BEGIN PDMENU3




PRO PDMENU3_Event, Event


  CASE Event.Value OF 


  'QUIT': BEGIN
    PRINT, 'QUIT pressed; Exiting'
    EXIT
    END
  'Two.Four': BEGIN
    PRINT, 'Event for Two.Four'
    END
  'Two.Five': BEGIN
    PRINT, 'Event for Two.Five'
    END
  'Two.Six': BEGIN
    PRINT, 'Event for Two.Six'
    END
  'Three': BEGIN
    PRINT, 'Event for Three'
    END
  ENDCASE
END


; DO NOT REMOVE THIS COMMENT: END PDMENU3
; CODE MODIFICATIONS MADE BELOW THIS COMMENT WILL BE LOST.


; CODE MODIFICATIONS MADE ABOVE THIS COMMENT WILL BE LOST.
; DO NOT REMOVE THIS COMMENT: BEGIN MAIN13




PRO MAIN13_Event, Event


  WIDGET_CONTROL,Event.Id,GET_UVALUE=Ev

  CASE Ev OF 

  'DRAW9': BEGIN
      Print, 'Event for DRAW9'
      END
  ; Event for PDMENU3
  'PDMENU3': PDMENU3_Event, Event
  ENDCASE
END


; DO NOT REMOVE THIS COMMENT: END MAIN13
; CODE MODIFICATIONS MADE BELOW THIS COMMENT WILL BE LOST.



PRO spam3, GROUP=Group




fname="no091195.day2"
get_lun,in1

openr,in1,fname
num_points=86400

h=fltarr(num_points) & d=fltarr(num_points) & z=fltarr(num_points)
dummy=fltarr(3)
ht=0.0 & dt=0.0 & zt=0.0

print,"Begun reading data"
for k = 0L, num_points-1 do begin
  readf,in1,dummy
  h(k)=dummy(0) & d(k)=dummy(1) & z(k)=dummy(2)
endfor

print,"Done reading data"

dssec=0 
desec=num_points-1
ssec=-1
while ssec lt dssec or ssec gt desec do $
begin
  print,"Start time (hours,mins,seconds)"
  read,shour,smin,ssec
  ssec=ssec+60*smin+3600*shour
endwhile
esec=desec+1
while esec gt desec or esec lt ssec do $
begin
  print,"Data length (minutes) (",fix((1+desec-ssec)/60.)," mins maximum)"
  read,lmin
  lsec=lmin*60
  esec=ssec+lsec-1
endwhile
print, ssec,lsec,esec
num_points_plot=lsec
h=h(ssec:esec)
d=d(ssec:esec)
z=z(ssec:esec)

hm=(moment(h))(0)
dm=(moment(d))(0)
zm=(moment(z))(0)

t=findgen(num_points_plot)
t=t+ssec

titlestring=fname
close,in1
free_lun,in1





  IF N_ELEMENTS(Group) EQ 0 THEN GROUP=0

  junk   = { CW_PDMENU_S, flags:0, name:'' }


  MAIN13 = WIDGET_BASE(GROUP_LEADER=Group, $
      COLUMN=1, $
      MAP=1, $
      UVALUE='MAIN13')

  BASE2 = WIDGET_BASE(MAIN13, $
      COLUMN=1, $
      MAP=1, $
      UVALUE='BASE2')

  LABEL6 = WIDGET_LABEL( BASE2, $
      UVALUE='LABEL6', $
      VALUE='spam')

  DRAW9 = WIDGET_DRAW( BASE2, $
      BUTTON_EVENTS=1, $
      RETAIN=2, $
      UVALUE='DRAW9', $
      XSIZE=1000, $
      YSIZE=600)


  MenuDesc136 = [ $
      { CW_PDMENU_S,       0, 'QUIT' }, $ ;        0
      { CW_PDMENU_S,       1, 'Two' }, $ ;        1
        { CW_PDMENU_S,       0, 'Four' }, $ ;        2
        { CW_PDMENU_S,       0, 'Five' }, $ ;        3
        { CW_PDMENU_S,       2, 'Six' }, $ ;        4
      { CW_PDMENU_S,       2, 'Three' } $  ;      5

  ]


  PDMENU3 = CW_PDMENU( MAIN13, MenuDesc136, /RETURN_FULL_NAME, $
      UVALUE='PDMENU3')

  WIDGET_CONTROL, MAIN13, /REALIZE

  ; Get drawable window index

  COMMON DRAW9_Comm, DRAW9_Id
  WIDGET_CONTROL, DRAW9, GET_VALUE=DRAW9_Id
  WSET, DRAW9_Id
  
!p.charsize = 2.0

!p.multi = [0,1,3]

jsplot,t,h-hm, title=titlestring
xyouts,num_points_plot/20,1,"H"
jsplot,t,d-dm
xyouts,num_points_plot/20,1,"D"
jsplot,t,z-zm
xyouts,num_points_plot/20,1,"Z"
  
  
  
  XMANAGER, 'MAIN13', MAIN13
END
