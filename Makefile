# ===================================================================
# Makefile 
# This file implements architecture dependent compilation of sources.
# This makefile was completely revised for Version 3.5 (in 2011)
# Checked again on 12 May 2015 (Version 3.6.1)
# Again revised and error corrected on 19 NOV 2022 (Version 3.6.2)
# -------------------------------------------------------------------
# Author: Prof. Dr. rer. nat. habil. Martin O. Steinhauser (2010)
# ===================================================================
 

# ===================================================================
#  Program Suite: MD-CUBE
#  ------------------------------------------------------------------
#  Version Log:
#  				3.5   	(01 APRIL 2010)
#                     	Completely revised makefile
#               3.5.1 	(27 OCT   2012)
#                     	Some major changes and improvements
#				3.6   	(10 NOV 2012)
#                     	Makefile can now read shell environment variables
#                     	such as MACHTYPE - this automates the use of this
#                     	makefile on arbitrary platforms
#				3.6.1	(12 MAY 2015)
#						Checked this Makefile again. Automatic creation of
#						./build amd ~/mybins directories now really works.
#						I couldn't resolve problems with setting 
#						SHOW_ERRORS=false as default. For some reason this
#						makro only works directly on the make command line.
#						The compiler macro PARALLEL=true has to be checked later
#						whether it really works.
#				3.6.2	(19 NOV 2022)
#						Makefile errors introduced by my former students 
#						have been checked and corrected. One thing remaining 
#						is a weired "warning: -lm: 'linker' input unused 
#						[-Wunused-command-line-argument]" from Makefile which 
#						seems to be unavoidable due to the limitations of 'make' 
#						to transform *.d files into *.o files automatically. 
#						So, all in all, except for some minor warnings, 
#						the Makefile now works again.
#  -----------------------------------------------------------
#  Author                : Prof. Dr. rer. nat. habil. Martin O. Steinhauser
#  Copyright (2003-now)  : Prof. Dr. rer. nat. habil. Martin O. Steinhauser
# 
#  Frankfurt University of Applied Science
#  Faculty of Computer Science and Engineering
#  Building 8, Room #115
#  Nibelungenplatz 1
#  D-60318 Frankfurt am Main
#  https://www.frankfurt-university.de/steinhauser
#  E-Mail: martin.steinhauser@fb2.fra-uas.de
#  https.//www.researchgate.net/profile/Martin-Steinhauser
# ============================================================


# =================================================================
# SECTION 1: PRELIMINARY PREPARATIONS
# =================================================================
#            Here, some default variables are set
# -----------------------------------------------------------------


# ==============================================================================
# DEFAULT VALUES FOR VARIABLES
# ---------------------------- TECHNICAL VARIABLES
DEBUGGING = false			# different levels are available
PROFILING = false			# switches on the -g option
EFENCE    = false			# for memory leak checking, not used anymore
RM        = rm -fr 			# standard command
CC        = gcc             # usually, gcc is available on all systems
SED       = sed     		# tool for maipulating data
#VERSION   = 3.6.1			# As of 12 MAY 2015
VERSION	  = 3.6.2			# As of 10 NOV 2022
SHELL     = /bin/bash

# the default files for storing all make warnings or errors        
ERRORFILE_MAIN     = .logfileErrorsMain
ERRORFILE_GRAPHICS = .logfileErrorsGraphics
ERRORFILE_ANALYZE  = .logfileErrorsAnalyze

# ------------------------- SIMULATION TYPES FOR SIMTYPE=Polymer
TYPE      = single          # Only for SIMTYPE=Polymer
#TYPE      = melt			# Only for SIMTYPE=Polymer

# ---------------- Options that have been introduced by my diploma student J. Schneider
# Not used anymore (will check and introduce again some time in the future)
CHAINS    = flex            
SPRING    = fene
SAVEDATA  = on
VOLUME    = on
THERMO    = off

# ---------------- Options that have been introduced by my diploma student T. Schindler
BOUNDARY  = periodic		# The other possibilities are 'reflectingz' and 'reflectingall'
# BOUNDARY = reflectingz
# BOUNDARY = reflectingall
# ------------------------------------------------------------------------------


# ---------------- Show ALL warnings and errors per default !
THROW=true
#THROW=false	# in this case, all warning are written to hidden logfiles



# ==============================================================================
# BINARIES OF THE PROGRAM SUITE
# -----------------------------

BINARY  := MD-CUBE				 	# The binary name of the main program
BINARY1 := MD-CUBE.Graphics			# Analyze program for grafical display of data
BINARY2 := MD-CUBE.AnalyzeData   	# Analyze program for analytical calculations from data

# ------------------------------------------------------------------------------


# ==============================================================================
# PROGRAM SIMTYPEs				
#-------------------------- DEFAULT SIMTYPE
#SIMTYPE := Impact
 SIMTYPE := Polymer
# ------------------------------------------------------------------------------


DOXYVERSION = $(shell doxygen --version)
#MAKEDOC = $(shell doxygen Doxyfile)
MAKEDOC := (doxygen Doxyfile)

# ==============================================================================
# LIBRARIES
#-------------------------- Math Library always has to be included
LIBS = -lm
# ------------------------------------------------------------------------------


# ==============================================================================
# ASSIGN PLATFORM VARIABLES
# ------------------------------------------------------------------------------
# Some of the system variables are only local bash shell variables, such
# as MACHTYPE, or OSTYPE, and as such they are not recognized by make on some 
# systems. Make only recognizes 'true' environment variables; by they way, also 
# something like "export MACHTYPE" won't help. Here, I use the trick with 
# doubling the $-sign. Then the variables are recognized correctly!
# ------------------------------------------------------------------------------
SHELL    := $(shell cut -d- -f1 <<< $$SHELL)
PLAT     := $(shell cut -d- -f1 <<< $$OSTYPE)
MACHINE  := $(shell cut -d- -f1 <<< $$MACHTYPE)
NODENAME := $(shell cut -d- -f1 <<< $$HOSTNAME)
HOST     := $(shell cut -d- -f1 <<< $$HOST)
HTYPE    := $(shell cut -d- -f1 <<< $$HOSTTYPE)
MAKE     := $(shell (which make))


# ==============================================================================
# PRINT KEY SYSTEM VARIABLES - THIS IS VERY USEFUL RIGHT HERE IN CASE SOMETHING
# IS MESSED UP IN THE MAKEFILE IN THE FUTURE
# ------------------------------------------------------------------------------
check:
	@echo
	@echo "==============================================================="
	@echo "YOUR SYSTEM CONFIGURATION IS:"
	@sleep 0.5
	@echo ------------------------
	@echo "PLATFORM 	is.....$(PLAT)"
	@echo "HOST     	is.....$(HOST)"
	@echo "NODENAME 	is.....$(NODENAME)"
	@echo "MACHINE  	is.....$(MACHINE)"
	@echo "TYPE     	is.....$(HTYPE)"
	@echo "USER     	is.....$(USER)"
	@echo "COMPILER 	is.....$(CC)"
	@echo "LIBS     	is.....$(LIBS)"
	@echo "OPTIONS  	is.....$(OPTIONS)"
	@echo "CFLAGS   	is.....$(CFLAGS)"
	@echo -------------------------------------
	@echo "THROW WARNINGS	is.....$(THROW)"
	@echo "==============================================================="
	@sleep 4.0
	@echo
# ------------------------------------------------------------------------------


# ------------------------
# Check, if some of the environment variables are not set - in this case, do not
# fuss around, but simply print an appropriate message, except for MACHTYPE.
# MACHTYPE is used in Section 3 for distinguishing variable settings for different
# operating systems - hence, this variable MUST BE SET. If it is not set, a 
# standard linux 64 bit system is assumed by assigning this value within make.
ifeq ($(PLAT) ,)
PLAT := "NOT SET on this system"
endif

ifeq ($(NODENAME) ,)
NODENAME := "NOT SET on this system"
endif

ifeq ($(HOST) ,)
HOST := "NOT SET on this system"
endif

ifeq ($(HTYPE) ,)
HTYPE := "NOT SET on this system"
endif

ifeq ($(MACHINE) , )
$(warning ------------------------------------------------------------------)
$(warning WARNING: Shell Variable MACHTYPE is not set on this system!)
$(warning WARNING: Assuming a standard 64 bit Linux system and continuing...)
MACHINE := x86_64
$(warning ------------------------------------------------------------------)
endif
$(shell sleep 2)

# ------------------------------------------------------------------------------



# ==============================================================================
# DIRECTORY PATHS 
# ---------------
MAKEDIR   := $(shell pwd)
# REMARK: pwd does not work if there are blanks within the directory path;
# When this is the case, use '.' instead to mark the current directory
# MAKEDIR   := .
DOCDIR    := $(MAKEDIR)/doc/
BINDIR    := $(HOME)/mybins
# REMARK: The BINDIR directory is automatically created if not existing
# ------------------------------------------------------------------------------


# ==============================================================================
# SUPPORTED PLATFORMS/OPERATING SYSTEMS (OSTYPE)
#-----------------------------------------------
PLATFORMS := i686 (Standard Linux) / OSF5.1 (HP Workstations) / unicosmk (Cray)\
 / AIX (SP6000) / cygwin (Windows) / x86-64-linux-gnu (64 bit Standard Linux) \
 / x86-64-suse-linux (64 bit Suse Linux) / MacOS (darwin22.0)
# ------------------------------------------------------------------------------




# ==============================================================================
# SECTION 2: GENERAL CODE SYMBOL DEFINITIONS
# ========== -------------------------------------------------------------------
#            Here, '#ifdef' commands in the main code are transferred to the
#            compiler with option -D
# ------------------------------------------------------------------------------


# ==============================================================================
# SYMBOLIC DEFINITIONS, concerning the POLYMER version of MD-Cube
symdef0  :=_POLYMER
symdef1  :=_NEW_FORCE
symdef2  :=_MAKE_STATISTICS
symdef3  :=_SWITCH_ON_PIVOT                 # --> Additional MC Pivot moves for equilibrating polymers
symdef4  :=_SWITCH_ON_SINGLE_CHAIN_MODE     # --> The inter-chain interactions are switched OFF
symdef5  :=_FORCECALC_WITH_CELLS            # --> Simple cell lists without additional skin and without ghosts
symdef6  :=_USE_GHOSTS                      # --> The most efficient force calculation
symdef7  :=_NO_RANDOM                       # --> The random seed is always the same, i.e. the "random" numbers are not random anymore
symdef8  :=_USE_MPI_PARALLEL                # --> Use the parallel version of MD-Cube
symdef9  :=_USE_DEBUGGING_LEVEL1            # --> Basic Debug output
symdef10 :=_USE_DEBUGGING_LEVEL2            # --> Debug details on data structures
symdef11 :=_USE_DEBUGGING_LEVEL3            # --> Debug details on parallel implementation

# New symbols for the non-equilibrium POLYMER simulations
symdef12 :=_STIFF_LINEAR_CHAINS             # --> Stiff linear chains only  
symdef13 :=_PERIODIC_SHEAR                  # --> Periodic shear of the surrounding solvent
symdef14 :=_FRAENKEL_SPRING                 # --> Parabolic Fraenkel-springs between particles
symdef15 :=_SHEAR_FLOW                      # --> Shear flow with constant shear rate
symdef16 :=_MACRO_SHEAR                     # --> Enable special periodic boundary conditions for shear simulations
symdef17 :=_NO_DATA                         # --> Disable saving sata to disk (for very Large Simulations)
symdef18 :=_PB_THERMOSTAT                   # --> Profile biased thermostat for NEMD simulations
# ------------------------------------------ FURTHER SYMBOLIC DEFINITIONS
symdef19 :=_N2_CALC						 	 # --> Inefficient N^2 force calculation
symdef20 :=_REFLECTING_Z					 # --> Reflecting boundary conditions in z-direction
symdef21 :=_REFLECTING_ALL					 # --> Reflecting boundary conditions in all directions
symdef22 :=_VTK								 # --> Output of .vtk files and explicit use of bonds

# Symbols for impact scenario
symdef23 :=_IMPACT	
# ------------------------------------------------------------------------------



# ==============================================================================
# THROW AN ERROR IF SIMTYPE IS NOT 'polymer'
#----------------------------SIMTYPE with polymer connectivities
ifneq ($(SIMTYPE), Polymer)
ifneq ($(SIMTYPE), Impact)
$(error ---> You have provided a SIMTYPE, which cannot be processed.)
$(error ---> Please, use 'Polymer' or 'Impact' by typing: "SIMTYPE =  ")
endif
endif
# ------------------------------------------------------------------------------


# ==============================================================================
# SIMTYPE 
#----------------------------SIMTYPE with polymer connectivities
ifeq ($(SIMTYPE) , Polymer)
SIMPOLYMER = "Polymer"
BINARY     := MD-CUBE.Polymer
SYMDEFS    = -D$(symdef0)

# DIFFERENT TYPES OF SEARCHLOOPS FOR THE FORCES (FOR TESTING PURPOSES)
#----------------------------SEARCHLOOP with cells and neighbor lists only (no ghosts) --> performance tests
	ifeq  ($(SEARCHLOOP),lists) 
		SYMDEFS  += -D$(symdef1)
		BINARY  := $(BINARY).NeighborListSearch
	else
#----------------------------SEARCHLOOP with cells only (no neighbor lists and no ghosts) --> performance tests
		ifeq ($(SEARCHLOOP),cells)
			SYMDEFS  += -D$(symdef5)
			BINARY   := $(BINARY).CellSearch
			
#----------------------------SEARCHLOOP without cells, i.e. N^2 searchloop. This is quite inefficient --> performance tests
		else
			ifeq ($(SEARCHLOOP),n2calc)
			SYMDEFS += -D$(symdef19)
			BINARY	:= $(BINARY).N2
	
#----------------------------DEFAULT SEARCHLOOP with cells, neighbors and ghosts 
#                        --> maximum performance with periodicity
			else
				SYMDEFS  += -D$(symdef1) -D$(symdef6)
			endif
		endif
	endif

endif


#----------------------------SIMTYPE for High Velocity Impact
ifeq ($(SIMTYPE) , Impact)
BINARY     := MD-CUBE.Impact
SYMDEFS  = -D$(symdef23) -D$(symdef1)
endif


# ------------------------------------------------------------------------------


# ==============================================================================
# TYPE 
#----------------------------TYPE switches on/off inter-chain interaction 
ifdef SIMPOLYMER
ifeq ($(TYPE),melt)
ifeq ($(RENAME), true)
	BINARY := $(BINARY).Melt
endif
else	
	ifeq ($(TYPE),single)
# (simulate single chains as default)
		SYMDEFS  += -D$(symdef4)
		BINARY :=$(BINARY)
	endif
endif
endif
# ------------------------------------------------------------------------------


# ==============================================================================
# BOUNDARY 
#----------------------------BOUNDARY changes boundary conditions. (So far only for the N^2 routine.)
# Possible boundary conditions: periodic, reflecting only in z-direction, reflecting in all directions.
ifneq ($(BOUNDARY),periodic)
# (periodic boundary conditions as default)
	ifeq ($(BOUNDARY),reflectingz)
		SYMDEFS += -D$(symdef20)
	else
		ifeq ($(BOUNDARY),reflectingall)
			SYMDEFS += -D$(symdef20)
			SYMDEFS += -D$(symdef21)
		endif
	endif
endif
# ------------------------------------------------------------------------------


# ==============================================================================
# MODE 
#----------------------------MODE switches on the pivot Monte Carlo module in 
# addition to the MD simulation for fast chain equilibration
ifeq ($(MODE),pivot)
symdef3 :=_SWITCH_ON_PIVOT
SYMDEFS  += -D$(symdef3)
endif
# ------------------------------------------------------------------------------


# ==============================================================================
# PIVOT
#----------------------------PIVOT check the pivot routine by producing pivot statistics output
ifeq ($(PIVOT),statistics)
	ifneq ($(MODE),pivot)
	ERROR = "!***** To use Pivot statistics you have to use the option 'MODE=pivot'"
	else
		symdef2 :=_MAKE_STATISTICS
		SYMDEFS  += -D$(symdef2) 
	endif	
endif
#-------------------------------------------------------------------------------



# =================================================================
# SECTION 3: COMPILER FLAGS; DEPENDING ON PLATFORM
# ========== -------------------------------------
# The UNIX and Linux system variable 'MACHTYPE' is used to identifiy different 
# platforms which are decribed in this SECTION 3. However, macOS is detected 
# directly using 'OSTYPE'. For some reason however, on some systems, make does not seem 
# to be able to read this variable properly, so occasionally it fails on some systems - 
# What always seems to work is using the HOSTNAME (if it is set e.g. in .bashrc).
# Therefore, when transfering the code to a new architecture, 
# it might be necessary to include a new if-statement including the new
# HOSTNAME of the system. BUT ONLY do this when MACHTYPE really fails!
# -----------------------------------------------------------------



# ===============================================
# General 64 bit systems (either Mac OS or Linux)
# -----------------------------------------------
ifeq ($(PLAT), darwin22)
CC		= gcc
endif
# Compiler flags for MAC OS X
CFLAGS = -Wall -pedantic  -ffast-math -funroll-loops\
  -D_INLINE_INTRINSICS -D_FASTMATH $(INCDIRS) $(SYMDEFS) 	# important: remove the -O2 flag
INSTDIR = $(BINDIR)/macOS
LIBS   := $(LIBS)

# ------------------------------------------------------------------------------



# =================================
# Standard Suse Linux 64 bit system
# ---------------------------------
ifeq ($(MACHINE), x86_64-suse-linux)
  MACHINE := 64bit Suse Linux System
  LIBS    = -lm
  CC      = gcc                     						# remark: Do not use g++
  CFLAGS  = -Wall -pedantic -finline-functions -ffast-math -funroll-loops\
  -D_INLINE_INTRINSICS -D_FASTMATH -march=native -O2 $(INCDIRS) $(SYMDEFS)     
  INSTDIR = $(BINDIR)/linux
endif
# ------------------------------------------------------------------------------

# ==========================================
# Cygwin (POSIX based system) on Windows PCs
# ------------------------------------------
ifeq ($(MACHINE), i686-pc-cygwin)
  CC      = gcc

MACHINE := x86_64
  CFLAGS  = -Wall -pedantic -funroll-loops -O3 $(SYMDEFS)
  INSTDIR = $(BINDIR)/cygwin
    ifeq ($(LAPACK), true)
      ifeq ($(NODENAME), Pcsteinhauser1)
        LIBS   = -L /cygdrive/c/Dokumente\ und\ Einstellungen/steinhauser/CygHome/Installations/ATLAS/lib/WinNT_P4SSE2 -llapack -lcblas -latlas -lg2c -lgmp
      endif       
      ifeq ($(NODENAME), lapsteinhauser1)
        LIBS   = -L /cygdrive/d/CygWin/CygHome/Installations/ATLAS/lib/WinNT_P3SSE2 -llapack -lcblas -latlas -lg2c -lgmp
      endif
      ifeq ($(NODENAME), gandalf)
        LIBS   = -L /cygdrive/d/CygWin/CygHome/Installations/ATLAS/lib/WinNT_P3SSE2 -llapack -lcblas -latlas -lg2c -lgmp
      endif
    endif
endif
# ------------------------------------------------------------------------------

# ==========================================
# Cygwin (POSIX based system) on Windows PCs
# ------------------------------------------
#Used by Erkai Watson on LAPSACE4
ifeq ($(MACHINE), p686)
  CC      = gcc

MACHINE := x86_64
  CFLAGS  = -Wall -pedantic -funroll-loops -O3 $(SYMDEFS)
  INSTDIR = $(BINDIR)/cygwin
  LIBS   := $(LIBS)
endif
# ------------------------------------------------------------------------------


# =============================================
# Redhat Linux 64 bit system on the EMI Cluster
# ---------------------------------------------
ifeq ($(HOSTNAME), i3)			# As an exception ,this system uses HOSTNAME, not MACHTYPE
CC      = gcc
CFLAGS = -Wall -pedantic  -O2 -D_INLINE_INTRINSICS $(SYMDEFS)
INSTDIR = $(BINDIR)/cluster
LIBS   := $(LIBS)
endif

# =============================================
# Redhat Linux 64 bit system on the EMI Cluster
# ---------------------------------------------
ifeq ($(HOSTNAME), i4)			# As an exception ,this system uses HOSTNAME, not MACHTYPE
CC      = gcc
CFLAGS = -Wall -pedantic -O2 -D_INLINE_INTRINSICS $(SYMDEFS)
INSTDIR = $(BINDIR)/cluster
LIBS   := $(LIBS)
endif


# ========================================
# General Redhat Linux 64 bit  system 
# ----------------------------------------
ifeq ($(MACHINE), x86_64-redhat-linux-gnu)
CC      = gcc
CFLAGS = -Wall -pedantic  -O2 -D_INLINE_INTRINSICS $(SYMDEFS)
INSTDIR = $(BINDIR)/cluster
LIBS   := $(LIBS)

ifdef PARALLEL
   CC      = mpicc	
endif


# --------------------------------
# SPECIAL LIBRARIES on the cluster
# When I need to include special or own compiled libraries, it is done here
# -------------------------------------------------------------------------
# Use my own compiled libraries
   ifeq ($(MYLIB),true)
       LIBS   =  -lm -L /home/steinhau/lib/ -llapack -lcblas -latlas -lgmp -lg2c

# Use the system lbraries (if available on the 64-bit cluster)
# ------------------------------------------------------------
#   else
#     LIBS   = -lm -llapack -lblas -lgmp -L /usr/lib/gcc/x86_64-redhat-linux/3.4.6 -lg2c 
   endif
endif
# ------------------------------------------------------------------------------


# ==========================
# Standard 32 bit Suse Linux 
# --------------------------
ifeq ($(MACHINE) , i686-suse-linux)
CC = gcc
CFLAGS = -Wall -pedantic -Wmissing-prototypes -Wnested-externs \
 -finline-functions -ffast-math -fcaller-saves -funroll-loops\
 -D_INLINE_INTRINSICS -D_FASTMATH  -march=i686 -O2 $(SYMDEFS) $(INCDIRS)
BINDIR := $(BINDIR)/linux32
INSTDIR = $(BINDIR)
endif
# ------------------------------------------------------------------------------


# =====================
#  HP-UNIX Workstations 
# ---------------------
ifeq ($(PLAT) , alphaev6-dec-osf5.1)
  CC      = cc
  CFLAGS  = -pedantic -finline-functions -ffast-math -fstrength-reduce -fcaller-saves -funroll-loops\
  -fschedule-insns -arch host -D_INLINE_INTRINSICS -D_FASTMATH -inline all -fast -O2\
  $(SYMDEFS)
  INSTDIR = $(BINDIR)/osf5.1
endif
#-------------------------------------------------------------------------------


# =======================
#  DEC ALPHA Workstations
# -----------------------
ifeq ($(PLAT) , AIX)
  CC      = cc
  CFLAGS  = -pedantic -finline-functions -ffast-math -fstrength-reduce -fcaller-saves\
  -funroll-loops -fschedule-insns  -D_INLINE_INTRINSICS -D_INTRINSICS -O2 \
  $(INCDIRS) $(SYMDEFS) 
  INSTDIR = $(BINDIR)/aix
  LIBS   += -lstdc++ 
endif
#-------------------------------------------------------------------------------


# ======================
#  Cray T3e Architecture
# ----------------------
ifeq ($(PLAT) , unicosmk)
  CC      = cc
  CFLAGS  = -Wall -pedantic -O3 $(INCDIRS) $(SYMDEFS) 
  INSTDIR = $(BINDIR)/cray
  LIBS   += -lstdc++ -pthread -lrt
endif
#-------------------------------------------------------------------------------




# ==============================================================================
# SECTION 4: SYMDEFS, concerning stiff chains and non-equilibrium simulations
# ========== -------------------------------------------------------------------

# ===============================================================
# STIFF CHAINS	
# ---------------------------
ifeq ($(CHAINS),stiff)
symdef12 :=_STIFF_LINEAR_CHAINS
#symdef14 :=_FRAENKEL_SPRING
SYMDEFS   += -D$(symdef12)
#SYMDEFS   += -D$(symdef14)
BINARY    := $(BINARY).Stiff
endif
#---------------------------

# ===============================================================
# PERIODIC SHEAR	
# ---------------------------
ifeq ($(SHEAR),periodic)
symdef13 :=_PERIODIC_SHEAR
symdef16 :=_MACRO_SHEAR
SYMDEFS   += -D$(symdef13)
SYMDEFS   += -D$(symdef16)
BINARY    := $(BINARY).periodicShear
endif
#---------------------------

# ===============================================================
# STATIC SHEAR FLOW
# ---------------------------
ifeq ($(SHEAR),static)
symdef15 :=_SHEAR_FLOW
symdef16 :=_MACRO_SHEAR
SYMDEFS   += -D$(symdef15)
SYMDEFS   += -D$(symdef16)
BINARY    := $(BINARY).ShearFlow
endif
#---------------------------

# ===============================================================
# STEP SHEAR 
# ---------------------------
ifeq ($(SHEAR),step)
symdef15 :=_STEP_SHEAR
symdef16 :=_MACRO_SHEAR
SYMDEFS   += -D$(symdef15)
SYMDEFS   += -D$(symdef16)
BINARY    := $(BINARY).StepShear
endif
#---------------------------

# ===============================================================
# PARABOLIC SPRINGS	
# ---------------------------
ifeq ($(SPRING),parabolic)
symdef14 :=_FRAENKEL_SPRING
SYMDEFS   += -D$(symdef14)
BINARY    := $(BINARY).Fraenkel
endif
#---------------------------




# =============================================================
# SECTION 5: Just GENERAL profile/debug/miscelleaneous options
# ========== --------------------------------------------------

# ==============================================================================
# VTK OUTPUT		--> only works with GHOSTS; Partly disabled for step_shear-functions (see respective function calls)
# ----------
ifeq ($(VTK),true)
		ifeq  ($(SEARCHLOOP),lists) 
			ERROR = "!***** VTK-option is not available with option 'SEARCHLOOP=lists'. Ghosts must be used!"
		else 
			ifeq ($(SEARCHLOOP),cells)
				ERROR = "!***** VTK-option is not available with option 'SEARCHLOOP=cells'. Ghosts must be used!"
			else
				symdef19 :=_VTK
				SYMDEFS   += -D$(symdef22)
			endif
		endif
endif
# ------------------------------------------------------------------------------


# ==============================================================================
# PROFILE BIASED THERMOSTAT
# -------------------------
ifeq ($(THERMOSTAT),pbt)
symdef18 :=_PB_THERMOSTAT
SYMDEFS   += -D$(symdef18)
BINARY    := $(BINARY).PBT
endif
# ------------------------------------------------------------------------------


# ==============================================================================
# NORANDOM                               --> constant random seed
# --------
ifeq ($(NORANDOM),true)
symdef7 :=_NO_RANDOM_NUMBERS
SYMDEFS   += -D$(symdef7)
BINARY    := $(BINARY)_NO_RANDOM
endif
# ------------------------------------------------------------------------------


# ==============================================================================
# NO DATA SAVING [ONLY MD-Cube.GM]
#---------------------------------
ifeq ($(SAVEDATA),off)
symdef17 :=_NO_DATA
SYMDEFS   += -D$(symdef17)
BINARY    := $(BINARY).NoData
endif
# ------------------------------------------------------------------------------


# ==============================================================================
# PROFILING                              --> Compile with profiling information
# ---------
ifeq ($(PROFILING),true)
  OPTIONS += -pg -fprofile-arcs -ftest-coverage
  CFLAGS  += -Wall -pedantic 
  LIBS += -lgcov
  BINARY  := $(BINARY)_PROFILING
endif
# ------------------------------------------------------------------------------


# ==============================================================================
# MEMORY_CHECK                          --> Memory Checks
# ------------
ifeq ($(EFENCE),true)
  ifeq ($(MACHINE),linux-gnu)
    LIBS    += -L /home/steinhau/lib/c1 -lefence
  else
    LIBS    += -lefence
  endif
OPTIONS += -g
CFLAGS  += -O0
BINARY  := $(BINARY)_EFENCE
endif
# ------------------------------------------------------------------------------


# ==============================================================================
# MEMORY_CHECK                         --> Performance tests
# ------------
ifeq ($(MPATROL),true)
LIBS    += -lmpatrol -lbfd -liberty
OPTIONS += -g
CFLAGS  = -include /usr/include/mpatrol.h -Wall -pedantic -O0
BINARY  := $(BINARY)_MPATROL
endif
# ------------------------------------------------------------------------------


# ==============================================================================
# GENERATE DEBUGGING OUTPUT            --> DEBUG FLAG set
# ---------
ifeq ($(DEBUG),true)  
OPTIONS   += -g3
CFLAGS    += -O0
BINARY    := $(BINARY)_DEBUG 
BINARY1   := $(BINARY1)_DEBUG
BINARY2   := $(BINARY2)_DEBUG 
endif
# ------------------------------------------------------------------------------


# ==============================================================================
# DEBUGGING LEVEL1                     --> Basic debugging output
# ----------------
ifeq ($(DEBUGGING),level1)
symdef9 :=_USE_DEBUGGING_LEVEL1  
SYMDEFS   += -D$(symdef9)
OPTIONS   += -g 
BINARY    := $(BINARY)_DEBUG_LEVEL1
BINARY1    := $(BINARY1)_DEBUG_LEVEL1  
BINARY2    := $(BINARY2)_DEBUG_LEVEL1  
endif
# ------------------------------------------------------------------------------


# ==============================================================================
# DEBUGGING LEVEL2                     --> Details on data structures      
# ----------------                         
ifeq ($(DEBUGGING),level2)
symdef10 :=_USE_DEBUGGING_LEVEL2
SYMDEFS   += -D$(symdef10)
OPTIONS   += -g 
#BINARY    := $(BINARY)_DEBUG_LEVEL2
#BINARY1    := $(BINARY1)_DEBUG_LEVEL2  
#BINARY2    := $(BINARY2)_DEBUG_LEVEL2
endif
# ------------------------------------------------------------------------------


# ==============================================================================
# DEBUGGING LEVEL3                     --> Details on parallel implementation
# ----------------
ifeq ($(DEBUGGING),level3)
symdef11 :=_USE_DEBUGGING_LEVEL3
SYMDEFS   += -D$(symdef11)
OPTIONS   += -g 
BINARY    := $(BINARY)_DEBUG_LEVEL3
BINARY1    := $(BINARY1)_DEBUG_LEVEL3  
BINARY2    := $(BINARY2)_DEBUG_LEVEL3
endif
# ------------------------------------------------------------------------------


# =============================================================================
# PARALLEL Version of MD-Cube
# ---------------------------
# --> Necessary compiler flag for the later MPI based parallel version of MD-CUBE
# --> For different parallel machines use directory paths appropriately
ifeq ($(PARALLEL),true)
  symdef8 :=_USE_MPI_PARALLEL
  SYMDEFS   += -D$(symdef8)
  CFLAGS += -I/home/martin/Installations/mpich-install/include
  LIBS   += -L/home/martin/Installations/mpich-install/lib -lmpich -lm
#  CFLAGS    += -I/usr/local/mpich-1.2.4..8a/include/
#  LIBS      += -L/usr/local/mpich-1.2.4..8a/lib/  -L/opt/gm/lib  -lmpich -lm 
#  LIBS      += -L/usr/local/mpich-1.2.4..8a/lib/  -L/opt/gm/lib  -lmpich -lm -lgm
  BINARY    := $(BINARY).Parallel
endif
# ------------------------------------------------------------------------------




# ==============================================
# SECTION 6: SOURCES OF PROGRAMS TO BE INSTALLED
#=========== -----------------------------------

#-----------------------------------------------------------------------
# BINARY: (MD-Cube) - Main target
#-----------------------------------------------------------------------
# The dependencies of the source files are taken care of automatically.
# Sources are stored away in 'sources/' and the object .o and dependency .d files
# get stored in 'builds/'. When adding new .c-files, the name has to be provided here. 
# THAT's ALL. When adding h.-files nothing has to be done here. They are being taken
# care of automatically. This automatism took me a week to figure out.
#------------------------------------------------------------------------------------------------
SRC = MD-Cube.c \
 InitSummary.c InitAllocation.c InitParameters.c InitTopologies.c InitArguments.c InitVelocities.c \
 IoHandling.c Warmup.c MCSamplingPivot.c Random.c                                                  \
 SolverBrownianDynamics.c SolverVelocityVerlet.c  Forces.c                                         \
 PotentialFene.c PotentialLJCosine.c PotentialBilayerMembrane.c PotentialsSummary.c                \
 VerletTables.c Ghosts.c BoundaryConditions.c  N2CalcAll.c                                         \
 Help.c CalculationsOntheFly.c CalculationsPolymers.c ExceptionHandling.c SetClocks.c shock.c                                                  
OBJ = $(SRC:.c=.o)
BIN = $(BINARY)
#------------------------------------------------------------------------------------------------


#-----------------------------------------------------------------------
# BINARY1: (MD-Cube.Grafics) - Dependencies of a grafics output program
#-----------------------------------------------------------------------
SRC1 = Grafics.c Alchemy.c Autodyn.c PolymersOpenDx.c VTK.c VMD.c POV.c
OBJ1 = $(SRC1:.c=.o)
BIN1 = $(BINARY1)
#------------------------------------------------------------------------------------------------


#-----------------------------------------------------------------------
# BINARY2 : (MD-Cube.AnalyzeData) - Dependencies of an analysis program
#-----------------------------------------------------------------------
SRC2 = Analyze.c AnalyzeCommandLine.c AnalyzeDataFileManagement.c \
AnalyzeMemoryManagement.c AnalyzePolymerStatics.c AnalyzePolymerDynamics.c \
Help.c ExceptionHandling.c AnalyzePolymerStress.c \
AnalyzeMembraneProperties.c AnalyzeImpact.c DBSCAN.c
OBJ2 = $(SRC2:.c=.o)
BIN2 = $(BINARY2)
#------------------------------------------------------------------------------------------------



# ==============================================
# SECTION 7: COMPILATION OF SOURCES AND BUILDING
#=========== -----------------------------------

#=========================================
# Define the different directories
BUILD=builds
BUILD_DIR=$(BUILD)/buildsMain
BUILD_DIR1=$(BUILD)/buildsGraphics
BUILD_DIR2=$(BUILD)/buildsAnalyze
SRCDIR=sources
VPATH=sources



# ==============================================================================
# 1. GENERATION OF MAIN TARGET (BINARY)
#-------------------------------------------------------------------------------
#
# It is decisive to use the 'patsubset' command - This cost me 3 days to figure out!
OBJS = $(patsubst %,$(BUILD_DIR)/%,$(OBJ))
#
## Nice compilation displaying the compiled files. Also, the install directory 
## in $HOME is created if it doesn't exist yet and the PATH variable is also
## set automatically.
$(BIN): $(OBJS)
	@echo "CC_ COMPILING DONE."
	@echo "___________________|"
	@sleep 1.0
	@echo
	@echo "___ LINKING OBJECT FILES..."
#	@sleep 0.5
	@$(CC) -o $@ $^ $(CFLAGS) $(OPTIONS) $(LIBS)
	@echo "_X_ LINKING DONE."
	@echo "___________________|"
	@sleep 1.0
	@echo
	@echo "___ INSTALLING ---> "$(BIN)""
#	@sleep 0.5
	@echo "    INTO '"$(INSTDIR)"'..."
	
## Check, if necessary directory exists, and if not, create it !
	@test -d $(BINDIR) || (mkdir $(BINDIR) ; echo "****CREATED directory $(BINDIR)")
	@test -d $(INSTDIR) || (mkdir $(INSTDIR) ; echo "****CREATED directory $(INSTDIR)")
	
## Continue with ordinary stuff
	@install -s $(BIN) $(INSTDIR)
	@echo "_X_ INSTALLING DONE."
	@echo "___________________|"
	@echo
	@sleep 0.5
	
ifeq ($(SHOW) , false)
	@echo "=================================================================="
	@echo "___ NOTE: ANY compiler warnings ARE STORED IN "'$(ERRORFILE_MAIN)'""
	@echo "=================================================================="
	@echo
	@sleep 2.0
endif
	
	@echo
	@echo "==============================================================="
	@echo "SYSTEM CONFIGURATION IS:"
	@sleep 0.5
	@echo  -------------------------------------
	@echo "PLATFORM 	is.....$(PLAT)"
	@echo "HOST     	is.....$(HOST)"
	@echo "NODENAME 	is.....$(NODENAME)"
	@echo "MACHINE  	is.....$(MACHINE)"
	@echo "TYPE     	is.....$(HTYPE)"
	@echo "USER     	is.....$(USER)"
	@echo "COMPILER 	is.....$(CC)"
	@echo "LIBS     	is.....$(LIBS)"
	@echo "OPTIONS  	is.....$(OPTIONS)"
	@echo "CFLAGS   	is.....$(CFLAGS)"
	@echo -------------------------------------
	@echo "THROW WARNINGS	is.....$(THROW)"
	@echo "==============================================================="
	@sleep 0.5
	@echo
	@echo "|==============================================================|"
	@echo "|*** NOTE: (C)opyright by                                      |"
	@echo "| Prof. Dr. rer. nat. habil. Martin Steinhauser (2003-present) |"
	@echo "|--------------------------------------------------------------|"
	@echo "|***   Frankfurt University of Applied Science                 |"
	@echo "|***   Faculty of Computer Science and Engineering             |"
	@echo "|***   Building 8, Room 115                                    |"
	@echo "|***   Nibelungenplatz 1                                       |"
	@echo "|***   D-60318 Frankfurt am Main                               |"
	@echo "|***   https://www.frankfurt-university.de/steinhauser         |"
	@echo "|***   E-Mail: martin.steinhauser@fb2.fra-uas.de               |"
	@echo "|***   https.//www.researchgate.net/profile/Martin-Steinhauser |"
	@echo "|==============================================================|"
	@echo "|***   CURRENT VERSION: $(VERSION)               |"
	@echo "|==============================================================|"
	@echo
	@echo "		============================="
	@echo "		  --->  FULL SUCCESS! <---   "
	@echo "		        -------------        "
	@echo "		============================="

# The following line in supposed to change all object into depency files, but this causes the compiler to
# throw a warning, which can be ignored.
-include $(OBJS:.o=.d)

## COMPILATION PROCESS
## -------------------
## Pretty sophisticated now, automatically discovering all dependencies and
## storing away the object and dependency files in a separate build directory.
## Error output during compilation is directed to .logfile. If anything goes
## wrong, look here for clues!
$(BUILD_DIR)/%.o: %.c


## Check first, if necessary directory exists, and if not, create it!
	@test -d $(BUILD) || (mkdir $(BUILD) ; echo "****CREATED directory $(BUILD)")
	@test -d $(BUILD_DIR) || (mkdir $(BUILD_DIR) ; echo "****CREATED directory $(BUILD_DIR)")

ifeq ($(THROW),false)
	@$(CC) -c $< $(CFLAGS) $(OPTIONS) -o $@ $(LIBS) 2>> $(ERRORFILE_MAIN)
endif
ifeq ($(THROW),true)
	@$(CC) -c $< $(CFLAGS) $(OPTIONS) -o $@ $(LIBS) 
endif


#	@sleep 0.5
	@echo CC_ COMPILING $<
	@gcc -MM $(CFLAGS) $(OPTIONS) $(SRCDIR)/$*.c > $*.d
	@mv -f $*.d $*.d.tmp
	@sed -e 's|.*:|$(BUILD_DIR)/$*.o:|' < $*.d.tmp > $*.d
	@sed -e 's/.*://' -e 's/\\$$//' < $*.d.tmp | fmt -1 | sed -e 's/^ *//' -e 's/$$/:/' >> $*.d
	@rm -f $*.d.tmp
	@mv -f *.d $(BUILD_DIR)/
# ==============================================================================
# MAIN TARGET FINISHED



# ==============================================================================
# 2. GENERATION OF GRAPHICAL OUTPUTT (BINARY1)
#-----------------------------------------------------------------------
#
# It is decisive to use the 'patsubset' command - This cost me 3 days to figure out!
OBJS1 = $(patsubst %,$(BUILD_DIR1)/%,$(OBJ1))
#
## Nice compilation displaying the compiled files
$(BIN1): $(OBJS1)
	@echo "CC_ COMPILING DONE."
	@echo "___________________|"
	@sleep 1.0
	@echo
	@echo "___ LINKING OBJECT FILES..."
	@sleep 0.5
	@$(CC) -o $@ $^ $(CFLAGS) $(OPTIONS) $(LIBS)
	@echo "_X_ LINKING DONE."
	@echo "___________________|"
	@sleep 1.0
	@echo
	@echo "___ INSTALLING ---> "$(BIN1)""
	@sleep 0.5
	@echo "    INTO '"$(INSTDIR)"'..."
	
## Check, if necessary directory exists, and if not, create it !
	@test -d $(BINDIR) || (mkdir $(BINDIR) ; echo "****CREATED directory $(BINDIR)")
	@test -d $(INSTDIR) || (mkdir $(INSTDIR) ; echo "****CREATED directory $(INSTDIR)")
	
## Continue with ordinary stuff
	@install -s $(BIN1) $(INSTDIR)
	@echo "_X_ INSTALLING DONE."
	@echo "___________________|"
	@echo
	@sleep 0.5
	
ifeq ($(SHOW) , false)
	@echo "=================================================================="
	@echo "___ NOTE: ANY compiler warnings ARE STORED IN "'$(ERRORFILE_GRAPHICS)'""
	@echo "=================================================================="
	@echo
	@sleep 0.5
endif

	@echo
	@echo "==============================================================="
	@echo "SYSTEM CONFIGURATION IS:"
	@sleep 0.5
	@echo ------------------------
	@echo "PLATFORM 	is.....$(PLAT)"
	@echo "HOST     	is.....$(HOST)"
	@echo "NODENAME 	is.....$(NODENAME)"
	@echo "MACHINE  	is.....$(MACHINE)"
	@echo "TYPE     	is.....$(HTYPE)"
	@echo "USER     	is.....$(USER)"
	@echo "COMPILER 	is.....$(CC)"
	@echo "LIBS     	is.....$(LIBS)"
	@echo "OPTIONS  	is.....$(OPTIONS)"
	@echo "CFLAGS   	is.....$(CFLAGS)"
	@echo -------------------------------------
	@echo "THROW WARNINGS	is.....$(THROW)"
	@echo "==============================================================="
	@sleep 1.0
	@echo
	@echo "|==============================================================|"
	@echo "|*** NOTE: (C)opyright by                                      |"
	@echo "| Prof. Dr. rer. nat. habil. Martin Steinhauser (2003-present) |"
	@echo "|--------------------------------------------------------------|"
	@echo "|***   Frankfurt University of Applied Science                 |"
	@echo "|***   Faculty of Computer Science and Engineering             |"
	@echo "|***   Building 8, Room 115                                    |"
	@echo "|***   Nibelungenplatz 1                                       |"
	@echo "|***   D-60318 Frankfurt am Main                               |"
	@echo "|***   https://www.frankfurt-university.de/steinhauser         |"
	@echo "|***   E-Mail: martin.steinhauser@fb2.fra-uas.de               |"
	@echo "|***   https.//www.researchgate.net/profile/Martin-Steinhauser |"
	@echo "|==============================================================|"
	@echo "|***   CURRENT VERSION: $(VERSION)               |"
	@echo "|==============================================================|"
	@echo
	@echo "		============================="
	@echo "		  --->  FULL SUCCESS! <---   "
	@echo "		        -------------        "
	@echo "		============================="


-include $(OBJS1:.o=.d)

## COMPILATION PROCESS
## -------------------
## Pretty sophisticated now, automatically discovering all dependencies and
## storing away the object and dependency files in a separate build directory.
## Error output during compilation is directed to .logfile. If anything goes
## wrong, look here for clues!
$(BUILD_DIR1)/%.o: %.c


## Check first, if necessary directory exists, and if not, create it!
	@test -d $(BUILD) || (mkdir $(BUILD) ; echo "****CREATED directory $(BUILD)")
	@test -d $(BUILD_DIR1) || (mkdir $(BUILD_DIR1) ; echo "****CREATED directory $(BUILD_DIR1)")

ifeq ($(THROW),false)
	@$(CC) -c $< $(CFLAGS) $(OPTIONS) -o $@ $(LIBS) 2>> $(ERRORFILE_GRAPHICS)
endif
ifeq ($(THROW),true)
	@$(CC) -c $< $(CFLAGS) $(OPTIONS) -o $@ $(LIBS) 
endif


	@sleep 0.5
	@echo CC_ COMPILING $<
	@gcc -MM $(CFLAGS) $(OPTIONS) $(SRCDIR)/$*.c > $*.d
	@mv -f $*.d $*.d.tmp
	@sed -e 's|.*:|$(BUILD_DIR1)/$*.o:|' < $*.d.tmp > $*.d
	@sed -e 's/.*://' -e 's/\\$$//' < $*.d.tmp | fmt -1 | sed -e 's/^ *//' -e 's/$$/:/' >> $*.d
	@rm -f $*.d.tmp
	@mv -f *.d $(BUILD_DIR1)/
# ==============================================================================
# GRAPHICAL OUTPUT TARGET FINISHED



# ==============================================================================
# 3. GENERATION OF ANALYZE OUTPUTT (BINARY2)
#-----------------------------------------------------------------------
#
# It is decisive to use the 'patsubset' command - This cost me 3 days to figure out!
OBJS2 = $(patsubst %,$(BUILD_DIR2)/%,$(OBJ2))
#
## Nice compilation displaying the compiled files
$(BIN2): $(OBJS2)
	@echo "CC_ COMPILING DONE."
	@echo "___________________|"
	@sleep 1.0
	@echo
	@echo "___ LINKING OBJECT FILES..."
	@sleep 0.5
	@$(CC) -o $@ $^ $(CFLAGS) $(OPTIONS) $(LIBS)
	@echo "_X_ LINKING DONE."
	@echo "___________________|"
	@sleep 1.0
	@echo
	@echo "___ INSTALLING ---> "$(BIN2)""
	@sleep 0.5
	@echo "    INTO '"$(INSTDIR)"'..."
	
		
## Check, if necessary directory exists, and if not, create it !
	@test -d $(BINDIR) || (mkdir $(BINDIR) ; echo "****CREATED directory $(BINDIR)")
	@test -d $(INSTDIR) || (mkdir $(INSTDIR) ; echo "****CREATED directory $(INSTDIR)")
	
## Continue with ordinary stuff
	@install -s $(BIN2) $(INSTDIR)
	@echo "_X_ INSTALLING DONE."
	@echo "___________________|"
	@echo
	@sleep 0.5
	
	
	
ifeq ($(SHOW) , false)
	@echo "=================================================================="
	@echo "___ NOTE: ANY compiler warnings ARE STORED IN "'$(ERRORFILE_ANALYZE)'""
	@echo "=================================================================="
	@echo
	@sleep 2.0
endif
	
	@echo
	@echo "==============================================================="
	@echo "SYSTEM CONFIGURATION IS:"
	@sleep 0.5
	@echo ------------------------
	@echo "PLATFORM 	is.....$(PLAT)"
	@echo "HOST     	is.....$(HOST)"
	@echo "NODENAME 	is.....$(NODENAME)"
	@echo "MACHINE  	is.....$(MACHINE)"
	@echo "TYPE     	is.....$(HTYPE)"
	@echo "USER     	is.....$(USER)"
	@echo "COMPILER 	is.....$(CC)"
	@echo "LIBS     	is.....$(LIBS)"
	@echo "OPTIONS  	is.....$(OPTIONS)"
	@echo "CFLAGS   	is.....$(CFLAGS)"
	@echo -------------------------------------
	@echo "THROW WARNINGS	is.....$(THROW)"
	@echo "==============================================================="
	@sleep 1.0
	@echo
	@echo "|==============================================================|"
	@echo "|*** NOTE: (C)opyright by                                      |"
	@echo "| Prof. Dr. rer. nat. habil. Martin Steinhauser (2003-present) |"
	@echo "|--------------------------------------------------------------|"
	@echo "|***   Frankfurt University of Applied Science                 |"
	@echo "|***   Faculty of Computer Science and Engineering             |"
	@echo "|***   Building 8, Room 115                                    |"
	@echo "|***   Nibelungenplatz 1                                       |"
	@echo "|***   D-60318 Frankfurt am Main                               |"
	@echo "|***   https://www.frankfurt-university.de/steinhauser         |"
	@echo "|***   E-Mail: martin.steinhauser@fb2.fra-uas.de               |"
	@echo "|***   https.//www.researchgate.net/profile/Martin-Steinhauser |"
	@echo "|==============================================================|"
	@echo "|***   CURRENT VERSION: $(VERSION)               |"
	@echo "|==============================================================|"
	@echo
	@echo "		============================="
	@echo "		  --->  FULL SUCCESS! <---   "
	@echo "		        -------------        "
	@echo "		============================="

	
-include $(OBJS2:.o=.d)

## COMPILATION PROCESS
## -------------------
## Pretty sophisticated now, automatically discovering all dependencies and
## storing away the object and dependency files in a separate build directory.
## If the build directory does not exist it is automatically created.
## Error output during compilation is directed to .logfile. If anything goes
## wrong, look here for clues!
$(BUILD_DIR2)/%.o: %.c


## Check first, if necessary directory exists, and if not, create it!
	@test -d $(BUILD) || (mkdir $(BUILD) ; echo "****CREATED directory $(BUILD)")
	@test -d $(BUILD_DIR2) || (mkdir $(BUILD_DIR2) ; echo "****CREATED directory $(BUILD_DIR2)")

ifeq ($(THROW),false)
	@$(CC) -c $< $(CFLAGS) $(OPTIONS) -o $@ $(LIBS) 2>> $(ERRORFILE_ANALYZE)
endif
ifeq ($(THROW),true)
	@$(CC) -c $< $(CFLAGS) $(OPTIONS) -o $@ $(LIBS) 
endif

	@sleep 0.5
	@echo CC_ COMPILING $<
	@gcc -MM $(CFLAGS) $(OPTIONS) $(SRCDIR)/$*.c > $*.d
	@mv -f $*.d $*.d.tmp
	@sed -e 's|.*:|$(BUILD_DIR2)/$*.o:|' < $*.d.tmp > $*.d
	@sed -e 's/.*://' -e 's/\\$$//' < $*.d.tmp | fmt -1 | sed -e 's/^ *//' -e 's/$$/:/' >> $*.d
	@rm -f $*.d.tmp
	@mv -f *.d $(BUILD_DIR2)/
# ==============================================================================
# ANALYZE OUTPUT TARGET FINISHED



# ==============================================================================
# SECTION 8: SOME MORE TARGETS
# ========= ------------------

# ==========================================
# STANDARD COMMAND 'all' makes main program: 
#-------------------------------------------
all          :$(BIN) $(BIN1) $(BIN2)

# ==========================================
# EACH SINGLE TARGET: 
#-------------------------------------------
MD-CUBE      :$(BIN)
Graphics     :$(BIN1)
Analyze		 :$(BIN2)
# ------------------------------------------------------------------------------


# ===============================
# The standard clean command
clean:

	@echo
	@echo "___ DELETING LOCAL BINARIES AND BUILD DIRECTORIES..."
	@$(RM) $(OBJ) $(OBJ1) $(OBJ2) $(BIN) $(BIN1) $(BIN2) 
	@echo "_X_ CLEANED "$(MAKEDIR)"/"
	@sleep 0.3
	@$(RM) $(BUILD_DIR)/ 
	@$(RM) $(BUILD_DIR1)/
	@$(RM) $(BUILD_DIR2)/
	@echo "_X_ DELETED ./"$(BUILD_DIR)"/" 
	@sleep 0.3
	@echo "_X_ DELETED ./"$(BUILD_DIR1)"/" 
	@sleep 0.3
	@echo "_X_ DELETED ./"$(BUILD_DIR2)"/"
	@sleep 0.3
	@echo "		============================="
	@echo "		  --->  FULL SUCCESS! <---   "
	@echo "		        -------------        "
	@echo "		============================="
#-------------------------------------------------------------------------------



# ======================================================================
# Cleans all binaries, objects, core files, documentation and test files
cleanall:

	@echo
	@echo "___ DELETING LOCAL BINARIES..."
	@$(RM) $(BIN) $(BIN1) $(BIN2) main.o
	@sleep 1.0
	@echo "_X_ $(MAKEDIR) CLEANED"
	@echo
	@echo "___ DELETING REMOTE BINARIES IN "$(INSTDIR)"..."
	@$(RM) $(INSTDIR)/$(BIN) $(INSTDIR)/$(BIN1) $(INSTDIR)/$(BIN2)
	@sleep 1.0
	@echo "_X_ $(MAKEDIR) CLEANED"
	@echo
	@sleep 1.0
	@echo "___ CLEANING BINARIES IN "$(INSTDIR)"..."
	@sleep 1.0
	@echo "_X_ BINARIES IN $(INSTDIR) DELETED"
	@echo
	@echo "___ DELETING LOCAL COMPILER LOGFILES IN "$(MAKEDIR)"..."
	@$(RM) $(ERRORFILE_MAIN) $(ERRORFILE_GRAPHICS) $(ERRORFILE_ANALYZE)
	@echo "_X_ LOGFILES DELETED"
	@echo
	@echo "___ DELETING "Testing" DIRECTORY IN "$(INSTDIR)"..."	
	@$(RM) ./Testing
	@sleep 1.0
	@echo "_X_ DELETED ./Testing directory"
	@sleep 0.5
	@echo "_X_ ALL CLEANED"	
	@sleep 1.0
	@echo "		============================="
	@echo "		  --->  FULL SUCCESS! <---   "
	@echo "		        -------------        "
	@echo "		============================="
#-------------------------------------------------------------------------------



# ========================
# Cleans all documentation
cleandoc:

	@echo
	@echo "___ CLEANING ALL DOCUMENTATION..."
	@$(RM) $(DOCDIR)
	@echo "_X_ REMOVED "$(DOCDIR)""
	@echo "		============================="
	@echo "		  --->  FULL SUCCESS! <---   "
	@echo "		        -------------        "
	@echo "		============================="
#-------------------------------------------------------------------------------



# ==================
# Make documentation
doc:

#ifeq ($(DOXYVERSION), 1.9.4)
#	@doxygen Doxyfile
	@echo
	@echo "================================================================================"
	@echo "___ YOU ARE USING doxygen VERSION "$(DOXYVERSION)"...."
	@echo "___ GENERATING DOCUMENTATION IN "$(DOCDIR)"...."
	@echo "================================================================================"
	@echo
	@sleep 2
#else
#	echo
#	$(warning --> You should consider updating your version of doxygen...)
#	sleep 2.0
#	echo
#	echo "___ GENERATING DOCUMENTATION IN "$(DOCDIR)"...."
#	@echo
#	@sleep 1
#endif

	@$(MAKEDOC)
	@echo "================================================================================"
	@echo "GENERATING Documentation in $(DOCDIR) done!"
	@echo "================================================================================"
#-------------------------------------------------------------------------------

	

# ====================
# Generate a help menu
help:

	@echo $(LINE)
	@echo "------------------------------------------------------------------------------------------------------------------"
	@echo "**** 'MD-CUBE' Makefile Usage instructions"
	@echo
	@echo "Supported TARGETS:"
	@echo "------------------"
	@echo " make all              : create all targets (currently three:"
	@echo "						  $(BIN) $(BIN1) $(BIN2)"
	@echo " make Analyze          : create target 'MD-Cube.Analyze'"
	@echo " make doc              : create html & latex & rtf documentation (platform independent)" 
	@echo "------------------------------------------------------------------------------------------------------------------" 
	@echo " make clean            : delete all local objects & binaries for current platform"
	@echo " make cleandoc         : delete html & latex & rtf dokumentation"
	@echo " make cleanall          : clean all local files and the binaries in $HOME/mybins"
	@echo "------------------------------------------------------------------------------------------------------------------" 
	@echo
	@echo
	@echo "Addtitional parameters: (ONLY for SIMTYPE polymer)"
	@echo "-----------------------"
	@echo " make SIMTYPE=polymer  : create binary for polymer code version for current platform (default is polymer)"
	@echo " make SEARCHLOOP=cells : create polymer binary with cells only for current platform"
	@echo " make SEARCHLOOP=lists : create polymer binary with cells and neighbor lists only for current platform"
	@echo " make SEARCHLOOP=n2calc: create polymer binary with an N^2 loop for current platform"
	@echo "                       --------------------------------------------------------------------------------------------" 
	@echo " make MODE=pivot       : create polymer binary along with pivot moves for current platform"
	@echo " make PIVOT=statistics : create polymer binary along with pivot statistics for current platform"
	@echo " make TYPE=melt        : create polymer binary for polymer melts for current platform (default is single)"
	@echo " make TYPE=single      : create polymer binary for single, isolated chains for current platform"
	@echo
	@echo
	@echo "General Options:"
	@echo "----------------"
	@echo " make GUI=true	     	: create GUI for selected binary for pre- and post-processing for current platform"
	@echo " make PARALLEL=true   	: create parallel version for selected binary for current platform"
	@echo " make THROW=true         : display all compiler warnings during compilation process"
	@echo " make DEBUGGING=true  	: create debugging output for selected binary for current platform"
	@echo " make PROFILING=true  	: create profiling information for selected binary for current platform"
	@echo " make COMPILE=clang   	: use the clang compiler on MAC OS X systems (is more reliable and exact)"
	@echo " make COMPILE=llvm-gcc   : use directly the standard llvm compiler on MAC OS which is the same as clang"
	@echo " make COMPILE=gcc-12     : use gcc from the Free Software Foundation if installed, e.g. by brew"
	@echo "                       ---------------------------------------------------------------------------------------------" 
	@echo	
	@echo "Supported platforms:"
	@echo "--------------------"
	@echo "i686              			(Standard Linux)" 
	@echo "i686-pc-linux-gnu 			(Standard Linux)"
	@echo "OSF5.1            			(SUN UNIX)      "
	@echo "unicosmk          			(Cray UNIX)     "
	@echo "AIX               			(HP UNIX)       "
	@echo "Cygwin            			(Cygwin under Windows, also with Eclipse)"	
	@echo "x86-64-linux-gnu  			(Linux 64bit)"
	@echo "x86-64-suse-linux 			(Standard Suse 64bit linux)"
	@echo "x86_64-apple-darwin22.1.0		(macOS)"
# ------------------------------------------------------------------------------
	@sleep 1.0
	@echo
	@echo "|==============================================================|"
	@echo "|*** NOTE: (C)opyright by                                      |"
	@echo "| Prof. Dr. rer. nat. habil. Martin Steinhauser (2003-present) |"
	@echo "|--------------------------------------------------------------|"
	@echo "|***   Frankfurt University of Applied Science                 |"
	@echo "|***   Faculty of Computer Science and Engineering             |"
	@echo "|***   Building 8, Room 115                                    |"
	@echo "|***   Nibelungenplatz 1                                       |"
	@echo "|***   D-60318 Frankfurt am Main                               |"
	@echo "|***   https://www.frankfurt-university.de/steinhauser         |"
	@echo "|***   E-Mail: martin.steinhauser@fb2.fra-uas.de               |"
	@echo "|***   https.//www.researchgate.net/profile/Martin-Steinhauser |"
	@echo "|==============================================================|"
	@echo "|***   CURRENT VERSION: $(VERSION)               |"
	@echo "|==============================================================|"
	@echo
	@echo $(LINE)
#-------------------------------------------------------------------------------
