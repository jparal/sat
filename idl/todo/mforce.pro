FUNCTION mforce, bx, by, dx, dy

;; rd3,'Bxb25Kat40.gz',bx
;; rd3,'Bzb25Kat40.gz',bz

IF dx LE dy THEN epsilon = dx ELSE epsilon = dy
epsilon = epsilon / 2.

bb = sqrt(bx*bx + by*by)
ss = size(bb)

ff = bb

FOR i=1, ss(1)-2 DO BEGIN
   FOR j=1, ss(2)-2 DO BEGIN

      IF bx(i,j) GT 0. THEN ii = 1 ELSE ii = -1
      IF by(i,j) GT 0. THEN jj = 1 ELSE jj = -1

      f1 = bb(i   , j   )
      f2 = bb(i+ii, j   )
      f3 = bb(i+ii, j+jj) 
      f4 = bb(i   , j+jj)
 
      b0 = bb(i, j)
      bx0 = bx(i, j) / b0
      by0 = by(i, j) / b0

      xf = bx0 * epsilon / dx
      xa = 1.0 - xf

      yf = by0 * epsilon / dy
      ya = 1.0 - yf

      w1 = xa * ya
      w2 = xf * ya
      w3 = xf * yf
      w4 = xa * yf

      tmp = 0.
      tmp = tmp + f1 * w1
      tmp = tmp + f2 * w2
      tmp = tmp + f3 * w3
      tmp = tmp + f4 * w4

      b1 = tmp

      ff(i, j) = - (b1 - b0) / (b0 * epsilon)

   ENDFOR
ENDFOR

RETURN, ff
END
