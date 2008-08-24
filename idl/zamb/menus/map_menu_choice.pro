; ----------------------------------------- Map_Menu_Choice ---
;
;
;    PURPOSE   Given a uservalue from a menu button created
;              by Create_Menu, return the index of the choice
;              within the category.  Set the selected menu button
;              to insensitive to signify selection, and set all
;              other choices for the category to sensitive.
;

function Map_Menu_Choice, $
            Eventval, $         ; IN: uservalue from seleted menu button
            MenuItems, $        ; IN: menu item array, as returned by Create_Menu
            MenuButtons         ; IN: button array as returned by Create_Menu

on_error, 2

;print, 'In Plot2D_MapMenuChoice, eventval = ', eventval

i = STRPOS(eventval, '|', 0)    ;Get the name less the last qualifier
while (i GE 0) do begin
    j = i
    i = STRPOS(eventval, '|', i+1)
endwhile

base = STRMID(eventval, 0, j+1) ;  Get the common buttons, includes last | .
buttons = WHERE(STRPOS(MenuItems, base) EQ 0) ;  buttons that share base name.
this = (WHERE(eventval EQ MenuItems))[0] ;  Get the Index of the selected item.
for i=0, N_ELEMENTS(buttons)-1 do begin ;Each button in this category
    index = buttons[i]
    WIDGET_CONTROL, MenuButtons(buttons[i]), $
      SENSITIVE=index NE this
endfor

RETURN, this - buttons[0]       ;  Return the selected button's index.
end
; ---------------------------------------------------------------------
