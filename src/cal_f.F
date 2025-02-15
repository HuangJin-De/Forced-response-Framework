program cal_f
implicit none

integer, parameter :: nt=2399
integer :: i,j,k,m,n,o,t,access
real :: dum1,dum2,dum3
real, dimension(3,5,nt) :: odata
character(300) :: path,fname,model,run
character listmodel(3)*10

path="/data/der0318/FF/data/"
listmodel=(/"CM1","SCALE","VVM"/)

do i=1,3
  do j=1,5
    write(fname,242) trim(path),trim(listmodel(i)),"_en",j,".dat"
    242 format(3A,I1,A)
    !write(*,*) trim(fname), access(trim(fname),' ')

    open(10,file=trim(fname),access="direct",recl=4)
    do t=1,nt
      read(10,rec=t) odata(i,j,t)
    enddo 
    close(10)
  enddo
enddo


where(odata<0.) odata=-1.
odata(3,:,1175:nt)=-1.


open(10,file="../data/sf_data.dat",access="direct",recl=nt*4)
n=1
do i=1,3
do j=1,5
  write(10,rec=n) odata(i,j,:)
  n=n+1
enddo
enddo
close(10)


end program cal_f
