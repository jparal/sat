;-------------------------------------------------------------
;+
; NAME:
;       find_dpath.pro
; PURPOSE:
;       Use either pwd or IDL_DATA_PATH to find files matching a pattern.
; CATEGORY:
; CALLING SEQUENCE:
;	filepaths=find_dpath(filename)
; INPUTS:
;	filename	filename of data file to be found.
;			May contain wildcards acceptable to find(1)
; KEYWORD PARAMETERS:
;	ROOTDIR		Directory to use as a root for the search
;	FULLPATH	Causes output of full rather than relative paths
; OUTPUTS:
;	filepaths	An array of strings containing the path
;			to any matching files, relative to the rootdir
;			given.
;			If no file is found, returns an empty scalar string.
;
;
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Bunting, 29 Jan 1996
;	Modified to use structures pointing to data values and header
;			29 Jan 1996
;
; Copyright (C) 1996, York University Space Geophysics Group
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------


	function find_dpath,filename,rootdir=rootdir,fullpath=full,
	help=hlp
	
	if n_elements(filename) eq 0 then filename="    no filename set"

        if keyword_set(hlp) then $
          begin 
          print,''
          print,' NAME:'
          print,'       find_dpath.pro'
          print,' PURPOSE:'
          print,'       Use $IDL_DATA_PATH (or . if this is not set) to find files matching a pattern.'
          print,' CATEGORY:'
          print,' CALLING SEQUENCE:'
          print,'	filepaths=find_dpath(filename)'
          print,' INPUTS:'
          print,'	filename	filename of data file to be found.'
          print,'			May contain wildcards acceptable to find(1)'
          print,' KEYWORD PARAMETERS:'
          print,'	ROOTDIR		Directory to use as a root for the search'
          print,'	FULLPATH	Causes output of full rather than relative paths'
          print,' OUTPUTS:'
          print,'	filepaths	An array of strings containing the path'
          print,'			to any matching files, relative to the rootdir'
          print,'			given.'
          print,'			If no file is found, returns an empty scalar string.'
          print,''
	endif
	
	
	
	if n_elements(rootdir) eq 0 then $
	  rootdir=getenv('IDL_DATA_PATH')
;	Took this out; a bit bad if say you're root.
;	(as you would end up running find over the whole directory tree!)
;	if n_elements(rootdir) eq 0 then $
;	  rootdir=getenv('HOME')
	if n_elements(rootdir) eq 0 then $
	  rootdir='.'
	  
;	Need to seperate components of rootdir, so it can contain
;	multiple path components
;	Then make a series of searches.  Not sure how we can eliminate
;	wastage and multiple runs.
	  
	  
	spawn,['/bin/find',rootdir,'-name',filename,'-print'],files,/noshell
	  
	  
	  
	  
	  
