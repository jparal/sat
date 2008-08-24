FUNCTION PHY_MGPAUSE, uu, cutoff

  uuloc = uu

  uuloc[where(uu GT cutoff)] = 1.
  uuloc[where(uu LT .99)] = 0.
  uuloc = SMOOTH (uuloc,4)
  uuloc = SMOOTH (uuloc,4)

;;  uuret = uuloc
;;  uuret(*,*,*) = 0.
;;  uuret[where( 0.01 LT uuloc AND uuloc LT 0.05 )] = 1.

  uuloc[where( 0.4 LT uuloc AND uuloc LT 0.6 )] = 2.
  uuloc[where(uuloc LT 1.9)] = 0.
  uuloc[where(uuloc GT 0.5)] = 2.

  RETURN, uuloc

END
