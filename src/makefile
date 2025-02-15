# makefile 
FC = mpiifort
CHECK = -CB -g -traceback -check all,noarg_temp_created -debug all
FCFLAGS = -O3 -free -assume byterecl -mcmodel=large -heap-arrays 10 -shared-intel -fp-model precise -qmkl
ifdef DEBUG
  FCFLAGS += $(CHECK)
endif
ifdef DOUBLE
  FCFLAGS += -r8
endif
FINCLUDE = -I/opt/libs-intel-oneapi/netcdf-4.7.4/include
LDLIBS = -L/opt/libs-intel-oneapi/netcdf-4.7.4/lib -lnetcdff 

# code paths
VPATH = ./

# objects
LIST = cal_obj_pdf.F read_cloud.F
a.out: cal_obj_pdf.o read_cloud.o
cal_obj_pdf.o: cal_obj_pdf.F read_cloud.o
read_cloud.o: read_cloud.F

## objects
#LIST = cal_f.F
#a.out: cal_f.o
#cal_f.o: cal_f.F

LIST_o = $(LIST:.F=.o)
target = a.out 

all: $(target)

$(LIST_o): %.o: %.F
	$(FC) $(FCFLAGS) $(FINCLUDE) -c $<

$(target) : $(LIST_o)
	$(FC) $(FCFLAGS) $(FINCLUDE) $^ -o $@ $(LDLIBS)

clean:
	rm -rf *.o *.mod a.out


