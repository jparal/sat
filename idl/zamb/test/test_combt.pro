nfiles = 3

fname = strarr(nfiles)
fpath = strarr(nfiles)

for i=0, nfiles -1 do begin
  fname[i] = dialog_pickfile(FILTER = '*.tif', get_path = path)
  fpath[i] = path
end


combine_tiff, fname, PATH = fpath, DIST = [2,2]

end