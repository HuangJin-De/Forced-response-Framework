program cal_obj_pdf
use mpi
use read_cloud
implicit none

integer, parameter :: nx=512,ny=128,nz=50,nt=2400
real, parameter :: dx=2000.,dy=2000.
INTEGER :: nproc, myid, ierr
integer, dimension(:), allocatable :: mpi_s, mpi_n
integer :: i,j,k,m,n,o,t, ts,te,tt
integer :: idum1, idum2, step
integer :: access
real :: dum1,dum2,dum3,dum4,dum5
real, dimension(nx,ny,nz) :: qc, vol
character(300) :: path, fname
REAL, DIMENSION(nz+1) :: zz,zc,dz

! count
INTEGER :: cbcri, ctcri
REAL, PARAMETER :: ct=6000., cb=1000.
INTEGER, PARAMETER :: ncri=100
REAL, DIMENSION(ncri+1) :: cri
REAL, DIMENSION(:,:,:,:), allocatable :: cloud_pdf
INTEGER, DIMENSION(:,:,:), allocatable :: cloud_num

call mpi_init(ierr)
call mpi_comm_size(mpi_comm_world,nproc,ierr)
call mpi_comm_rank(mpi_comm_world,myid,ierr)

allocate(mpi_s(nproc),mpi_n(nproc))

idum2=nt/nproc
ts=idum2*myid+1
if (myid<mod(nt,nproc)) then
  ts=ts+myid
  idum2=idum2+1
else
  ts=ts+mod(nt,nproc)
endif
te=ts+idum2-1
idum1=ts

write(*,*) myid, ts, te

call mpi_allgather(idum2,1,mpi_int,mpi_n,1,mpi_int,mpi_comm_world,ierr)
call mpi_allgather(ts,1,mpi_int,mpi_s,1,mpi_int,mpi_comm_world,ierr)

if (myid==0) then
  allocate(cloud_num(5,3,nt),cloud_pdf(ncri,5,3,nt))
else
  allocate(cloud_num(5,3,idum1),cloud_pdf(ncri,5,3,idum1))
endif

call mpi_barrier(mpi_comm_world,ierr)




path="/data/der0318/FF/"


WRITE(fname,111) trim(path),"/FF_data/VVM/","FF_fixed_0p25K_en1","/fort.98"
111 FORMAT(A,A,A,A)
OPEN(10,FILE=fname)
DO i=1,188
  READ(10,*)
ENDDO
DO i=1,nz+1
  READ(10,*) j, zz(i), zc(i)
ENDDO
DO k=2,nz
  dz(k)=zz(k)-zz(k-1)
ENDDO
CLOSE(10)

do k=1,nz
  vol(:,:,k)=dy*dx*dz(k)/(1000*1000*1000) ! km^3
enddo


!initialization
cloud_pdf=0.
DO i=1,ncri+1
  dum1=-1+(i-1)*0.2
  cri(i)=10**dum1
ENDDO
ctcri=nz
cbcri=0
DO k=1,nz
  IF (zc(k)<=cb) cbcri=max(cbcri,k)
  IF (zc(k)>=ct) ctcri=min(ctcri,k)
ENDDO

write(*,*) cbcri, ctcri, zc(cbcri), zc(ctcri)




do t=ts,te
  tt=t-ts+1


  112 format(2A,I1,A,I1,A,I6.6,A)


  do n=1,5
    ! VVM
    write(fname,112) trim(path), "/FF_data/VVM/FF_fixed_0p25K_en", n, &
                     "/archive/FF_fixed_0p25K_en",&
                     n,".L.Thermodynamic-",t,".nc"
    step=t
  
    idum1=access(trim(fname),' ')
    if (idum1/=0) then
      write(*,*) "vvm data file is not found.", t,n
      qc=0.
    else 
      call read_data("VVM",trim(fname),nx,ny,nz,step,qc)
    endif

    call cloud_size_pdf(nx,ny,nz,qc,vol,1.E-5,cbcri,ctcri,ncri,cri,cloud_pdf(:,n,1,tt),cloud_num(n,1,tt))
    


    ! SCALE
    idum1=int(t/24)+1
    idum2=mod(t,24)
    if (idum2==0) then
      idum1=idum1-1
      idum2=24
    endif
    write(fname,112) trim(path), "/FF_data/SCALE/FF_fixed_0p25K_en", n, &
                     "/FF_fixed_0p25K_en", &
                     n,".history-",idum1,".nc"
    step=idum2

    idum1=access(trim(fname),' ')
    if (idum1/=0) then
      write(*,*) "scale data file is not found.", t,n
      qc=0.
    else
      call read_data("SCALE",trim(fname),nx,ny,nz,idum2,qc)
    endif

    call cloud_size_pdf(nx,ny,nz,qc,vol,1.E-5,cbcri,ctcri,ncri,cri,cloud_pdf(:,n,2,tt),cloud_num(n,2,tt))



    ! CM1
    write(fname,112) trim(path), "/FF_data/CM1/FF_fixed_0p25K_en", n, &
                     "/cm", &
                     int(n/n),"out_",t,"_s.dat"
    step=t

    idum1=access(trim(fname),' ')
    if (idum1/=0) then
      write(*,*) "cm1 data file is not found.", t, n
      qc=0.
    else
      call read_data("CM1",trim(fname),nx,ny,nz,step,qc)
    endif

    call cloud_size_pdf(nx,ny,nz,qc,vol,1.E-5,cbcri,ctcri,ncri,cri,cloud_pdf(:,n,3,tt),cloud_num(n,3,tt))



  enddo

enddo


call mpi_barrier(mpi_comm_world,ierr)


if (myid==0) then
  call mpi_gatherv(mpi_in_place,mpi_n(myid+1)*15,mpi_real,cloud_num,mpi_n*15,mpi_s*15,mpi_real,0,mpi_comm_world,ierr)  
  call mpi_gatherv(mpi_in_place,mpi_n(myid+1)*15*ncri,mpi_real,cloud_pdf,mpi_n*15*ncri,mpi_s*15*ncri,mpi_real,0,mpi_comm_world,ierr)  
else
  call mpi_gatherv(cloud_num,mpi_n(myid+1)*15,mpi_real,cloud_num,mpi_n*15,mpi_s*15,mpi_real,0,mpi_comm_world,ierr)
  call mpi_gatherv(cloud_pdf,mpi_n(myid+1)*15*ncri,mpi_real,cloud_pdf,mpi_n*15*ncri,mpi_s*15*ncri,mpi_real,0,mpi_comm_world,ierr)
endif


if (myid==0) then
  open(10,file="../data/VVM_cloud_size_pdf.dat",access="direct",recl=ncri*5*4)
  open(11,file="../data/SCALE_cloud_size_pdf.dat",access="direct",recl=ncri*5*4)
  open(12,file="../data/CM1_cloud_size_pdf.dat",access="direct",recl=ncri*5*4)
  do t=1,nt
    write(10,rec=t) cloud_pdf(:,:,1,t)
    write(11,rec=t) cloud_pdf(:,:,2,t)
    write(12,rec=t) cloud_pdf(:,:,3,t)
  enddo
  close(10)
  close(11)
  close(12)
endif

call mpi_finalize(ierr)


end program cal_obj_pdf




subroutine cloud_size_pdf(nx,ny,nz,qc,vol,criteria,cbcri,ctcri,ncri,cri,cloud_pdf,cloud_num) 
implicit none

! input/output
integer, intent(in) :: nx, ny, nz, ncri
integer, intent(in) :: cbcri, ctcri 
real, intent(in) :: criteria
real, dimension(ncri+1), intent(in) :: cri
real, dimension(nx,ny,nz), intent(in) :: qc, vol
real, dimension(ncri), intent(out) :: cloud_pdf
real, intent(out) :: cloud_num

! local variables
integer :: n, j
real :: dum1,dum2
INTEGER, DIMENSION(nx,ny,nz) :: flag_qc
INTEGER, DIMENSION(nx*ny*nz) :: flagcloud, top, bottom
REAL, DIMENSION(nx*ny*nz) :: sizecloud

call six_connected(nx,ny,nz,qc,vol,criteria,flag_qc,flagcloud,sizecloud,top,bottom)

cloud_pdf=0.
do n=1,nx*ny*nz
  if (flagcloud(n) == -1) goto 987
  if (top(n)>=ctcri .and. bottom(n)<=cbcri) then
    dum1=sizecloud(n)
    do j=1,ncri
      if (dum1>=cri(j) .and. dum1<cri(j+1)) then
        cloud_pdf(j)=cloud_pdf(j) + 1
        goto 848
      endif
    enddo
    848 continue
  endif
enddo
987 continue

cloud_num=sum(cloud_pdf,1)

end subroutine cloud_size_pdf





SUBROUTINE six_connected(nx,ny,nz,data_array,volume_array,criteria &
                        ,cloudflag_array,cloudflag_seq,cloudsize_seq &
                        ,top,bottom)
IMPLICIT NONE

! input
INTEGER, INTENT(in) :: nx, ny, nz
REAL   , INTENT(in) :: criteria     ! criteria for defining objects
REAL   , DIMENSION(nx,ny,nz), INTENT(in) :: data_array ! data array
REAL   , DIMENSION(nx,ny,nz), INTENT(in) :: volume_array ! volume array

! output
INTEGER, DIMENSION(nx,ny,nz), INTENT(inout) :: cloudflag_array ! cloud flag array
INTEGER, DIMENSION(nx*ny*nz), INTENT(inout) :: cloudflag_seq ! cloud flag
REAL   , DIMENSION(nx*ny*nz), INTENT(inout) :: cloudsize_seq ! cloud size
INTEGER, DIMENSION(nx*ny*nz), INTENT(inout) :: top, bottom

! local variables
REAL :: con_size
INTEGER :: ct, cb
INTEGER :: i, j, k
INTEGER :: i_end, j_end, k_end
INTEGER :: nex , ney , nez , myx , myy ,myz
INTEGER :: label, waiting_num, dir
INTEGER, DIMENSION(6), PARAMETER :: &
         move_x_3d(6) =  (/ -1,  0, +1,  0,  0,  0 /), &
         move_y_3d(6) =  (/  0, -1,  0, +1,  0,  0 /), &
         move_z_3d(6) =  (/  0,  0,  0,  0, +1, -1 /)
INTEGER, DIMENSION(3,nx*ny*nz) :: waiting_grid
LOGICAL, DIMENSION(nx,ny,nz) :: search_flag

! initialization
i_end = nx
j_end = ny
k_end = nz

label           = 1
cloudflag_array = -1
cloudflag_seq   = -1
cloudsize_seq   = -1.
search_flag     = .FALSE.


! searching loop
k_loop: DO k=1,k_end
j_loop: DO j=1,j_end
i_loop: DO i=1,i_end

  grid_searched_or_not: IF (.not.(search_flag(i,j,k)))THEN

  search_flag(i,j,k) = .TRUE.
  waiting_num = 1
  con_size    = 0.
  ct          = 1
  cb          = k_end

  waiting_grid(1,waiting_num) = i
  waiting_grid(2,waiting_num) = j
  waiting_grid(3,waiting_num) = k

  searching_loop: DO

    IF (waiting_num < 1) GOTO 888

    myx = waiting_grid(1,waiting_num)
    myy = waiting_grid(2,waiting_num)
    myz = waiting_grid(3,waiting_num)

    waiting_num = waiting_num - 1

    IF (data_array(myx,myy,myz) >= criteria) THEN
      cloudflag_array(myx,myy,myz) = label
      con_size = con_size + 1. * volume_array(myx,myy,myz)
      ct = max(ct,myz)
      cb = min(cb,myz)

      check_neighbor: DO dir=1,6
        nex = myx + move_x_3d(dir)
        ney = myy + move_y_3d(dir)
        nez = myz + move_z_3d(dir)

        IF ( nex==0       ) nex = i_end
        IF ( nex==i_end+1 ) nex = 1
        IF ( ney==0       ) ney = j_end
        IF ( ney==j_end+1 ) ney = 1

        IF ( nex>=1 .AND. nex<=i_end .AND. &
             ney>=1 .AND. ney<=j_end .AND. &
             nez>=1 .AND. nez<=k_end )THEN

          ne_search_or_not: IF (.not.(search_flag(nex,ney,nez)))THEN

            waiting_num = waiting_num +1
            waiting_grid(1,waiting_num) = nex
            waiting_grid(2,waiting_num) = ney
            waiting_grid(3,waiting_num) = nez

            search_flag(nex,ney,nez) = .TRUE.
          ENDIF ne_search_or_not
        ENDIF

      ENDDO check_neighbor

    ENDIF

  ENDDO searching_loop
  888 CONTINUE

  IF (con_size /= 0)THEN
    cloudflag_seq(label) = label
    cloudsize_seq(label) = con_size
    top(label) = ct
    bottom(label) = cb
    label = label + 1
  ENDIF
  ENDIF grid_searched_or_not
ENDDO i_loop
ENDDO j_loop
ENDDO k_loop

END SUBROUTINE six_connected
