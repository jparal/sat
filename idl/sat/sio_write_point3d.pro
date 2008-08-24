pro SIO_WRITE_POINT3D, fname, data, nosuffix=nosuffix, comment=comment
;+
; NAME:
;   SIO_WRITE_POINT3D
;
; PURPOSE:
;   Write array in Point3D data format.
;
; CATEGORY:
;   SIO
;
; INPUTS:
;   fname .. the file name
;
;   data .. data to write havin the dimension [4,*]
;
; KEYWORD PARAMETERS:
;   nosuffix ..  do not write suffix to the file name (.3D)
;
;   comment .. the comment on the fist line of file without # character
;   (default: "x y z value"
;
; OUTPUTS:
;    File in format:
;    # comment
;    data[0,0] data[1,0] data[2,0] data[3,0]
;    data[0,1] data[1,1] data[2,1] data[3,1]
;    ...
;
; MODIFICATION HISTORY:
;
;       Fri Jun 13 10:58:34 2008, Jan Paral <jparal@gmail.com>
;
;		Initial version

  UTL_CHECK_SIZE, data, ss=[2,4]
  lfname = fname ;;+'.3D'
  UTL_KEYWORD_DEF, comment, 'x y z val'
  lcomment = '# '+comment

  iunit=9
  OPENW,iunit,lfname ;;,compress=compress
  PRINTF,iunit,lcomment
  PRINTF,iunit,data
  CLOSE,iunit

  return
end
