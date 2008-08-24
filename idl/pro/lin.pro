;--------------------------------------------------------------------;
; lin,name,time                                                 ;
;                                                                    ;
; Read position of all cluster II spacecrafts in minute intervals    ;
; and from crossing time evaulate coordinate of shock crossing       ;
;                                                                    ;
; name                                                               ;
; ----                                                               ;
;  File name with position.                                          ;
; The positions file has the format:                                 ;
;                                                                    ;
; number_of_lines                                                    ;
; x_GSE   y_GSE   z_GSE                                              ;
; ........                                                           ;
;                                                                    ;
; time                                                               ;
; ----                                                               ;
;  Time in seconds from beging. Letting first given value be at      ;
; time 0                                                             ;
;                                                                    ;
;                                                                    ;
; TODO:                                                              ;
;  - Add parameter for option where times are given as well.         ;
;--------------------------------------------------------------------;
pro lin,name,time

SWREAD,name,data,ITEMS=3

; Export do Postscriptu?
;to_ps=1

;=====================================================================
;=====================================================================

;IF (to_ps GT 0) THEN TOPS
;IF (to_ps GT 0) THEN DEVICE,/LAND,/COLOR,FILE='out.ps'

;=========================================================;
; Linearize and compute shock crossing
;=========================================================;
n=size(data)
times = findgen(n(2))*60
weight = findgen(n(2))
weight(*) = 1.0

; P(0) .. rychlost razove vlny ve smeru normaly
; P(1) .. zrychleni razove vlny ve smeru normaly
expr = 'P(0) + P(1)*(x)'
start = [data(0,0),1.0]
result_x = MPFITEXPR(expr,times,data(0,*),weight, start)
start = [data(1,0),1.0]
result_y = MPFITEXPR(expr,times,data(1,*),weight, start)
start = [data(2,0),1.0]
result_z = MPFITEXPR(expr,times,data(2,*),weight, start)

; Pozice X
x=result_x(0) + result_x(1) * time
y=result_y(0) + result_y(1) * time
z=result_z(0) + result_z(1) * time


;=========================================================;
; Print result
;=========================================================;
print,data(0,*)
print,'Position of X Y Z:'
print,x,y,z

!p.multi=[0,2,2]

plot,times,data(0,*),psym=4,/yst
oplot,times,result_x(0)+result_x(1)*times

plot,times,data(1,*),psym=4,/yst
oplot,times,result_y(0)+result_y(1)*times

plot,times,data(2,*),psym=4,/yst
oplot,times,result_z(0)+result_z(1)*times

;--------------------------------------------------------------------;

;IF to_ps GT 0 THEN DEVICE,/CLOSE
;IF to_ps GT 0 THEN TOX

return
end
