function file_exists, filename
  
  res = findfile(filename, count = count)
  return, count

end