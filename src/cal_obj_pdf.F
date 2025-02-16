program cal_obj_pdf
use read_cloud
implicit none

integer, parameter :: nx=512,ny=128,nz=70
real, dimension(nx,ny,nz) :: qc 



call read_data("VVM","./vvm_test.nc",nx,ny,nz,200,qc)
call read_data("SCALE","./scale_test.nc",nx,ny,nz,20,qc)
call read_data("CM1","./cm1_test.dat",nx,ny,nz,200,qc)




end program cal_obj_pdf
