; --------------------------------------------- Enable_Menu_Choice ---
;
;
;    PURPOSE   Given a uservalue from a menu button created
;              by Create_Menu, enable this button
;

pro Enable_Menu_Choice, $
            button, $           ; IN: uservalue from seleted menu button
            MenuItems, $        ; IN: menu item array, as returned by Create_Menu
            MenuButtons         ; IN: button array as returned by Create_Menu

on_error, 2

this = (WHERE(button EQ MenuItems))[0] ;  Get the Index of the selected item.

WIDGET_CONTROL, MenuButtons(this), SENSITIVE= 1

end
; ---------------------------------------------------------------------
