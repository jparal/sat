;+
; NAME:
;   xcd
;
; PURPOSE:
;   Change current directory via mouse.
;
;   Two lists are displayed side by side.  The one on the left shows
;   directories.  Click on a directory to cd there.  The list
;   on the right shows files to help you see where you are.
;   (The list on the right does not respond to mouse clicks.)
; CATEGORY:
;   Utility.
; CALLING SEQUENCE:
;   xcd
; INPUTS:
;   None.
; KEYWORD PARAMETERS:
;   None
; OUTPUTS:
;   None.
; SIDE EFFECTS:
;   Your current directory can be changed.
; RESTRICTIONS:
;   Windows, OpenVMS & unix platforms only.  Originally written on Windows95.
;   Should work on other Windows platforms, but I (Paul) havn't tried it.
;   Unix functionality written on HP and SGI machines.
;
;   Note that drive names are resolved by procedure GET_DEVICES
;
; PROCEDURE:
;   Xcd has a reference to a DirListing, and
;   widgets for displaying that DirListing.  If the user clicks on a
;   sub-directory (or "..\"), or droplist-selects a different drive,
;   xcd changes IDL's current directory to that location, and
;   refreshes with a new current-directory DirListing.
;
; MODIFICATION HISTORY:
;   Paul C. Sorenson, July 1997. paulcs@netcom.com.
;        Written with IDL 5.0.
;   Jim Pendleton, July 1997. jimp@rsinc.com
;        Modified for compatability with OpenVMS as a basis for
;        platform independent code
;   Paul C. Sorenson, July 13, 1997.  Changes so that DirListing class
;        methods do not return pointers to data members.  (Better
;        object-oriented design that way.)
;   Karsten Rodenacker, July 16, 1997. Changes using my routine GET_DEVICES
;        and additions for unix machines
;   Paul C. Sorenson. July 22, 1997.  Hardcode drive "A:" to always appear
;        when running on Windows.
;   Paul C. Sorenson. Nov 8, 1997.  Avoid testing for the existence of "A:"
;        on Windows platform.  Doing so was slow, and unnessesary due to
;        July 22 modification.
;   Paul C. Sorenson. December 10, 1997.  Make xcd be a widget program with
;        a state rather than an object.
;-
function dirlisting::init, location
;
;Function DirListing::INIT: construct listing of LOCATION's contents.
;INPUT:
;  LOCATION (optional): string indicating the directory we want listing
;                       of. default is current directory.
;
catch, error_stat
if error_stat ne 0 then begin
   catch, /cancel
   print, !err_string
   return, 0
   end
;
;Store name of location.
;
if n_elements(location) gt 0 then $
   pushd, location
cd, current=current
case !version.os_family of
   'Windows' : begin
      self.Drive = strupcase(strmid(current, 0, 2))
      self.Path = strmid(current, 2, strlen(current))
      end
   'vms' : begin
      colon = rstrpos(current, ':')
      self.Drive = strmid(current, 0, colon + 1)
      rightbracket = rstrpos(current, ']')
      self.Path = strmid(current, colon + 1, rightbracket - colon)
      end
   'unix' : begin
      self.Drive = strmid(current, 0, rstrpos(current, '/'))
      self.Path = current
      end
   else :
   endcase
;
;Obtain listing of location's contents.
;
case !version.os_family of
   'Windows' : listing = findfile()
   'vms' : listing = findfile()
   'unix' : listing = findfile('-Fa')
   else :
   endcase
if n_elements(location) gt 0 then $
   popd
;
;Divide into direcory-only & file-only listings.
;
flags = bytarr(n_elements(listing))
case !version.os_family of
   'Windows' : begin
      for i=0,n_elements(listing)-1 do begin
         if rstrpos(listing[i], '\') eq (strlen(listing[i]) - 1) then $
            flags[i] = 1b
         end
      end
   'vms' : begin
      for i=0,n_elements(listing)-1 do begin
         dotdir = strpos(listing[i], '.DIR;')
         if dotdir ne -1 then begin
            flags[i] = 1b
            rightbracket = rstrpos(listing[i], ']')
            listing[i] = strmid(listing[i], rightbracket + 1, $
               dotdir - rightbracket - 1)
            end
         end
      end
   'unix' : begin
      for i=0,n_elements(listing)-1 do begin
         dotdir = strpos(listing[i], '/',1)
         if dotdir ne -1 then begin
            flags[i] = 1b
            rightbracket = strpos(listing[i], '/', dotdir + 1)
            listing[i] = strmid(listing[i], rightbracket + 1, $
               dotdir - rightbracket - 1)
            end
         end
      end
   else :
   endcase

dirs_indx = where(flags, dir_count)
files_indx = where(flags eq 0b, file_count)

if dir_count gt 0 then begin
   dirs = listing[dirs_indx]
   case !version.os_family of
      'Windows' : begin
         dirs = dirs[where(dirs ne '.\')]
         end
      'vms' :
      'unix' : dirs = dirs[where(dirs ne '.')]
      else :
      endcase
   dirs = dirs[sort(strupcase(dirs))]
   if (!version.os_family eq 'vms') then $
      dirs = ['[-]', 'sys$login', dirs]
   end $
else begin
   if (!version.os_family eq 'vms') then begin
      dirs = ['[-]', 'sys$login']
      end $
   else begin
      dirs = ''
      end
   end

if file_count gt 0 then begin
   files = listing[files_indx]
   case !version.os_family of
      'Windows':
      'vms': begin
          for i = 0l, n_elements(files) - 1 do begin
             rightbracket = rstrpos(files[i], ']')
             files[i] = strmid(files[i], rightbracket + 1, $
                strlen(files[i]))
             end
          end
      'unix':
      endcase
   files = files[sort(strupcase(files))]
   end $
else begin
   files = ''
   end
;
;Store pointers to resulting string arrays.
;
self.pSubdirNames = ptr_new(dirs, /no_copy)
self.pFileNames = ptr_new(files, /no_copy)
return, 1 ; Success.
end
;----------------------------------------------------------------------
pro dirlisting::cleanup
ptr_free, self.pSubdirNames
ptr_free, self.pFileNames
end
;----------------------------------------------------------------------
pro dirlisting__define
void = {dirlisting, $
   Drive: '',               $ ; e.g. 'C:'
   Path: '',                $ ; location.  e.g. '\foo\bar'
   pSubdirNames: ptr_new(), $ ; string array of sub-directory names
   pFileNames:   ptr_new()  $ ; string array of file names
   }
end
;----------------------------------------------------------------------
function dirlisting::SubdirNames
return, *self.pSubdirNames
end
;----------------------------------------------------------------------
function dirlisting::FileNames
return, *self.pFileNames
end
;----------------------------------------------------------------------
function dirlisting::Path
return, self.Path
end
;----------------------------------------------------------------------
function dirlisting::Drive
return, self.Drive
end
;----------------------------------------------------------------------
pro xcd_event, event

widget_control, event.top, get_uvalue=pXcd

catch, error_stat
if error_stat ne 0 then begin
   catch, /cancel
   void = dialog_message(!err_string, /error)
   xcd_update, *pXcd ; Try again, this time without "cd".
   return
   end

case event.id of
   (*pXcd).wDirList: begin
      path = (*pXcd).rDirListing->Path()
;
;     Construct full (if possible) pathname, and cd to it.  (Using
;     a full, rather than relative pathname here makes xcd impervious
;     to directory changes made by other IDL programs or from the
;     command line.)
;
      case !version.os_family of
         'Windows' : begin
            if rstrpos(path, '\') ne (strlen(path) - 1) then $
               path = path + '\'
            cd, (*pXcd).rDirListing->Drive() + $
                path                      + $
                ((*pXcd).rDirListing->SubdirNames())[event.index]
            end
         'vms' : begin
            subdir = ((*pXcd).rDirListing->SubdirNames())[event.index]
            if (subdir ne '[-]' and subdir ne 'sys$login') then begin
               rightbracket = rstrpos(path, ']')
               leftbracket = strpos(path, '[')
               path = strmid(path, leftbracket + 1, rightbracket - $
                  leftbracket - 1)
               newdir = (*pXcd).rDirListing->Drive() $
                  + '[' + path + '.' $
                  + subdir + ']'
               end $
            else begin
               newdir = subdir
               end
            cd, newdir
            end
         'unix' : begin
            if rstrpos(path, '/') ne (strlen(path) - 1) then $
               path = path + '/'
            cd, path + $
                ((*pXcd).rDirListing->SubdirNames())[event.index]
            end
         else:
         endcase
;
      xcd_update, *pXcd
      widget_control, (*pXcd).tlb, /update ; workaround.  Resize base.
      end
   (*pXcd).wDriveList: begin
      widget_control, /hourglass
      case !version.os_family of
         'Windows' : cd, (*(*pXcd).pDriveNames)[event.index]
         'vms' : cd, (*(*pXcd).pDriveNames)[event.index] + '[000000]'
         'unix' : cd, (*(*pXcd).pDriveNames)[event.index]
         else:
         endcase
      xcd_update, *pXcd
      widget_control, (*pXcd).tlb, /update ; workaround.  Resize base.
      end
   else: begin
      end
   endcase

end
;----------------------------------------------------------------------
pro xcd_cleanup, tlb
widget_control, tlb, get_uvalue=pXcd
obj_destroy, (*pXcd).rDirListing
ptr_free, (*pXcd).pDriveNames
ptr_free, pXcd
cd, current=current & print, current
end
;----------------------------------------------------------------------
pro xcd_update, xcd
;
;Procedure XCD_UPDATE: set self's widgets and state values to
;  reflect the current directory.
;
widget_control, /hourglass

obj_destroy, xcd.rDirListing
xcd.rDirListing = obj_new('dirlisting')

indx = where(*xcd.pDriveNames eq xcd.rDirListing->Drive())

widget_control, xcd.wDriveList, set_droplist_select=indx(0)
widget_control, xcd.wLabel,     set_value=xcd.rDirListing->Path()
widget_control, xcd.wDirList,   set_value=xcd.rDirListing->SubdirNames()
widget_control, xcd.wFileList,  set_value=xcd.rDirListing->FileNames()
end
;----------------------------------------------------------------------
pro xcd__define
void = {xcd,        $
   tlb:         0L, $      ; top-level base
   wDriveList:  0L, $      ; droplist of available drives.
   wLabel:      0L, $      ; shows name of current directory
   wDirList:    0L, $      ; shows sub-directories in current directory
   wFileList:   0L, $      ; shows files in current directory
   pDriveNames: ptr_new(),$; String array.  e.g. ['A', 'C:', 'D:', etc.]
   rDirListing: obj_new() $; listing of current directory
   }
end
;----------------------------------------------------------------------
pro xcd

on_error, 2 ; Return to caller if error.

xcd = {xcd}

widget_control, /hourglass
case !version.os_family of
   'MacOS': begin
      message, 'Xcd has not been implemented for MacOS.'
      end
   'Windows': begin
      drives = string(bindgen(1,25) + (byte('B'))[0]) + ':' ; ['B:',...'Z:']
      indx = where(direxist(drives))
      if indx[0] ne -1 then $
         xcd.pDriveNames = ptr_new(['A:', drives(indx)]) $
      else $
         xcd.pDriveNames = ptr_new(['A:'])
      end
   else: begin
      xcd.pDriveNames = ptr_new(get_devices())
      end
   endcase
;
;Create widgets.  Store results in Xcd's state structure.
;
tlb = widget_base(title='xcd', /column) ; top-level base

readout_base = widget_base(tlb, /row)
xcd.wDriveList = widget_droplist(readout_base, value=*xcd.pDriveNames)
xcd.wLabel = widget_label(readout_base, /dynamic_resize)

list_base = widget_base(tlb, /row)
ysize = 20 ; Looks good on my (Paul's) monitor.
xcd.wDirList = widget_list(list_base, ysize=ysize)
xcd.wFileList = widget_list(list_base, ysize=ysize)
;
;Set remaining state structure values, then store resulting state.
;
xcd_update, xcd
xcd.tlb = tlb
widget_control, tlb, set_uvalue=ptr_new(xcd, /no_copy)
;
;Center and realize tlb.
;
device, get_screen_size=scrsz
widget_control, tlb, map=0
widget_control, tlb, /realize
tlb_geometry = widget_info(tlb, /geometry)
widget_control, tlb, $
                tlb_set_xoffset= 0 > (scrsz(0) - tlb_geometry.scr_xsize) / 2, $
                tlb_set_yoffset= 0 > (scrsz(1) - tlb_geometry.scr_ysize) / 2
widget_control, tlb, map=1
widget_control, tlb, /update ; workaround.  Resize base.
;
xmanager, 'xcd', tlb, cleanup='xcd_cleanup', /no_block
end


