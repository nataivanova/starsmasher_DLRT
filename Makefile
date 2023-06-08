# if you want to use gfortran, keep these next two lines and comment out the other FC and LDFLAG lines further below
FC = mpif90 -ffixed-line-length-132 
LDFLAGS = 

LD = "/vega/astro/users/ag3293/anaconda/bin/mpif90"
#use this for if ifort maped to mpif90
#FC = mpif90 -132

MPIPATH = "/vega/astro/users/ag3293/anaconda/"
##########FCFLAGS = -cpp -ffixed-line-length-132  -I$(MPIPATH)/include #-mcmodel=large
#use this if mpif90 is not ifort ... or comment these next two lines out if you don't have ifort
#FC = ifort -132 -I$(MPIPATH)/include
#LDFLAGS = -lifcore -lsvml -lifport -limf

CUDAPATH = /cm/shared/apps/cuda80/toolkit/8.0.44/

OLEVEL = -O4 #-g 
FFLAGS = $(OLEVEL)
CFLAGS = $(OLEVEL)
CXXFLAGS = $(OLEVEL)
GRAVLIB = SPHgrav_lib           # use this one for the direct force
#GRAVLIB = SPHgravtree_lib       # use this one for the  tree  force
LIBS =  -lm -lstdc++ #-L$(GRAVLIB) -lSPHgrav -L$(CUDAPATH)/lib64 -lcudart

FOBJS = kdtree2.o advance.o balAV3.o \
        getderivs.o getTemperature.o \
        initialize_hyperbolic.o init.o kernels.o \
        main.o output.o pressure.o\
        ran1.o spline.o splint.o\
        initialize_polyes.o initialize_polymces.o\
        initialize_corotating.o relax.o zeroin.o resplintmu.o grav.o initialize_triple.o temperaturefunction.o initialize_bps.o initialize_bpbh.o calccom.o elements.o initialize_smbh.o initialize_parent.o initialize_hyperbolic_binary_single.o skipahead.o compbest3.o changetf.o tstep.o initialize_grsph.o eatem.o useeostable.o hunt.o usekappatable.o initialize_asciiimage.o
#  grav.o 
CPUOBJS = $(FOBJS) cpu_grav.o
GPUOBJS = $(FOBJS) gpu_grav.o
%.o: %.f starsmasher.h
	$(FC) -c $(FFLAGS) $<
%.o :: %.f90 starsmasher.h
	$(FC) -c $(FFLAGS) $<
#%.o: %.c starsmasher.h
#	$(CC) -c $(CFLAGS) $<

GPUEXEC = test_gpu_sph
CPUEXEC = test_cpu_sph

gpu: $(GPUOBJS)
	make -f Makefile -C $(GRAVLIB)
	$(LD) -o $(GPUEXEC) $(LDFLAGS) $(GPUOBJS) $(LIBS) -L$(GRAVLIB) -lSPHgrav -L$(CUDAPATH)/lib64 -lcudart -L/cm/shared/apps/openmpi/open64/64/1.10.1/lib64/ -lmpi_mpifh
	mv $(GPUEXEC) ..
	echo ***MADE VERSION THAT USES GPUS***

cpu: $(CPUOBJS)
	$(LD) -o $(CPUEXEC) $(LDFLAGS) $(CPUOBJS) $(LIBS) 
	mv $(CPUEXEC) ..
	echo ***MADE VERSION THAT DOES NOT NEED GPUS***

clean:  
	/bin/rm -rf *o *__*.f90 *_*.mod ../*_sph
	make clean -C $(GRAVLIB)
