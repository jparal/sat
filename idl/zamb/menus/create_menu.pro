; ----------------------------------------------- Plot2D_MenuCreate ---
;
;
;
;    PURPOSE  Create a menu from a string descriptor (MenuItems).
;             Return the parsed menu items in MenuItems (overwritten),
;             and the array of corresponding menu buttons in MenuButtons.
;
;    MenuItems = (input/output), on input the menu structure
;                in the form of a string array.  Each button
;                is an element, encoded as follows:
;
;    Character 1 and 2 = hex bit flag.  
;           Bit 0 = 1 to denote a button with children.  
;           Bit 1 = 2 to denote this is the last child of its parent.
;           Bit 2 = 4 to show that this button should initially be 
;                    insensitive, to denote selection.
;           Bit 3 = 8 to use a separator before the button
;                  Any combination of bits may be set.
;                 
;	           On RETURN, MenuItems contains the fully
;                  qualified button names.
;
;    Characters 2-end = Menu button text.  Text should NOT
;                       contain the character |, which is used
;                       to delimit menu names.
;
;    Example:
;
;        MenuItems = ['1File', $
;                       '0Save', $
;                       '2Quit', $
;		           '1Edit',$
;                       '2Cut', $
;		           '2Help']
;
;         Creates a menu with three top level buttons
;         (file, edit and help). File has 2 choices
;         (save and exit), Edit has one choice, and help has none.
;         On RETURN, MenuItems contains the fully qualified
;         menu button names in a string array of the
;         form: ['<Prefix>|File', '<Prefix>|File|Save',
;	        '<Prefix>|File|Quit', '<Prefix>|Edit',..., etc. ]
;

function __Get_Menu_Level, MenuItem
  level = 0
  pos = strpos(MenuItem,'|')
  while (pos ne -1) do begin
     pos = pos + 1
     level = level + 1
     pos = strpos(MenuItem,'|', pos)
  end
  return, level
end


pro Create_Menu, $
                MenuItems, $    ; IN/OUT: See below
                MenuButtons, $  ; OUT: Button widget id's of the created menu
                Bar_base, $     ; IN: menu base ID
                Prefix=prefix, $; IN: (opt) Prefix for this menu's button names.
                                ;     If omitted, no prefix
                realize = realize, $
                event_pro = event_pro, verbose = verbose

on_error, 2

level = 0
parent = [ bar_base, 0, 0, 0, 0, 0]
names = STRARR(5)
lflags = INTARR(5)

MenuButtons = LONARR(N_ELEMENTS(MenuItems))

if (N_ELEMENTS(prefix)) then begin
    names(0) = prefix + '|'
endif else begin
    names(0) = '|'
endelse

if (Keyword_Set(verbose)) then begin
  print, 'Creating menu, baseID = ', Bar_base
end

for i=0, N_ELEMENTS(MenuItems)-1 do begin
    flag = lon_hex(STRMID(MenuItems(i), 0, 1))
    txt = STRMID(MenuItems(i), 1, 100)
    uv = ''

    for j = 0, level do uv = uv + names(j)
    MenuItems(i) = uv + txt     ;  Create the button for fully qualifid names.
    isHelp = txt eq 'Help' or txt eq 'About'
        
    MenuButtons(i) = WIDGET_BUTTON(parent(level), $
                                   VALUE= txt, UVALUE=uv+txt, $
                                   MENU=(flag and 1), HELP=isHelp, $
                                   SEPARATOR = (flag and 8), event_pro = event_pro)
                                   
    if (Keyword_Set(verbose)) then begin
    ;  print, '-------------------------'
    ;  print, 'ID     = ', MenuButtons(i)
    ;  print, 'Parent = ', parent(level) 
    ;  print, txt
     ; print, uv+txt
     ; print, '-------------------------'
      
      print, uv+txt, MenuButtons(i)
    end   

    if ((flag AND 4) NE 0) then begin
        WIDGET_CONTROL, MenuButtons(i), SENSITIVE = 0
    endif

;    if (keyword_set(realize)) then begin
;       WIDGET_CONTROL, MenuButtons(i), /realize
;    end

    if (flag AND 1) then begin
        level = level + 1
        parent(level) = MenuButtons(i)
        names(level) = txt + '|'
        lflags(level) = (flag and 2) NE 0
    endif else if ((flag AND 2) NE 0) then begin
        while lflags(level) do level = level-1 ;  Pops the previous levels.
        level = level - 1
    endif
endfor

if (keyword_set(realize)) then begin
    WIDGET_CONTROL, Bar_base, /realize
end


;if (keyword_set(realize)) then begin
;  if (N_ELEMENTS(prefix)) then begin
;    base_level = __Get_Menu_Level(prefix)
;  endif else begin
;    base_level = 0
;  endelse
;  
;  for i=0, N_ELEMENTS(MenuItems)-1 do begin
;    if (__Get_Menu_Level(MenuItems[i])-base_level eq 1) then begin
;      print, 'Realizing ',MenuItems[i]
;      widget_control, MenuButtons[i], /realize       
;    end
;  end
;end
end
; ---------------------------------------------------------------------