#  (c) Bernecker + Rainer Industrie-Elektronik Ges.m.b.H.
#      A-5142 Eggelsberg, B&R Strasse 1
#      www.br-automation.com
#
# Project       : POWERLINK Xilinx Examples
# Module        : Build all designs
# Autor         : mairt
# Date          : 26.11.2012
# File          : Makefile
# contents      : Generates a build system.make file for each designs and calls
#                 'make bistream' target.
################################################################################

VERSION = 0.1


##################################
# Directory structure
CNDK_DIR=../..
FPGA_DIR=$(CNDK_DIR)/fpga/xilinx

LX9_DIR=$(FPGA_DIR)/Avnet_lx9
LX150t_DIR=$(FPGA_DIR)/Avnet_lx150t
S6PLKEB_DIR=$(FPGA_DIR)/Avnet_s6plkeb

# lx9 designs
LX9_DIRECTIO_AXI=$(LX9_DIR)/micro_pcp_DirectIO-axi
LX9_DIRECTIO_PLB=$(LX9_DIR)/micro_pcp_DirectIO-plb

#lx150t designs
LX150t_INTAXI_AXI=$(LX150t_DIR)/iek_ap_pcp_intaxi-axi
LX150t_INTPLB_PLB=$(LX150t_DIR)/iek_ap_pcp_intplb-plb
LX150t_INTSPI_PLB=$(LX150t_DIR)/iek_ap_pcp_SPI-plb
LX150t_DIRECTIO_AXI=$(LX150t_DIR)/iek_pcp_DirectIO-axi
LX150t_DIRECTIO_PLB=$(LX150t_DIR)/iek_pcp_DirectIO-plb

#s6plkeb designs
S6PLKEB_16BITPRLL_AP__AXI=$(S6PLKEB_DIR)/s6plkeb_ap_16bitprll-axi
S6PLKEB_INTAXI_AXI=$(S6PLKEB_DIR)/s6plkeb_ap_pcp_intaxi-axi
S6PLKEB_INTPLB_PLB=$(S6PLKEB_DIR)/s6plkeb_ap_pcp_intplb-plb
S6PLKEB_16BITPRLL_PCP_AXI=$(S6PLKEB_DIR)/s6plkeb_pcp_16bitprll-axi
S6PLKEB_DIRECTIO_AXI=$(S6PLKEB_DIR)/s6plkeb_pcp_DirectIO-axi
S6PLKEB_DIRECTIO_PLB=$(S6PLKEB_DIR)/s6plkeb_pcp_DirectIO-plb

##################################
# Variables
MAKE=make
RM=rm -rf

##################################
# Rules

.PHONY:	header
header:
	@echo ""
	@echo "================================================================================"
	@echo " Build all examples - Build System (Xilinx)"
	@echo "================================================================================"
	@echo ""
	@echo " Copyright (c) 2012 B&R"
	@echo " Version $(VERSION)"
	@echo "================================================================================"
	@echo ""
	@echo "Write 'make all' to build all bitstreams of the examples designs"
	@echo "Write 'make lx9' to build all lx9 examples"
	@echo "Write 'make lx150t' to build all lx150t examples"
	@echo "Write 'make s6plkeb' to build all s6plkeb examples"
	@echo ""
	@echo "Write 'make clean' to remove all generated files"
	@echo "Write 'make clean_lx9' to remove all generated files from lx9 examples"
	@echo "Write 'make clean_lx150t' to remove all generated files from lx150t examples"
	@echo "Write 'make clean_s6plkeb' to remove all generated files from s6plkeb examples"

###################################
# BUILD RULES
###################################

# lx9 rules
lx9_directIO-axi:
	$(MAKE) -C $(LX9_DIRECTIO_AXI) all
	$(MAKE) -C $(LX9_DIRECTIO_AXI) -f system.make bits
	$(MAKE) -C $(LX9_DIRECTIO_AXI) -f system.make exporttosdk

lx9_directIO-plb:
	$(MAKE) -C $(LX9_DIRECTIO_PLB) all
	$(MAKE) -C $(LX9_DIRECTIO_PLB) -f system.make bits
	$(MAKE) -C $(LX9_DIRECTIO_PLB) -f system.make exporttosdk

# lx150t rules
lx150t_intaxi-axi:
	$(MAKE) -C $(LX150t_INTAXI_AXI) all
	$(MAKE) -C $(LX150t_INTAXI_AXI) -f system.make bits
	$(MAKE) -C $(LX150t_INTAXI_AXI) -f system.make exporttosdk

lx150t_intplb-plb:
	$(MAKE) -C $(LX150t_INTPLB_PLB) all
	$(MAKE) -C $(LX150t_INTPLB_PLB) -f system.make bits
	$(MAKE) -C $(LX150t_INTPLB_PLB) -f system.make exporttosdk

lx150t_intspi-plb:
	$(MAKE) -C $(LX150t_INTSPI_PLB) all
	$(MAKE) -C $(LX150t_INTSPI_PLB) -f system.make bits
	$(MAKE) -C $(LX150t_INTSPI_PLB) -f system.make exporttosdk

lx150t_directIO-axi:
	$(MAKE) -C $(LX150t_DIRECTIO_AXI) all
	$(MAKE) -C $(LX150t_DIRECTIO_AXI) -f system.make bits
	$(MAKE) -C $(LX150t_DIRECTIO_AXI) -f system.make exporttosdk


lx150t_directIO-plb:
	$(MAKE) -C $(LX150t_DIRECTIO_PLB) all
	$(MAKE) -C $(LX150t_DIRECTIO_PLB) -f system.make bits
	$(MAKE) -C $(LX150t_DIRECTIO_PLB) -f system.make exporttosdk

# s6plkeb rules
s6plkeb_16bitprll_ap_axi:
	$(MAKE) -C $(S6PLKEB_16BITPRLL_AP__AXI) all
	$(MAKE) -C $(S6PLKEB_16BITPRLL_AP__AXI) -f system.make bits
	$(MAKE) -C $(S6PLKEB_16BITPRLL_AP__AXI) -f system.make exporttosdk

s6plkeb_intaxi-axi:
	$(MAKE) -C $(S6PLKEB_INTAXI_AXI) all
	$(MAKE) -C $(S6PLKEB_INTAXI_AXI) -f system.make bits
	$(MAKE) -C $(S6PLKEB_INTAXI_AXI) -f system.make exporttosdk

s6plkeb_intplb-plb:
	$(MAKE) -C $(S6PLKEB_INTPLB_PLB) all
	$(MAKE) -C $(S6PLKEB_INTPLB_PLB) -f system.make bits
	$(MAKE) -C $(S6PLKEB_INTPLB_PLB) -f system.make exporttosdk

s6plkeb_16bitprll_pcp_axi:
	$(MAKE) -C $(S6PLKEB_16BITPRLL_PCP_AXI) all
	$(MAKE) -C $(S6PLKEB_16BITPRLL_PCP_AXI) -f system.make bits
	$(MAKE) -C $(S6PLKEB_16BITPRLL_PCP_AXI) -f system.make exporttosdk

s6plkeb_directIO-axi:
	$(MAKE) -C $(S6PLKEB_DIRECTIO_AXI) all
	$(MAKE) -C $(S6PLKEB_DIRECTIO_AXI) -f system.make bits
	$(MAKE) -C $(S6PLKEB_DIRECTIO_AXI) -f system.make exporttosdk

s6plkeb_directIO-plb:
	$(MAKE) -C $(S6PLKEB_DIRECTIO_PLB) all
	$(MAKE) -C $(S6PLKEB_DIRECTIO_PLB) -f system.make bits
	$(MAKE) -C $(S6PLKEB_DIRECTIO_PLB) -f system.make exporttosdk

####################################
# General rules
.PHONY: all
all: lx9 lx150t s6plkeb

.PHONY: lx9
lx9: lx9_directIO-axi lx9_directIO-plb

.PHONY: lx150t
lx150t: lx150t_intaxi-axi lx150t_intplb-plb lx150t_intspi-plb lx150t_directIO-axi lx150t_directIO-plb

.PHONY: s6plkeb
s6plkeb: s6plkeb_16bitprll_ap_axi s6plkeb_intaxi-axi s6plkeb_intplb-plb s6plkeb_16bitprll_pcp_axi s6plkeb_directIO-axi s6plkeb_directIO-plb

###################################
# CLEAN RULES
###################################
.PHONY: clean
clean: clean_lx9 clean_lx150t clean_s6plkeb

.PHONY: clean_lx9
clean_lx9:
	$(MAKE) -C $(LX9_DIRECTIO_PLB) all
	$(MAKE) -C $(LX9_DIRECTIO_PLB) -f system.make clean
	-$(RM) $(LX9_DIRECTIO_PLB)/system.make $(LX9_DIRECTIO_PLB)/SDK
	$(MAKE) -C $(LX9_DIRECTIO_AXI) all
	$(MAKE) -C $(LX9_DIRECTIO_AXI) -f system.make clean
	-$(RM) $(LX9_DIRECTIO_AXI)/system.make $(LX9_DIRECTIO_AXI)/SDK

.PHONY: clean_lx150t
clean_lx150t:
	$(MAKE) -C $(LX150t_INTAXI_AXI) all
	$(MAKE) -C $(LX150t_INTAXI_AXI) -f system.make clean
	-$(RM) $(LX150t_INTAXI_AXI)/system.make $(LX150t_INTAXI_AXI)/SDK
	$(MAKE) -C $(LX150t_INTPLB_PLB) all
	$(MAKE) -C $(LX150t_INTPLB_PLB) -f system.make clean
	-$(RM) $(LX150t_INTPLB_PLB)/system.make $(LX150t_INTPLB_PLB)/SDK
	$(MAKE) -C $(LX150t_INTSPI_PLB) all
	$(MAKE) -C $(LX150t_INTSPI_PLB) -f system.make clean
	-$(RM) $(LX150t_INTSPI_PLB)/system.make $(LX150t_INTSPI_PLB)/SDK
	$(MAKE) -C $(LX150t_DIRECTIO_AXI) all
	$(MAKE) -C $(LX150t_DIRECTIO_AXI) -f system.make clean
	-$(RM) $(LX150t_DIRECTIO_AXI)/system.make $(LX150t_DIRECTIO_AXI)/SDK
	$(MAKE) -C $(LX150t_DIRECTIO_PLB) all
	$(MAKE) -C $(LX150t_DIRECTIO_PLB) -f system.make clean
	-$(RM) $(LX150t_DIRECTIO_PLB)/system.make $(LX150t_DIRECTIO_PLB)/SDK

.PHONY: clean_s6plkeb
clean_s6plkeb:
	$(MAKE) -C $(S6PLKEB_16BITPRLL_AP__AXI) all
	$(MAKE) -C $(S6PLKEB_16BITPRLL_AP__AXI) -f system.make clean
	-$(RM) $(S6PLKEB_16BITPRLL_AP__AXI)/system.make $(S6PLKEB_16BITPRLL_AP__AXI)/SDK
	$(MAKE) -C $(S6PLKEB_INTAXI_AXI) all
	$(MAKE) -C $(S6PLKEB_INTAXI_AXI) -f system.make clean
	-$(RM) $(S6PLKEB_INTAXI_AXI)/system.make $(S6PLKEB_INTAXI_AXI)/SDK
	$(MAKE) -C $(S6PLKEB_INTPLB_PLB) all
	$(MAKE) -C $(S6PLKEB_INTPLB_PLB) -f system.make clean
	-$(RM) $(S6PLKEB_INTPLB_PLB)/system.make $(S6PLKEB_INTPLB_PLB)/SDK
	$(MAKE) -C $(S6PLKEB_16BITPRLL_PCP_AXI) all
	$(MAKE) -C $(S6PLKEB_16BITPRLL_PCP_AXI) -f system.make clean
	-$(RM) $(S6PLKEB_16BITPRLL_PCP_AXI)/system.make $(S6PLKEB_16BITPRLL_PCP_AXI)/SDK
	$(MAKE) -C $(S6PLKEB_DIRECTIO_AXI) all
	$(MAKE) -C $(S6PLKEB_DIRECTIO_AXI) -f system.make clean
	-$(RM) $(S6PLKEB_DIRECTIO_AXI)/system.make $(S6PLKEB_DIRECTIO_AXI)/SDK
	$(MAKE) -C $(S6PLKEB_DIRECTIO_PLB) all
	$(MAKE) -C $(S6PLKEB_DIRECTIO_PLB) -f system.make clean
	-$(RM) $(S6PLKEB_DIRECTIO_PLB)/system.make $(S6PLKEB_DIRECTIO_PLB)/SDK