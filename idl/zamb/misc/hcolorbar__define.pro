;+
; NAME:
;       HCOLORBAR
;
; FILENAME:
;       hcolorbar__define.pro
;;
; PURPOSE:
;       The purpose of this program is to create a horizontal
;       colorbar object to be used in conjunction with other
;       IDL 5 graphics objects.
;
; AUTHOR:
;       FANNING SOFTWARE CONSULTING
;       David Fanning, Ph.D.
;       2642 Bradbury Court
;       Fort Collins, CO 80521 USA
;       Phone: 970-221-0438
;       E-mail: davidf@dfanning.com
;       Coyote's Guide to IDL Programming: http://www.dfanning.com/
;
; CATEGORY:
;       IDL 5 Object Graphics.
;
; CALLING SEQUENCE:
;       thisColorBar = Obj_New('HColorBar')
;
; REQUIRED INPUTS:
;       None.
;
; INIT METHOD KEYWORD PARAMETERS:
;
;       COLOR: A three-element array representing the RGB values of a color
;          for the colorbar axes and annotation. The default value is
;          white: [255,255,255].
;
;       NAME: The name associated with this object.
;
;       NCOLORS: The number of colors associated with the colorbar. The
;          default is 256.
;
;       MAJOR: The number of major tick divisions on the colorbar axes.
;          The default is 5.
;
;       MINOR: The number of minor tick marks on the colorbar axes.
;          The default is 4.
;
;       PALETTE: A palette object for the colorbar. The default palette
;           is a gray-scale palette object.
;
;       POSITION: A four-element array specifying the position of the
;           colorbar in normalized coordinate space. The default position
;           is [0.10, 0.90, 0.90, 0.95].
;
;       RANGE: The range associated with the colorbar axis. The default
;           is [0, NCOLORS].
;
;       TEXT: A text object. Colorbar axis annotation will use this text
;           object to set its properties. The default is a text object
;           using a 8 point Helvetica font in the axis color.
;
;       TITLE: A string containing a title for the colorbar axis
;           annotation. The default is a null string.
;
; OTHER METHODS:
;
;       GetProperty (Procedure): Returns colorbar properties in keyword
;          parameters as defined for the INIT method. Keywords allowed are:
;
;               COLOR
;               NAME
;               MAJOR
;               MINOR
;               PALETTE
;               POSITION
;               RANGE
;               TEXT
;               TITLE
;
;       SetProperty (Procedure): Sets colorbar properties in keyword
;          parameters as defined for the INIT method. Keywords allowed are:
;
;               COLOR
;               NAME
;               MAJOR
;               MINOR
;               PALETTE
;               POSITION
;               RANGE
;               TEXT
;               TITLE
;
; SIDE EFFECTS:
;       A HColorBar structure is created. The colorbar INHERITS IDLgrMODEL.
;       Thus, all IDLgrMODEL methods and keywords can also be used. It is
;       the model that is selected in a selection event, since the SELECT_TARGET
;       keyword is set for the model.
;
; RESTRICTIONS:
;       None.
;
; EXAMPLE:
;       To create a colorbar object and add it to a plot view object, type:
;
;       thisColorBarObject = Obj_New('HColorBar')
;       plotView->Add, thisColorBarObject
;       plotWindow->Draw, plotView
;
; MODIFICATION HISTORY:
;       Written by David Fanning, from VColorBar code, 20 Sept 98. DWF.
;       Changed a reference to _Ref_Extra to _Extra. 27 Sept 98. DWF.
;       Fixed bug when adding a text object via the TEXT keyword. 9 May 99. DWF.
;-
;
;###########################################################################
;
; LICENSE
;
; This software is OSI Certified Open Source Software.
; OSI Certified is a certification mark of the Open Source Initiative.
;
; Copyright © 2000 Fanning Software Consulting.
;
; This software is provided "as-is", without any express or
; implied warranty. In no event will the authors be held liable
; for any damages arising from the use of this software.
;
; Permission is granted to anyone to use this software for any
; purpose, including commercial applications, and to alter it and
; redistribute it freely, subject to the following restrictions:
;
; 1. The origin of this software must not be misrepresented; you must
;    not claim you wrote the original software. If you use this software
;    in a product, an acknowledgment in the product documentation
;    would be appreciated, but is not required.
;
; 2. Altered source versions must be plainly marked as such, and must
;    not be misrepresented as being the original software.
;
; 3. This notice may not be removed or altered from any source distribution.
;
; For more information on Open Source Software, visit the Open Source
; web site: http://www.opensource.org.
;
;###########################################################################


FUNCTION Normalize, range, Position=position

    ; This is a utility function to calculate the scale factor
    ; required to position a vector of specified range at a
    ; specific position given in normalized coordinates.

IF (N_Elements(position) EQ 0) THEN position = [0.0, 1.0]

scale = [((position[0]*range[1])-(position[1]*range[0])) / $
    (range[1]-range[0]), (position[1]-position[0])/(range[1]-range[0])]

RETURN, scale
END
;-------------------------------------------------------------------------



FUNCTION HColorBar::INIT, Position=position, Text=text, $
    NColors=ncolors, Title=title, Palette=palette, $
    Major=major, Minor=minor, Range=range, Color=color, $
    _Extra=extra, Name=name

   ; Catch possible errors.

Catch, error
IF error NE 0 THEN BEGIN
   Catch, /Cancel
   ok = Dialog_Message(!Error_State.Msg)
   Message, !Error_State.Msg, /Informational
   RETURN, 0
ENDIF

   ; Initialize superclass.

IF (self->IDLgrModel::Init(_EXTRA=extra) NE 1) THEN RETURN, 0

    ; Define default values for keywords, if necessary.

IF N_Elements(title) EQ 0 THEN title=''
IF N_Elements(name) EQ 0 THEN name=''
IF N_Elements(color) EQ 0 THEN self.color = [255,255,255] $
   ELSE self.color = color
IF N_Elements(text) EQ 0 THEN BEGIN
    IF N_Elements(title) EQ 0 THEN title=''
    thisFont = Obj_New('IDLgrFont', 'Helvetica', Size=9.0)
    thisText = Obj_New('IDLgrText', title, Color=self.color, $
       Font=thisFont)
    self.thisText = thisText
    self.thisFont = thisFont
ENDIF ELSE BEGIN
   self.thisText = text
   self.thisText->GetProperty, Font=thisFont
   self.thisFont = thisFont
   IF N_Elements(title) NE 0 THEN BEGIN
      self.thisText->SetProperty, Strings=title
   ENDIF
ENDELSE
IF N_Elements(ncolors) EQ 0 THEN self.ncolors = 256 $
   ELSE self.ncolors = ncolors
IF N_Elements(palette) EQ 0 THEN BEGIN
    red = (green = (blue = BIndGen(self.ncolors)))
    self.palette = Obj_New('IDLgrPalette', red, green, blue)
ENDIF ELSE self.palette = palette
IF N_Elements(range) EQ 0 THEN self.range = [0, self.ncolors] $
   ELSE self.range = range
IF N_Elements(major) EQ 0 THEN self.major = 5 $
   ELSE self.major = major
IF N_Elements(minor) EQ 0 THEN self.minor = 4 $
   ELSE self.minor = minor
IF N_Elements(position) EQ 0 THEN self.position = [0.10, 0.90, 0.90, 0.95] $
   ELSE self.position = position

    ; Create the colorbar image. Get its size.

bar = BINDGEN(self.ncolors) # REPLICATE(1B,10)
s = SIZE(bar, /Dimensions)
xsize = s[0]
ysize = s[1]

    ; Create the colorbar image object. Add palette to it.

thisImage = Obj_New('IDLgrImage', bar, Palette=self.palette)

    ; Scale the image into the correct position.

xs = Normalize([0,xsize], Position=[self.position(0), self.position(2)])
ys = Normalize([0,ysize], Position=[self.position(1), self.position(3)])
thisImage->SetProperty, XCoord_Conv=xs, YCoord_Conv=ys

    ; Create scale factors to position the axes.

;longScale = Normalize(self.range, Position=[self.position(0), self.position(2)])
longScale = Normalize([0,self.ncolors], Position=[self.position(0), self.position(2)])

shortScale = Normalize([0,1], Position=[self.position(1), self.position(3)])

    ; Create the colorbar axes.

    shortAxis1 = Obj_New("IDLgrAxis", 1, Color=self.color, Ticklen=0.025, $
    Major=1, Range=[0,1], /NoText, /Exact, YCoord_Conv=shortScale,  $
    Location=[self.position(0), 1000, 0])
    shortAxis2 = Obj_New("IDLgrAxis", 1, Color=self.color, Ticklen=0.025, $
    Major=1, Range=[0,1], /NoText, /Exact, YCoord_Conv=shortScale,  $
    Location=[self.position(2), 1000, 0], TickDir=1)

    textAxis = Obj_New("IDLgrAxis", 0, Color=self.color, Ticklen=0.025, $
    Major=self.major, Minor=self.minor, Title=thisText, Range=self.range, /Exact, $
    XCoord_Conv=longScale, Location=[1000, self.position(1), 0])
    textAxis->GetProperty, TickText=thisText
    thisText->SetProperty, Font=self.thisFont

    longAxis2 = Obj_New("IDLgrAxis", 0, Color=self.color, /NoText, Ticklen=0.025, $
    Major=self.major, Minor=self.minor, Range=self.range, TickDir=1, $
    XCoord_Conv=longScale, Location=[1000, self.position(3), 0], /Exact)

    ; Add the parts to the colorbar model.

self->Add, thisImage
self->Add, shortAxis1
self->Add, shortAxis2
self->Add, textAxis
self->Add, longAxis2

   ; Assign the name.

self->IDLgrModel::SetProperty, Name=name, Select_Target=1

    ; Create a container object and put the model into it.

thisContainer = Obj_New('IDL_Container')
thisContainer->Add, thisFont
thisContainer->Add, self.thisText
thisContainer->Add, self.palette
thisContainer->Add, textAxis
thisContainer->Add, shortAxis1
thisContainer->Add, shortAxis2
thisContainer->Add, longAxis2

    ; Update the SELF structure.

self.thisImage = thisImage
self.thisFont = thisFont
self.thisText = thisText
self.textAxis = textAxis
self.shortAxis1 = shortAxis1
self.shortAxis2 = shortAxis2
self.longAxis2 = longAxis2
self.thisContainer = thisContainer


RETURN, 1
END
;-------------------------------------------------------------------------



PRO HColorBar::Cleanup

    ; Lifecycle method to clean itself up.

Obj_Destroy, self.thisContainer
self->IDLgrMODEL::Cleanup
END
;-------------------------------------------------------------------------



PRO HColorBar::GetProperty, Position=position, Text=text, $
    Title=title, Palette=palette, Major=major, Minor=minor, $
    Range=range, Color=color, Name=name

    ; Get the properties of the colorbar.

IF Arg_Present(position) THEN position = self.position
IF Arg_Present(text) THEN text = self.text
IF Arg_Present(title) THEN self.text->GetProperty, Strings=title
IF Arg_Present(palette) THEN palette = self.palette
IF Arg_Present(major) THEN major = self.major
IF Arg_Present(minor) THEN minor = self.minor
IF Arg_Present(range) THEN range = self.range
IF Arg_Present(color) THEN color = self.color
IF Arg_Present(name) THEN self->IDLgrMODEL::GetProperty, Name=name
IF Arg_Present(extra) THEN self->IDLgrMODEL::GetProperty, _Ref_Extra=extra

END
;-------------------------------------------------------------------------



PRO HColorBar::SetProperty, Position=position, Text=text, $
    Title=title, Palette=palette, Major=major, Minor=minor, $
    Range=range, Color=color, Name=name

    ; Set properties of the colorbar.

IF N_Elements(position) NE 0 THEN BEGIN
    self.position = position

        ; Find the size of the image. Scale it.

    self.thisImage->GetProperty, Data=image
    s = Size(image)
    xsize = s(1)
    ysize = s(2)
    xs = Normalize([0,xsize], Position=[position(0), position(2)])
    ys = Normalize([0,ysize], Position=[position(1), position(3)])
    self.thisImage->SetProperty, XCoord_Conv=xs, YCoord_Conv=ys

        ; Create new scale factors to position the axes.

;    longScale = Normalize(self.range, $
;       Position=[self.position(1), self.position(3)])
    longScale = Normalize([0,self.ncolors], $
       Position=[self.position(1), self.position(3)])

    shortScale = Normalize([0,1], $
       Position=[self.position(0), self.position(2)])

        ; Position the axes. 1000 indicates this location is ignored.

    self.textaxis->SetProperty, YCoord_Conv=longScale, $
       Location=[self.position(0), 1000, 0]
    self.longaxis2->SetProperty, YCoord_Conv=longScale, $
       Location=[self.position(2), 1000, 0]
    self.shortAxis1->SetProperty, XCoord_Conv=shortScale, $
       Location=[1000, self.position(1), 0]
    self.shortAxis2->SetProperty, XCoord_Conv=shortScale, $
       Location=[1000, self.position(3), 0]

ENDIF
IF N_Elements(text) NE 0 THEN self.text = text
IF N_Elements(title) NE 0 THEN self.thisText->SetProperty, Strings=title
IF N_Elements(palette) NE 0 THEN BEGIN
    self.palette = palette
    self.thisImage->SetProperty, Palette=palette
ENDIF
IF N_Elements(major) NE 0 THEN BEGIN
    self.major = major
    self.textAxis->SetProperty, Major=major
    self.longAxis2->SetProperty, Major=major
END
IF N_Elements(minor) NE 0 THEN BEGIN
    self.minor = minor
    self.textAxis->SetProperty, Minor=minor
    self.longAxis2->SetProperty, Minor=minor
END
IF N_Elements(range) NE 0 THEN BEGIN
    self.range = range
;    longScale = Normalize(range, $
;       Position=[self.position(1), self.position(3)])
    longScale = Normalize([0,self.ncolors], $
       Position=[self.position(1), self.position(3)])

    self.textAxis->SetProperty, Range=range, YCoord_Conv=longScale
    self.longAxis2->SetProperty, Range=range, YCoord_Conv=longScale
ENDIF
IF N_Elements(color) NE 0 THEN BEGIN
    self.color = color
    self.textAxis->SetProperty, Color=color
    self.longAxis2->SetProperty, Color=color
    self.shortAxis1->SetProperty, Color=color
    self.shortAxis2->SetProperty, Color=color
    self.thisText->SetProperty, Color=color
ENDIF
IF N_Elements(name) NE 0 THEN self->IDLgrMODEL::SetProperty, Name=name
IF N_Elements(extra) NE 0 THEN self->IDLgrMODEL::SetProperty, _Extra=extra
END
;-------------------------------------------------------------------------



PRO HColorBar__Define

colorbar = { HCOLORBAR, $
             INHERITS IDLgrMODEL, $      ; Inherits the Model Object.
             Position:FltArr(4), $       ; The position of the colorbar.
             Palette:Obj_New(), $        ; The colorbar palette.
             thisImage:Obj_New(), $      ; The colorbar image.
             imageModel:Obj_New(), $     ; The colorbar image model.
             thisContainer:Obj_New(), $  ; Container for cleaning up.
             thisFont:Obj_New(), $       ; The annotation font object.
             thisText:Obj_New(), $       ; The bar annotation text object.
             textAxis:Obj_New(), $       ; The axis containing annotation.
             shortAxis1:Obj_New(), $     ; A short axis.
             shortAxis2:Obj_New(), $     ; A second short axis.
             longAxis2:Obj_New(), $      ; The other long axis.
             NColors:0, $                ; The number of colors in the bar.
             Major:0, $                  ; Number of major axis intervals.
             Minor:0, $                  ; Number of minor axis intervals.
             Color:BytArr(3), $          ; Color of axes and annotation.
             Range:FltArr(2) }           ; The range of the colorbar axis.

END
;-------------------------------------------------------------------------
