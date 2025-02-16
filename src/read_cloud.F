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
integer :: idum1,idum2
real, dimension(:,:,:,:), allocatable :: q


if (trim(model)=='VVM') then
  write(*,*) "read VVM data at step:",step
  
  allocate(q(nx,ny,nz,2))

  ierr = nf90_open(trim(fname),NF90_NOWRITE,fid1)
  IF (ierr/=nf90_noerr) WRITE(*,*) "open fail"
  ierr = nf90_inq_varid(fid1,"qc",varid1)
  IF (ierr/=nf90_noerr) WRITE(*,*) "var_inq fail qc"
  ierr = nf90_get_var(fid1,varid1,q(:,:,:,1),start=(/ 1,1,1,1 /),count=(/ nx,ny,nz,1 /))
  IF (ierr/=nf90_noerr) WRITE(*,*) "read fail"
  ierr = nf90_inq_varid(fid1,"qi",varid1)
  IF (ierr/=nf90_noerr) WRITE(*,*) "var_inq fail qi"
  ierr = nf90_get_var(fid1,varid1,q(:,:,:,2),start=(/ 1,1,1,1 /),count=(/ nx,ny,nz,1 /))
  IF (ierr/=nf90_noerr) WRITE(*,*) "read fail"
  ierr = nf90_close(fid1)
  IF (ierr/=nf90_noerr) WRITE(*,*) "close fail"


elseif (trim(model)=="SCALE") then
  write(*,*) "read SCALE data at step:",step

  allocate(q(nx,ny,nz,4))

  ierr = nf90_open(trim(fname),NF90_NOWRITE,fid1)
  IF (ierr/=nf90_noerr) WRITE(*,*) "open fail"
  ierr = nf90_inq_varid(fid1,"QC",varid1)
  IF (ierr/=nf90_noerr) WRITE(*,*) "var_inq fail"
  ierr = nf90_get_var(fid1,varid1,q(:,:,2:nz,1),start=(/ 1,1,1,step /),count=(/ nx,ny,nz-1,1 /))
  IF (ierr/=nf90_noerr) WRITE(*,*) "read fail"
  ierr = nf90_inq_varid(fid1,"QI",varid1)
  IF (ierr/=nf90_noerr) WRITE(*,*) "var_inq fail"
  ierr = nf90_get_var(fid1,varid1,q(:,:,2:nz,1),start=(/ 1,1,1,step /),count=(/ nx,ny,nz-1,1 /))
  IF (ierr/=nf90_noerr) WRITE(*,*) "read fail"
  ierr = nf90_inq_varid(fid1,"QS",varid1)
  IF (ierr/=nf90_noerr) WRITE(*,*) "var_inq fail"
  ierr = nf90_get_var(fid1,varid1,q(:,:,2:nz,1),start=(/ 1,1,1,step /),count=(/ nx,ny,nz-1,1 /))
  IF (ierr/=nf90_noerr) WRITE(*,*) "read fail"
  ierr = nf90_inq_varid(fid1,"QG",varid1)
  IF (ierr/=nf90_noerr) WRITE(*,*) "var_inq fail"
  ierr = nf90_get_var(fid1,varid1,q(:,:,2:nz,1),start=(/ 1,1,1,step /),count=(/ nx,ny,nz-1,1 /))
  IF (ierr/=nf90_noerr) WRITE(*,*) "read fail"
  ierr = nf90_close(fid1)
  IF (ierr/=nf90_noerr) WRITE(*,*) "close fail"


elseif (trim(model)=="CM1") then
  write(*,*) "read CM1 data at step:",step

  allocate(q(nx,ny,nz,4))
  
  fid1=10
  open(fid1,file=trim(fname),access="direct",recl=nx*ny*4)
  
  do idum2=1,nz
    ! qc
    idum1=33+5*nz ! 33 2D and 5 3D fields
    read(fid1,rec=idum1+idum2) q(:,:,idum2,1)

    ! qi 
    idum1=33+7*nz ! 33 2D and 7 3D fields
    read(fid1,rec=idum1+idum2) q(:,:,idum2,2)

    ! qs 
    idum1=33+8*nz ! 33 2D and 8 3D fields
    read(fid1,rec=idum1+idum2) q(:,:,idum2,3)

    ! qg 
    idum1=33+9*nz ! 33 2D and 9 3D fields
    read(fid1,rec=idum1+idum2) q(:,:,idum2,4)
  enddo

  close(fid1) 
  

else 
  write(*,*) "The model name does not exist.", trim(model)

  allocate(q(1,1,1,1))
endif

condensate=sum(q,4)

deallocate(q)

end subroutine read_data


end module read_cloud
