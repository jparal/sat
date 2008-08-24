 rd1,'Dns45_1p5t81',by
ix=findgen(901)*.25
 iy=findgen(128)*.25
dn=dn(*,1:*)
contour,nle=16,dn,ix,iy,/fill,/yst,xra=[100,200],xtitle='x',ytitle='y',title='Density'
end
