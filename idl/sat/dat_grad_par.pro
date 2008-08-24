FUNCTION dat_grad_par, vx, vy, DX=dx, DY=dy

  IF NOT (keyword_set(dx)) THEN dx=1.
  IF NOT (keyword_set(dy)) THEN dy=1.

  IF dx LE dy THEN epsilon = dx ELSE epsilon = dy
  epsilon = epsilon / 2.

  bb = sqrt(vx*vx + vy*vy)
  ss = size(bb)

  ff = bb

  FOR i=1, ss(1)-2 DO BEGIN
     FOR j=1, ss(2)-2 DO BEGIN

        IF vx(i,j) GT 0. THEN ii = 1 ELSE ii = -1
        IF vy(i,j) GT 0. THEN jj = 1 ELSE jj = -1

        f1 = bb(i   , j   )
        f2 = bb(i+ii, j   )
        f3 = bb(i+ii, j+jj) 
        f4 = bb(i   , j+jj)
 
        b0 = bb(i, j)
        vx0 = vx(i, j) / b0
        vy0 = vy(i, j) / b0

        xf = vx0 * epsilon / dx
        xa = 1.0 - xf

        yf = vy0 * epsilon / dy
        ya = 1.0 - yf

        w1 = xa * ya
        w2 = xf * ya
        w3 = xf * yf
        w4 = xa * yf

        b1 = 0.
        b1 = b1 + f1 * w1
        b1 = b1 + f2 * w2
        b1 = b1 + f3 * w3
        b1 = b1 + f4 * w4

        ff(i, j) = (b1 - b0) /  epsilon

     ENDFOR
  ENDFOR

  RETURN, ff
END
