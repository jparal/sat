
maxi = 220;
dit = 2;
mini = 170;

dn=sh5_rdsq('Dn','test','Dn',mini,dit,maxi);

bx=sh5_rdsq('B','test','B0',mini,dit,maxi);
by=sh5_rdsq('B','test','B1',mini,dit,maxi);
bz=sh5_rdsq('B','test','B2',mini,dit,maxi);
bb=sqrt(bx.^2+by.^2+bz.^2); bb(find(bb>100)) = 100.;

[cbx,cby,cbz]=curl(bx,by,bz);
cb=sqrt(cbx.^2+cby.^2+cbz.^2); cb(find(cb>100)) = 100.;

ex=sh5_rdsq('E','test','E0',mini,dit,maxi);
ey=sh5_rdsq('E','test','E1',mini,dit,maxi);
ez=sh5_rdsq('E','test','E2',mini,dit,maxi);
ee=sqrt(ex.^2+ey.^2+ez.^2);

JxBx=sh5_rdsq('JxB','test','JxB0',mini,dit,maxi);
JxBy=sh5_rdsq('JxB','test','JxB1',mini,dit,maxi);
JxBz=sh5_rdsq('JxB','test','JxB2',mini,dit,maxi);
JxB=sqrt(JxBx.^2+JxBy.^2+JxBz.^2);

CBxBx=sh5_rdsq('CBxB','test','CBxB0',mini,dit,maxi);
CBxBy=sh5_rdsq('CBxB','test','CBxB1',mini,dit,maxi);
CBxBz=sh5_rdsq('CBxB','test','CBxB2',mini,dit,maxi);
CBxB=sqrt(CBxBx.^2+CBxBy.^2+CBxBz.^2);

DbDtx=sh5_rdsq('DbDt','test','DbDt0',mini,dit,maxi);
DbDty=sh5_rdsq('DbDt','test','DbDt1',mini,dit,maxi);
DbDtz=sh5_rdsq('DbDt','test','DbDt2',mini,dit,maxi);
DbDt=sqrt(DbDtx.^2+DbDty.^2+DbDtz.^2);
