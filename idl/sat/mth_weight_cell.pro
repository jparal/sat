FUNCTION MTH_WEIGHT_CELL, data, cx, cy

  ON_ERROR, 1
  ss = SIZE (data)
  IF (ss(0) NE 2)    THEN MESSAGE, 'Function require 2D data (for now)'
  IF (cx GT ss(1)-1) THEN MESSAGE, 'Parameter "cx" exceed number of elements'
  IF (cy GT ss(2)-1) THEN MESSAGE, 'Parameter "cy" exceed number of elements'

;; Relative position in cell
  i = UINT (cx)
  xf = cx - i;
  xa = 1. - xf;

  j = UINT (cy)
  yf = cy - j;
  ya = 1. - yf;

;; Bilinear weights
  w1 = xa * ya;
  w2 = xf * ya;
  w3 = xf * yf;
  w4 = xa * yf;

  tmp = 0.
  tmp = tmp + data(i  ,j  ) * w1
  tmp = tmp + data(i+1,j  ) * w2
  tmp = tmp + data(i+1,j+1) * w3
  tmp = tmp + data(i  ,j+1) * w4

  RETURN, tmp
END
