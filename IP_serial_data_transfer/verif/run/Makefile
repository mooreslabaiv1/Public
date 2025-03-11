
################################################################################
PROJECT_NAME = serialDP
################################################################################

INCL      = +incdir+../include+../src+../env+../tests+../tb+../rtl

################################################################################

DEFINES   =
COMP_OPTS =
RTL_DOT_FS    = -f rtl.f
CM_DIR = ./coverage_data
RUN_OPTS  = -cm line+tgl+cond+branch+fsm -l simv.log +vcs+cm_report -cm_dir $(CM_DIR)
SIMULATOR = ./simv
COVERAGE_OPTS = -cm line+tgl+cond+branch+fsm -cm_dir $(CM_DIR)
TEST_LIST = testlist.f
LOG_DIR=logs
# <Optional> ToDo: Top level dut file
DUT =
#Checking the VCS version
VCS_VERSION = $(shell vcs -id > vcs_version ; grep "Compiler version" vcs_version | awk -F " " '{print $$5}')
#This variable contains all the UVM-1.0 supported VCS tool versions.
UVM10_SUPP_VCS_VERSNS = E-2011.03
SEED      = 1 # Default seed set to 1
VERBOSITY = debug
MODE      = NORMAL # Default configuration record-replay mode set to NORMAL

#### VCS and UVM checking
ifdef VCS_HOME
 ifneq ($(VCS_VERSION),$(filter $(VCS_VERSION),$(UVM10_SUPP_VCS_VERSNS)))
  VCS_VERS_WARNING = 1
 endif
 ifndef UVM_HOME
  UVM = -ntb_opts uvm
 else
  UVM = -debug_pp +incdir+$(UVM_HOME)/src $(UVM_HOME)/src/uvm_pkg.sv ${UVM_HOME}/src/dpi/uvm_dpi.cc -CFLAGS -DVCS
 endif
else
 ERR_STATUS = 1
endif

COMP_OPTS = -full64 -timescale=1ns/10ps -sverilog -l vcs.log $(UVM) $(RTL_DOT_FS) $(INCL) $(DEFINES)

all default: check clean comp run_all convert_coverage_html

check:
ifdef VCS_VERS_WARNING
	@echo ""
	@echo "VCS version is ${VCS_VERSION}"
	@echo "WARNING: VCS version should be atleast E-2011.03 or greater"
	@echo ""
endif
ifdef ERR_STATUS
	@echo ""
	@echo "ERROR : VCS_HOME is not set"
	@echo "Please set VCS_HOME to run this Makefile"
	@echo ""
endif

lint: check
	vcs -parse_only $(COMP_OPTS)              $(COVERAGE_OPTS)             -debug_all ../tb/serialDP_tb_top.sv

comp: check
ifndef ERR_STATUS
ifeq ($(MODE), RECORD)
		vcs $(COMP_OPTS)                  $(COVERAGE_OPTS)                 -debug_all ../tb/serialDP_tb_top.sv
else
ifeq ($(MODE), DEBUG)
		vcs $(COMP_OPTS)                  $(COVERAGE_OPTS)                 -debug_all  ../tb/serialDP_tb_top.sv
else
		vcs $(COMP_OPTS)                  $(COVERAGE_OPTS)                 ../tb/serialDP_tb_top.sv
endif
endif
endif

# Set TEST_PREFIX based on MODE (RECORD or default)
TEST_PREFIX := $(if $(findstring RECORD,$(MODE)),runMode-,run-)

# Create a directory for logs
$(LOG_DIR):
	mkdir -p $(LOG_DIR)

# Target to run all tests listed in TEST_LIST
run_all: $(LOG_DIR) $(foreach test, $(shell cat $(TEST_LIST)), $(TEST_PREFIX)$(test))

# Target to run individual tests; generates log files for each test
run-%: $(LOG_DIR)
	@echo "Running test: $*"
	$(SIMULATOR) $(RUN_OPTS) +ntb_random_seed=$(SEED) +UVM_TESTNAME=$* -l $(LOG_DIR)/$*.log

# Target to run individual tests in RECORD mode; generates log files with additional options
runMode-%: $(LOG_DIR)
	@echo "Running test in RECORD mode: $*"
	$(SIMULATOR) $(RUN_OPTS) +ntb_random_seed=$(SEED) +UVM_TESTNAME=$* +UVM_TR_RECORD +UVM_LOG_RECORD -l $(LOG_DIR)/$*.log

convert_coverage_html:
	$(VCS_HOME)/bin/urg -dir $(CM_DIR).vdb/ -report ./coverage_html

# Clean up log files
.PHONY: clean
clean:
	rm -rf $(LOG_DIR)
	rm -rf simv* csrc
	rm -rf vc_hdrs.h .vcsmx_rebuild *.log
	rm -rf work/* *.svshell vcs_version
	rm -rf coverage_*
	rm -f testbench.vcd ucli.key .fsm*


help:
	@echo "****************************************************************"
	@echo "***   Makefile Help for serialDP VIP :  				    ***"
	@echo "****************************************************************"
	@echo "*  Usage:                                                      *"
	@echo "*  ------                                                      *"
	@echo "*  make       Compile and Run the testcase                     *"
	@echo "*                                                              *"
	@echo "*  Available targets:                                          *"
	@echo "*  make help  [To see the Help]                                *"
	@echo "*  make clean [Remove simulation generated files/directories]  *"
	@echo "*  make comp  [Compile the testcase]                           *"
#	@echo "*                                                              *"
	@echo "*  Optional Arguments                                          *"
#	@echo "*  VERBOSITY         [Message severity to be display]          *"
#	@echo "*  make VERBOSITY=<sev> [example make VERBOSITY=note]          *"
	@echo "*  MODE = RECORD/DEBUG                                         *"
	@echo "*  make MODE=RECORD  [To enable UVM TR Record mechanism]       *"
	@echo "*  make MODE=DEBUG  [To enable -debug_all]                     *"
	@echo "****************************************************************"
