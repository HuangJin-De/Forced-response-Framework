program cal_obj_pdf
use read_cloud
implicit none

integer, parameter :: nx=1024,ny=512,nz=74
real, dimension(nx,ny,nz) :: qc 



call read_data("VVM","./test.nc",nx,ny,nz,200,qc)
call read_data("SCALE","./test.nc",nx,ny,nz,200,qc)
call read_data("CM1","./test.nc",nx,ny,nz,200,qc)




end program cal_obj_pdf
