#
# Copyright (c) 2016 University of Cambridge All rights reserved.
#
# Author: Marco Forconesi
#
# This software was developed with the support of 
# Prof. Gustavo Sutter and Prof. Sergio Lopez-Buedo and
# University of Cambridge Computer Laboratory NetFPGA team.
#
# @NETFPGA_LICENSE_HEADER_START@
#
# Licensed to NetFPGA C.I.C. (NetFPGA) under one or more
# contributor license agreements.  See the NOTICE file distributed with this
# work for additional information regarding copyright ownership.  NetFPGA
# licenses this file to you under the NetFPGA Hardware-Software License,
# Version 1.0 (the "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at:
#
#   http://www.netfpga-cic.org
#
# Unless required by applicable law or agreed to in writing, Work distributed
# under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
# CONDITIONS OF ANY KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations under the License.
#
# @NETFPGA_LICENSE_HEADER_END@

##############################################################################

CC=gcc
CFLAGS=-Wall -lpcap

ifeq ($(OS),Windows_NT)
	DEL := del /q /S 
	RD  := rd /q /S 
else
	DEL := rm -rf 
	RD  := rm -rf 
endif

clean_dirs := xsim.dir
clean_list := xsim* xelab* xvlog* xvhdl* webtalk* simlog *.dat

HDL  = $(wildcard $(SIM_HDL)/*.v)
VHDL = $(SRC_VHDL)/xgmii_includes.vhd

ifeq ($(USE_VHDL),src)
    VHDL += $(SRC_VHDL)/axis2xgmii.vhd
	VHDL += $(SRC_VHDL)/xgmii2axis.vhd
	VHDL += $(SRC_VHDL)/padding_ctrl.vhd
	VHDL += $(SRC_VHDL)/rst_mod.vhd
	VHDL += $(SRC_VHDL)/rx.vhd
	VHDL += $(SRC_VHDL)/tx.vhd
	VHDL += $(SRC_VHDL)/nfmac10g.vhd
else
    HDL += $(wildcard $(SRC_HDL)/*.v)
endif

TEST ?= loopback
top_sim_hdl := nfmac10g_$(TEST)_tb

ifeq ($(TEST),nf2xil)
	top_sim_hdl := nfmac10g_interoperability_tb
	xvflags := -d rx_xilinx_mac
endif

ifeq ($(TEST),xil2nf)
	top_sim_hdl := nfmac10g_interoperability_tb
	xvflags := -d tx_xilinx_mac
endif

ifeq ($(TEST),axis_loopback)
	HDL += $(wildcard $(USRIF_HDL)/*.v)
	top_sim_hdl := usr_intf_axis_loopback_tb
endif

.PHONY: clean cleansim gen_stim runsim siminst sim_usr_intf

IFGI_VALUES       := 0 10 20
CORR_LEVLI_VALUES := 0 1 2
UNDERRUNI_VALUES  := 1 2

siminst:
	$(foreach ifgi, $(IFGI_VALUES), $(foreach corr_levli, $(CORR_LEVLI_VALUES), $(MAKE) runsim USE_VHDL_SRC=$(USE_VHDL_SRC) SIMHDL=$(SIMHDL) SRC_HDL=$(SRC_HDL) SRC_VHDL=$(SRC_VHDL) PCAP=$(PCAP) TEST=$(TEST) IFG=$(ifgi) CORR_LEVL=$(corr_levli) UNDERRUN=0 LOG=$(LOG) && )) true
	$(foreach ifgi, $(IFGI_VALUES), $(foreach underruni, $(UNDERRUNI_VALUES), $(MAKE) runsim USE_VHDL_SRC=$(USE_VHDL_SRC) SIMHDL=$(SIMHDL) SRC_HDL=$(SRC_HDL) SRC_VHDL=$(SRC_VHDL) PCAP=$(PCAP) TEST=$(TEST) IFG=$(ifgi) CORR_LEVL=0 UNDERRUN=$(underruni) LOG=$(LOG) && )) true

runsim: gen_stim $(HDL) $(VHDL)
	echo "\n\n////\nSim: IFG=$(IFG) CORR_LEVL=$(CORR_LEVL) UNDERRUN=$(UNDERRUN)\n////" >> $(LOG)
	xvlog -sv $(xvflags) $(HDL)
	xvhdl -2008 $(VHDL)
	xelab work.$(top_sim_hdl) -s sim_snapshot
	xsim -R sim_snapshot > simlog
	grep -i "SIM OK" simlog || (echo "Simulation failed, see reports"; false)
	cat simlog >> $(LOG)

sim_usr_intf:
	$(foreach ifgi, $(IFGI_VALUES), $(foreach corr_levli, $(CORR_LEVLI_VALUES), $(MAKE) runsim USE_VHDL_SRC=$(USE_VHDL_SRC) SIMHDL=$(SIMHDL) SRC_HDL=$(SRC_HDL) SRC_VHDL=$(SRC_VHDL) USR_INTF_SRCHDL=$(USR_INTF_SRCHDL) PCAP=$(PCAP) TEST=$(TEST) IFG=$(ifgi) CORR_LEVL=0 UNDERRUN=0 LOG=$(LOG)))

gen_stim: pcap2axis cleansim
	./$< $(PCAP) $(IFG) $(CORR_LEVL) $(UNDERRUN)

pcap2axis: pcap2axis.c
	$(CC) -o $@  $< $(CFLAGS)

cleansim: 
	-$(foreach entry, $(clean_dirs), $(shell $(RD) $(entry)))
	-$(foreach entry, $(clean_list), $(shell $(DEL) $(entry)))

clean: cleansim
	-$(DEL) pcap2axis
	-$(DEL) pcap2axis.exe
