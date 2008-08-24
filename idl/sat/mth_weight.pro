FUNCTION MTH_WEIGHT, data, x, y, DX=dx, DY=dy

  ON_ERROR, 1
  ss = SIZE (data)
  IF (ss(0) NE 2) THEN MESSAGE, 'Function require 2D data (for now)'

  IF NOT (KEYWORD_SET(dx)) THEN dx=1.
  IF NOT (KEYWORD_SET(dy)) THEN dy=1.

  ;; All other testing is done inside of MTH_WEIGHT_CELL
  RETURN, MTH_WEIGHT_CELL, data, x/dx, y/dy
END
