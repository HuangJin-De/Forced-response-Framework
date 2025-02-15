module read_cloud
use netcdf
implicit none




contains


subroutine read_data(model,fname,nx,ny,nz,step,condensate)
implicit none

! input/output
character(*), intent(in) :: model,fname
integer, intent(in) :: nx,ny,nz,step
real, dimension(nx,ny,nz), intent(out) :: condensate

! local variables
integer :: fid1,varid1,ierr
real, dimension(:,:,:,:), allocatable :: q

condensate=0.

if (trim(model)=='VVM') then
  write(*,*) "read VVM data at step:",step
  
  allocate(q(nx,ny,nz,2))

  ierr = nf90_open(fname,NF90_NOWRITE,fid1)
  IF (ierr/=nf90_noerr) WRITE(*,*) "open fail"
  ierr = nf90_inq_varid(fid1,"qc",varid1)
  IF (ierr/=nf90_noerr) WRITE(*,*) "var_inq fail qc"
  ierr = nf90_get_var(fid1,varid1,q(:,:,:,1),start=(/ 1,1,1,step /),count=(/ nx,ny,nz,1 /))
  IF (ierr/=nf90_noerr) WRITE(*,*) "read fail"
  ierr = nf90_inq_varid(fid1,"qi",varid1)
  IF (ierr/=nf90_noerr) WRITE(*,*) "var_inq fail qi"
  ierr = nf90_get_var(fid1,varid1,q(:,:,:,2),start=(/ 1,1,1,step /),count=(/ nx,ny,nz,1 /))
  IF (ierr/=nf90_noerr) WRITE(*,*) "read fail"
  ierr = nf90_close(fid1)
  IF (ierr/=nf90_noerr) WRITE(*,*) "close fail"


elseif (trim(model)=="SCALE") then
  write(*,*) "read SCALE data at step:",step

  allocate(q(nx,ny,nz,2))




elseif (trim(model)=="CM1") then
  write(*,*) "read CM1 data at step:",step

  allocate(q(nx,ny,nz,2))



else 
  write(*,*) "The model name does not exist.", trim(model)

  allocate(q(1,1,1,1))
endif



deallocate(q)

end subroutine read_data


end module read_cloud
