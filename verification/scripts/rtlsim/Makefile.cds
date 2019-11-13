SOC_NAME = ../../../../../../chilipe
TOP_DIR = $(SOC_NAME)/rs_top
BLOCKS_DIR = $(SOC_NAME)/blocks
RTL_SRC = $(BLOCKS_DIR)/reed_solomon/frontend/rtl/src
MODEL_SRC = $(BLOCKS_DIR)/reed_solomon/frontend/model/src
VTB = $(BLOCKS_DIR)/reed_solomon/verification/tb
VLOGS = $(BLOCKS_DIR)/reed_solomon/verification/logs
VREPORT = $(BLOCKS_DIR)/reed_solomon/verification/reports
VSCRIPTS = $(BLOCKS_DIR)/reed_solomon/verification/scripts
AXI_RTL = $(BLOCKS_DIR)/axi4_lite/frontend/rtl/src

DECODER_C = $(MODEL_SRC)/decode_C
REFMOD = $(DECODER_C)/encoder.cpp $(DECODER_C)/decoder.cpp
IFS = $(AXI_RTL)/axi4_lite_if.sv 

RTL = $(RTL_SRC)/reedsolomon.sv \
			$(RTL_SRC)/encrtl/register_in_if.sv \
			$(RTL_SRC)/encrtl/register_out_if.sv \
			$(RTL_SRC)/decrtl/basic_ops.sv \
			$(RTL_SRC)/encrtl/rsenc.sv \
			$(RTL_SRC)/encrtl/rsenc_control.sv \
			$(RTL_SRC)/decrtl/syndrome.sv \
			$(RTL_SRC)/decrtl/synd.sv \
			$(RTL_SRC)/decrtl/Berlekamp_Massey.sv \
			$(RTL_SRC)/decrtl/omega.sv \
			$(RTL_SRC)/decrtl/CSvalue.sv \
			$(RTL_SRC)/decrtl/CSlocation.sv \
			$(RTL_SRC)/decrtl/Forney.sv \
			$(RTL_SRC)/decrtl/rsdec.sv \
			$(RTL_SRC)/ramrtl/ram.sv \
			$(RTL_SRC)/ramrtl/datapath_rs.sv

PKGS = $(AXI_RTL)/axi4_types.sv $(VTB)/rs_pkg.sv 
SEED = 1
QTD_TESTS = 10

UVM = +UVM_TR_RECORD +UVM_TESTNAME=rs_test +UVM_VERBOSITY=HIGH
MODE = ALL
COVER = 100
TRANSA = 1000

RUN_ARGS_COMMON = -access +r -input $(VSCRIPTS)/rtlsim/shm.tcl \
		  +uvm_set_config_int=*,recording_detail,1 -coverage all -covoverwrite


GATE =         /mnt/hdd1tera/xfab/xh018/diglibs/D_CELLS_HD/v3_0/verilog/v3_0_0/VLG_PRIMITIVES.v \
               /mnt/hdd1tera/xfab/xh018/diglibs/D_CELLS_HD/v3_0/verilog/v3_0_0/D_CELLS_HD.v \
               ../reedsolomon/synthesis/synthesis/outputs/reedsolomon_map.v

sim:
	@g++ -g -fPIC -Wall -std=c++0x $(REFMOD) -shared -o teste.so
	@xrun -64bit -uvm +incdir+$(VTB) +incdir+$(RTL_SRC) +incdir+$(AXI_RTL) $(PKGS) $(IFS) $(RTL) $(VTB)/rs_top.sv -sv_lib teste.so \
		+UVM_TESTNAME=rs_test +UVM_VERBOSITY=HIGH -covtest rs_test-$(SEED) -svseed $(SEED)  \
	  -defparam rs_top.min_cover=$(COVER) -defparam rs_top.min_transa=$(TRANSA) -define $(MODE) $(RUN_ARGS_COMMON) -timescale 1ns/1ns
	
simgate:
	g++ -g -fPIC -Wall -std=c++0x $(REFMOD) -shared -o teste.so
	irun -64bit -uvm +incdir+$(RTL_SRC) +incdir+$(AXI_RTL) $(PKGS) $(IFS) $(GATE) $(VTB)/rs_top.sv -sv_lib teste.so \
	  +UVM_TESTNAME=rs_test -covtest rs_test-$(SEED) -svseed $(SEED)  \
	  -access +r -input shm.tcl \
		  +uvm_set_config_int=*,recording_detail,1 -coverage all -covoverwrite \
	  -define NETLIST -sdf_simtime -maxdelays -sdf_verbose -timescale 1ns/1ps
	mv *.log $(VLOGS)/gatesim/
	mv *.history $(VREPORT)/gatesim/

clean:
	@rm -rf INCA_libs waves.shm $(VREPORT)/rtlsim/* *.history *.log $(VLOGS)/rtlsim/* *.key mdv.log imc.log imc.key ncvlog_*.err *.trn *.dsn .simvision/ xcelium.d simv.daidir cov_work *.so *.o

view_waves:
	simvision waves.shm &

view_cover:
	imc &

testes: sim
	@mkdir --parents reports/
	@for i in `seq 1 10000`; do \
	  seed=$$((1 + RANDOM % 10000)); \
	  echo "Running test: " $$i; \
		$(MAKE) isim VERB=HIGH MINT=1500 SEED=$$seed BAUD=$${BAUD_RATES[$${i}]}| grep "Mismatch" > reports/$$seed; \
		done;
	  #$(MAKE) isim $(UVM) +ntb_random_seed=$$seed | grep "Mismatch" > reports/$$seed; \
	  done;

