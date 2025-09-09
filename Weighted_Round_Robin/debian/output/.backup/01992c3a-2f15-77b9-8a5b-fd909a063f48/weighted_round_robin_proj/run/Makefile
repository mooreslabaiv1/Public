################################################################################
PROJECT_NAME   = weighted_round_robin
################################################################################

###########
## DEFINES 
###########
DEFINES        =


##############
## DOT_F FILES 
##############
RTL_DOT_F      = -f /actions/_work/mooreslab_full_app/mooreslab_full_app/samples/weighted_round_robin/rtl/rtl.vf
TB_DOT_F       = -f tb.f


##############
## UVM OPTIONS 
##############
UVM_VERBOSITY  = 
UVM_OPTS       =


###############
## VCS OPTIONS 
###############
CM_DIR         = ./coverage_data
COVERAGE_OPTS  = -cm line+tgl+cond+branch+fsm -cm_dir $(CM_DIR)
COMP_OPTS      = -timescale=1ns/1ns -sverilog -l comp.log -ntb_opts uvm $(RTL_DOT_F) $(TB_DOT_F) $(DEFINES)
RUN_OPTS       = ./simv -l sim.log +vcs+cm_report $(COVERAGE_OPTS) +UVM_TIMEOUT=3000000


#####################
## REGRESSION OPTIONS 
#####################
LOG_DIR        = logs
TEST_LIST      = testlist.f

all default: check clean comp run_all cov_report

##############
##  VCS CHECK
##############
check:
ifndef VCS_HOME
	@echo ""
	@echo "ERROR : VCS_HOME is not set"
	@echo "Please set VCS_HOME to run this Makefile"
	@echo ""
endif


##############
##  LINT CHECK
##############
lint: check
	vcs -full64 -parse_only $(COMP_OPTS)  $(COVERAGE_OPTS)


##############
##  COMPILE
##############
comp: check
	vcs -full64 $(COMP_OPTS)  $(COVERAGE_OPTS)


#####################
##  RUN SINGLE TEST
#####################
# Create a directory for logs
$(LOG_DIR):
	mkdir -p $(LOG_DIR)
# Run a single test
run-%: $(LOG_DIR)
	@echo "###################"
	@echo "Running test: $*"
	@echo "###################"
	$(RUN_OPTS) +ntb_random_seed=$(SEED) +UVM_TESTNAME=$* -l $(LOG_DIR)/$*.log  -cm_name $*


#####################
##  RUN REGRESSION
#####################
# Target to run all tests listed in TEST_LIST
run_all: $(LOG_DIR) $(foreach test, $(shell cat $(TEST_LIST)), run-$(test))


#####################
##  MERGE COVERAGE
#####################
cov_report:
	$(VCS_HOME)/bin/urg -dir $(CM_DIR).vdb/ -report ./coverage_html


#########################
##  CLEAN LOG/TEMP FILES
#########################
# Clean up log files
clean:
	rm -rf $(LOG_DIR)
	rm -rf simv* csrc
	rm -rf vc_hdrs.h .vcsmx_rebuild *.log
	rm -rf work/* *.svshell vcs_version
	rm -rf coverage_*
	rm -f testbench.vcd ucli.key .*.xml


#########
##  HELP
#########
help:
	@echo "****************************************************************"
	@echo "***   Makefile Help for weighted_round_robin VIP :  				    ***"
	@echo "****************************************************************"
	@echo "*  Usage:                                                      *"
	@echo "*  ------                                                      *"
	@echo "*  make       Compile and Run all the testcases                *"
	@echo "*                                                              *"
	@echo "*  Available targets:                                          *"
	@echo "*  make help  [To see the Help]                                *"
	@echo "*  make clean [Remove simulation generated files/directories]  *"
	@echo "*  make comp  [Compile the design and testbench]               *"
	@echo "****************************************************************"

.PHONY: clean
all default: check clean comp run_all cov_report
