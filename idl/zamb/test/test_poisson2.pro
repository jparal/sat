pro test_poisson2

  pData  = ptr_new(complexarr(704,160,160), /no_copy)
  
  (*pData)[300:400, 80:100, 80:100] = 1.0
  
  poisson_solver, pData, /time
  
  ptr_free, pData

end