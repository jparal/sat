pro bullet, x, y, radi, ct, color, imx=imx, imy=imy

; TODO:
; rename => plt_bullet
;; imi=findgen(1001)/1000*!pi*2
;; imx=sin(imi)
;; imy=cos(imi)
; text + text offset

loadct,ct,/silent
polyfill,imx*radi + x, imy*radi + y,color=color,/data
loadct,0,/silent
oplot,   imx*radi + x, imy*radi + y,color=0, thick=1

return
end
