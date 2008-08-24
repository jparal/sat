DirName = Dialog_PickFile(/Directory, TITLE = 'Select Data')
if (DirName eq '') then stop

;list = GenFrameList(DirName, IT0 = 160)
list = GenFrameList(DirName)
;list = GenFrameList(DirName, IT0 = 20, IT1 = 120)

print, list

end
