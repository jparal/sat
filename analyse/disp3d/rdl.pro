
!P.Multi = [0, 1, 2, 0, 1]

; p : Peter, m : mine

;; rd,'firehose.kvect',pk
;; rd,'firehose.omega',pw
;; rd,'firehose.gamma',py
;; rd,'cyclotron.kvect',pk
;; rd,'cyclotron.omega',pw
;; rd,'cyclotron.gamma',py

sh5_read, 'firehose.h5', 'k', mk
sh5_read, 'firehose.h5', 'wp', mwp
sh5_read, 'firehose.h5', 'yp', myp
sh5_read, 'firehose.h5', 'wm', mwm
sh5_read, 'firehose.h5', 'ym', mym
plot, mk,mwp
plot, mk,myp

sh5_read, 'cyclotron.h5', 'k', mk
sh5_read, 'cyclotron.h5', 'wp', mwp
sh5_read, 'cyclotron.h5', 'yp', myp
sh5_read, 'cyclotron.h5', 'wm', mwm
sh5_read, 'cyclotron.h5', 'ym', mym
;; plot, mk,mwm
;; plot, mk,mym

;; sh5_read, 'bump.h5', 'k', mk
;; sh5_read, 'bump.h5', 'wp', mwp
;; sh5_read, 'bump.h5', 'yp', myp
;; sh5_read, 'bump.h5', 'wm', mwm
;; sh5_read, 'bump.h5', 'ym', mym

;xrng = [0.2, 0.3]
plot, mk, mwm, yrange=[min([mwm,mwp]),max([mwm,mwp])], /yst, xrange=xrng
oplot, mk, mwp
IF KEYWORD_SET(pk) THEN BEGIN
   oplot, pk, pw, linestyle=2
endif

plot, mk, mym, yrange=[min([mym,myp]),max([mym,myp])], /yst, xrange=xrng
oplot, mk, myp
IF KEYWORD_SET(pk) THEN BEGIN
   oplot, pk, py, linestyle=2
endif

END
