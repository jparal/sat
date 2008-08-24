;asks for the type of the display 
; e.g. x,ps,tek,...
pro dis
c=' '
read,'display  (x,ps,tek,...) ',c
set_plot,c
return
end
