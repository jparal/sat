; -------------------------------------------------- SceneAntiAlias ---
; AntiAliases the view/scence v on window w, with a jitter factor of 4
; Original Copied from the object world demo d_objworld2.pro
; ---------------------------------------------------------------------

PRO SceneAntiAlias,w,v,n
  on_error, 2
  
  if N_Elements(n) eq 0 then n = 4
  case n of
        2 : begin
                jitter = [[ 0.246490,  0.249999],[-0.246490, -0.249999]]
                njitter = 2
        end
        3 : begin
                jitter = [[-0.373411, -0.250550],[ 0.256263,  0.368119], $
                          [ 0.117148, -0.117570]]
                njitter = 3
        end
        8 : begin
                jitter = [[-0.334818,  0.435331],[ 0.286438, -0.393495], $
                          [ 0.459462,  0.141540],[-0.414498, -0.192829], $
                          [-0.183790,  0.082102],[-0.079263, -0.317383], $
                          [ 0.102254,  0.299133],[ 0.164216, -0.054399]]
                njitter = 8
        end
        else : begin
                jitter = [[-0.208147,  0.353730],[ 0.203849, -0.353780], $
                          [-0.292626, -0.149945],[ 0.296924,  0.149994]]
                njitter = 4
        end
  end
 
  w->getproperty,dimension=d
  acc = fltarr(3,d[0],d[1])

  if (obj_isa(v,'idlgrview')) then begin
	nViews = 1
	oViews = objarr(1)
	oViews[0] = v
  end else begin
	nViews = v->count()
	oViews = v->get(/all)
  end

  rView = fltarr(4,nViews)
  for j=0,nViews-1 do begin 
 	oViews[j]->idlgrview::getproperty,view=view
	rView[*,j] = view
  end

  for i=0,njitter-1 do begin

	for j=0,nViews-1 do begin 
  		sc = float(rView(2,j))/(float(d[0]))
        	oViews[j]->setproperty,view=[rView[0,j]+jitter[0,i]*sc, $
                             rView[1,j]+jitter[1,i]*sc,rView[2,j],rView[3,j]]
  	end

        w->draw,v
        img = w->read()
        img->getproperty,data=data
        acc = acc + float(data)
        obj_destroy,img

	for j=0,nViews-1 do begin
  		oViews[j]->setproperty,view=rView[*,j]
	end
  end

  acc = acc / float(njitter)

  o=obj_new('idlgrimage',acc)

  v2=obj_new('idlgrview',view=[0,0,d[0],d[1]],proj=1)
  m=obj_new('idlgrmodel')
  m->add,o
  v2->add,m

  w->draw,v2

  obj_destroy,v2

END
; ---------------------------------------------------------------------
