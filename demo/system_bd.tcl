
################################################################
# This is a generated script based on design: system
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2021.1
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source system_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xczu4cg-fbvb900-1-e
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name system

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:axis_data_fifo:2.0\
xilinx.com:ip:xlconstant:1.1\
xilinx.com:ip:proc_sys_reset:5.0\
xilinx.com:ip:xxv_ethernet:4.0\
user.org:user:nfmac10g:1.0\
xilinx.com:ip:util_vector_logic:2.0\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: nfmac_eth1
proc create_hier_cell_nfmac_eth1 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_nfmac_eth1() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 rx_axis_0

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 tx_axis_0


  # Create pins
  create_bd_pin -dir I -type clk eth_clk
  create_bd_pin -dir O -from 0 -to 0 rx_axis_aresetn
  create_bd_pin -dir I -from 0 -to 0 user_rx_reset
  create_bd_pin -dir I -from 0 -to 0 user_tx_reset
  create_bd_pin -dir I -from 7 -to 0 xgmii_rxc
  create_bd_pin -dir I -from 63 -to 0 xgmii_rxd
  create_bd_pin -dir O -from 7 -to 0 xgmii_txc
  create_bd_pin -dir O -from 63 -to 0 xgmii_txd

  # Create instance: const_0, and set properties
  set const_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 const_0 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
 ] $const_0

  # Create instance: const_16x0, and set properties
  set const_16x0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 const_16x0 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
   CONFIG.CONST_WIDTH {16} \
 ] $const_16x0

  # Create instance: const_80x0, and set properties
  set const_80x0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 const_80x0 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
   CONFIG.CONST_WIDTH {80} \
 ] $const_80x0

  # Create instance: const_8x0, and set properties
  set const_8x0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 const_8x0 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
   CONFIG.CONST_WIDTH {8} \
 ] $const_8x0

  # Create instance: nfmac10g_0, and set properties
  set nfmac10g_0 [ create_bd_cell -type ip -vlnv user.org:user:nfmac10g:1.0 nfmac10g_0 ]

  # Create instance: rx_rstn, and set properties
  set rx_rstn [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 rx_rstn ]
  set_property -dict [ list \
   CONFIG.C_OPERATION {not} \
   CONFIG.C_SIZE {1} \
   CONFIG.LOGO_FILE {data/sym_notgate.png} \
 ] $rx_rstn

  # Create instance: tx_rstn, and set properties
  set tx_rstn [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 tx_rstn ]
  set_property -dict [ list \
   CONFIG.C_OPERATION {not} \
   CONFIG.C_SIZE {1} \
   CONFIG.LOGO_FILE {data/sym_notgate.png} \
 ] $tx_rstn

  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins rx_axis_0] [get_bd_intf_pins nfmac10g_0/rx_axis]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins tx_axis_0] [get_bd_intf_pins nfmac10g_0/tx_axis]

  # Create port connections
  connect_bd_net -net Op1_1 [get_bd_pins user_rx_reset] [get_bd_pins rx_rstn/Op1]
  connect_bd_net -net Op2_1 [get_bd_pins user_tx_reset] [get_bd_pins tx_rstn/Op1]
  connect_bd_net -net const_0_dout [get_bd_pins const_0/dout] [get_bd_pins nfmac10g_0/pause_req] [get_bd_pins nfmac10g_0/reset]
  connect_bd_net -net const_16x0_dout [get_bd_pins const_16x0/dout] [get_bd_pins nfmac10g_0/pause_val]
  connect_bd_net -net const_80x0_dout [get_bd_pins const_80x0/dout] [get_bd_pins nfmac10g_0/rx_configuration_vector] [get_bd_pins nfmac10g_0/tx_configuration_vector]
  connect_bd_net -net const_8x0_dout [get_bd_pins const_8x0/dout] [get_bd_pins nfmac10g_0/tx_ifg_delay]
  connect_bd_net -net nfmac10g_0_xgmii_txc [get_bd_pins xgmii_txc] [get_bd_pins nfmac10g_0/xgmii_txc]
  connect_bd_net -net nfmac10g_0_xgmii_txd [get_bd_pins xgmii_txd] [get_bd_pins nfmac10g_0/xgmii_txd]
  connect_bd_net -net rx_rstn_Res [get_bd_pins rx_axis_aresetn] [get_bd_pins nfmac10g_0/rx_axis_aresetn] [get_bd_pins nfmac10g_0/rx_dcm_locked] [get_bd_pins rx_rstn/Res]
  connect_bd_net -net tx_rstn_Res [get_bd_pins nfmac10g_0/tx_axis_aresetn] [get_bd_pins nfmac10g_0/tx_dcm_locked] [get_bd_pins tx_rstn/Res]
  connect_bd_net -net xgmii_rxc_1 [get_bd_pins xgmii_rxc] [get_bd_pins nfmac10g_0/xgmii_rxc]
  connect_bd_net -net xgmii_rxd_1 [get_bd_pins xgmii_rxd] [get_bd_pins nfmac10g_0/xgmii_rxd]
  connect_bd_net -net xxv_ethernet_0_tx_mii_clk_0 [get_bd_pins eth_clk] [get_bd_pins nfmac10g_0/rx_clk0] [get_bd_pins nfmac10g_0/tx_clk0]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: nfmac_eth0
proc create_hier_cell_nfmac_eth0 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_nfmac_eth0() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 rx_axis_0

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 tx_axis_0


  # Create pins
  create_bd_pin -dir I -type clk eth_clk
  create_bd_pin -dir O -from 0 -to 0 rx_axis_aresetn
  create_bd_pin -dir I -from 0 -to 0 user_rx_reset
  create_bd_pin -dir I -from 0 -to 0 user_tx_reset
  create_bd_pin -dir I -from 7 -to 0 xgmii_rxc
  create_bd_pin -dir I -from 63 -to 0 xgmii_rxd
  create_bd_pin -dir O -from 7 -to 0 xgmii_txc
  create_bd_pin -dir O -from 63 -to 0 xgmii_txd

  # Create instance: const_0, and set properties
  set const_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 const_0 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
 ] $const_0

  # Create instance: const_16x0, and set properties
  set const_16x0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 const_16x0 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
   CONFIG.CONST_WIDTH {16} \
 ] $const_16x0

  # Create instance: const_80x0, and set properties
  set const_80x0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 const_80x0 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
   CONFIG.CONST_WIDTH {80} \
 ] $const_80x0

  # Create instance: const_8x0, and set properties
  set const_8x0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 const_8x0 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
   CONFIG.CONST_WIDTH {8} \
 ] $const_8x0

  # Create instance: nfmac10g_0, and set properties
  set nfmac10g_0 [ create_bd_cell -type ip -vlnv user.org:user:nfmac10g:1.0 nfmac10g_0 ]

  # Create instance: rx_rstn, and set properties
  set rx_rstn [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 rx_rstn ]
  set_property -dict [ list \
   CONFIG.C_OPERATION {not} \
   CONFIG.C_SIZE {1} \
   CONFIG.LOGO_FILE {data/sym_notgate.png} \
 ] $rx_rstn

  # Create instance: tx_rstn, and set properties
  set tx_rstn [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 tx_rstn ]
  set_property -dict [ list \
   CONFIG.C_OPERATION {not} \
   CONFIG.C_SIZE {1} \
   CONFIG.LOGO_FILE {data/sym_notgate.png} \
 ] $tx_rstn

  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins rx_axis_0] [get_bd_intf_pins nfmac10g_0/rx_axis]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins tx_axis_0] [get_bd_intf_pins nfmac10g_0/tx_axis]

  # Create port connections
  connect_bd_net -net Op1_1 [get_bd_pins user_rx_reset] [get_bd_pins rx_rstn/Op1]
  connect_bd_net -net Op2_1 [get_bd_pins user_tx_reset] [get_bd_pins tx_rstn/Op1]
  connect_bd_net -net const_0x0000_dout [get_bd_pins const_16x0/dout] [get_bd_pins nfmac10g_0/pause_val]
  connect_bd_net -net const_80x0_dout [get_bd_pins const_80x0/dout] [get_bd_pins nfmac10g_0/rx_configuration_vector] [get_bd_pins nfmac10g_0/tx_configuration_vector]
  connect_bd_net -net nfmac10g_0_xgmii_txc [get_bd_pins xgmii_txc] [get_bd_pins nfmac10g_0/xgmii_txc]
  connect_bd_net -net nfmac10g_0_xgmii_txd [get_bd_pins xgmii_txd] [get_bd_pins nfmac10g_0/xgmii_txd]
  connect_bd_net -net rx_rstn_Res [get_bd_pins rx_axis_aresetn] [get_bd_pins nfmac10g_0/rx_axis_aresetn] [get_bd_pins nfmac10g_0/rx_dcm_locked] [get_bd_pins rx_rstn/Res]
  connect_bd_net -net tx_rstn_Res [get_bd_pins nfmac10g_0/tx_axis_aresetn] [get_bd_pins nfmac10g_0/tx_dcm_locked] [get_bd_pins tx_rstn/Res]
  connect_bd_net -net xgmii_rxc_1 [get_bd_pins xgmii_rxc] [get_bd_pins nfmac10g_0/xgmii_rxc]
  connect_bd_net -net xgmii_rxd_1 [get_bd_pins xgmii_rxd] [get_bd_pins nfmac10g_0/xgmii_rxd]
  connect_bd_net -net xlconstant_0_dout [get_bd_pins const_0/dout] [get_bd_pins nfmac10g_0/pause_req] [get_bd_pins nfmac10g_0/reset]
  connect_bd_net -net xlconstant_1_dout [get_bd_pins const_8x0/dout] [get_bd_pins nfmac10g_0/tx_ifg_delay]
  connect_bd_net -net xxv_ethernet_0_tx_mii_clk_0 [get_bd_pins eth_clk] [get_bd_pins nfmac10g_0/rx_clk0] [get_bd_pins nfmac10g_0/tx_clk0]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set RefCLK_SFP [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 RefCLK_SFP ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {156250000} \
   ] $RefCLK_SFP

  set SFP_RX [ create_bd_intf_port -mode Slave -vlnv xilinx.com:display_xxv_ethernet:gt_ports:2.0 SFP_RX ]

  set SFP_TX [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_xxv_ethernet:gt_ports:2.0 SFP_TX ]


  # Create ports
  set eth0_clk [ create_bd_port -dir O -type clk eth0_clk ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {} \
 ] $eth0_clk
  set eth1_clk [ create_bd_port -dir O -type clk eth1_clk ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {} \
 ] $eth1_clk
  set sys_clk [ create_bd_port -dir I -type clk -freq_hz 100000000 sys_clk ]
  set sys_rstn [ create_bd_port -dir I -type rst sys_rstn ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_LOW} \
 ] $sys_rstn

  # Create instance: axis_data_fifo_0, and set properties
  set axis_data_fifo_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 axis_data_fifo_0 ]
  set_property -dict [ list \
   CONFIG.FIFO_MODE {2} \
   CONFIG.IS_ACLK_ASYNC {1} \
 ] $axis_data_fifo_0

  # Create instance: axis_data_fifo_1, and set properties
  set axis_data_fifo_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 axis_data_fifo_1 ]
  set_property -dict [ list \
   CONFIG.FIFO_MODE {2} \
   CONFIG.IS_ACLK_ASYNC {1} \
 ] $axis_data_fifo_1

  # Create instance: gnd, and set properties
  set gnd [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 gnd ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
 ] $gnd

  # Create instance: loopback_NORMAL_OP, and set properties
  set loopback_NORMAL_OP [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 loopback_NORMAL_OP ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
   CONFIG.CONST_WIDTH {3} \
 ] $loopback_NORMAL_OP

  # Create instance: nfmac_eth0
  create_hier_cell_nfmac_eth0 [current_bd_instance .] nfmac_eth0

  # Create instance: nfmac_eth1
  create_hier_cell_nfmac_eth1 [current_bd_instance .] nfmac_eth1

  # Create instance: outclk_TXPROGDIVCLK, and set properties
  set outclk_TXPROGDIVCLK [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 outclk_TXPROGDIVCLK ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {5} \
   CONFIG.CONST_WIDTH {3} \
 ] $outclk_TXPROGDIVCLK

  # Create instance: sys_rstgen, and set properties
  set sys_rstgen [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 sys_rstgen ]
  set_property -dict [ list \
   CONFIG.C_EXT_RST_WIDTH {1} \
 ] $sys_rstgen

  # Create instance: sys_rstgen1, and set properties
  set sys_rstgen1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 sys_rstgen1 ]
  set_property -dict [ list \
   CONFIG.C_EXT_RST_WIDTH {1} \
 ] $sys_rstgen1

  # Create instance: sys_rstgen2, and set properties
  set sys_rstgen2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 sys_rstgen2 ]
  set_property -dict [ list \
   CONFIG.C_EXT_RST_WIDTH {1} \
 ] $sys_rstgen2

  # Create instance: vcc, and set properties
  set vcc [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 vcc ]

  # Create instance: xxv_ethernet_0, and set properties
  set xxv_ethernet_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xxv_ethernet:4.0 xxv_ethernet_0 ]
  set_property -dict [ list \
   CONFIG.ADD_GT_CNTRL_STS_PORTS {1} \
   CONFIG.BASE_R_KR {BASE-R} \
   CONFIG.CORE {Ethernet PCS/PMA 64-bit} \
   CONFIG.DATA_PATH_INTERFACE {MII} \
   CONFIG.ENABLE_PIPELINE_REG {1} \
   CONFIG.INCLUDE_AXI4_INTERFACE {0} \
   CONFIG.INCLUDE_STATISTICS_COUNTERS {0} \
   CONFIG.INCLUDE_USER_FIFO {0} \
   CONFIG.LANE2_GT_LOC {X0Y1} \
   CONFIG.NUM_OF_CORES {2} \
 ] $xxv_ethernet_0

  # Create interface connections
  connect_bd_intf_net -intf_net RefCLK_SFP_1 [get_bd_intf_ports RefCLK_SFP] [get_bd_intf_pins xxv_ethernet_0/gt_ref_clk]
  connect_bd_intf_net -intf_net SFP_RX_1 [get_bd_intf_ports SFP_RX] [get_bd_intf_pins xxv_ethernet_0/gt_rx]
  connect_bd_intf_net -intf_net axis_data_fifo_0_M_AXIS [get_bd_intf_pins axis_data_fifo_0/M_AXIS] [get_bd_intf_pins nfmac_eth1/tx_axis_0]
  connect_bd_intf_net -intf_net axis_data_fifo_1_M_AXIS [get_bd_intf_pins axis_data_fifo_1/M_AXIS] [get_bd_intf_pins nfmac_eth0/tx_axis_0]
  connect_bd_intf_net -intf_net eth_10g_xcvr_x2_gt_tx [get_bd_intf_ports SFP_TX] [get_bd_intf_pins xxv_ethernet_0/gt_tx]
  connect_bd_intf_net -intf_net nfmac_eth0_rx_axis_0 [get_bd_intf_pins axis_data_fifo_0/S_AXIS] [get_bd_intf_pins nfmac_eth0/rx_axis_0]
  connect_bd_intf_net -intf_net nfmac_eth1_rx_axis_0 [get_bd_intf_pins axis_data_fifo_1/S_AXIS] [get_bd_intf_pins nfmac_eth1/rx_axis_0]

  # Create port connections
  connect_bd_net -net const_6_dout [get_bd_pins loopback_NORMAL_OP/dout] [get_bd_pins xxv_ethernet_0/gt_loopback_in_0] [get_bd_pins xxv_ethernet_0/gt_loopback_in_1]
  connect_bd_net -net eth_10g_xcvr_x2_eth_clk [get_bd_ports eth0_clk] [get_bd_pins axis_data_fifo_0/s_axis_aclk] [get_bd_pins axis_data_fifo_1/m_axis_aclk] [get_bd_pins nfmac_eth0/eth_clk] [get_bd_pins sys_rstgen1/slowest_sync_clk] [get_bd_pins xxv_ethernet_0/rx_core_clk_0] [get_bd_pins xxv_ethernet_0/tx_mii_clk_0]
  connect_bd_net -net eth_10g_xcvr_x2_rx_mii_c_0 [get_bd_pins nfmac_eth0/xgmii_rxc] [get_bd_pins xxv_ethernet_0/rx_mii_c_0]
  connect_bd_net -net eth_10g_xcvr_x2_rx_mii_d_0 [get_bd_pins nfmac_eth0/xgmii_rxd] [get_bd_pins xxv_ethernet_0/rx_mii_d_0]
  connect_bd_net -net eth_10g_xcvr_x2_user_rx_reset_0 [get_bd_pins nfmac_eth0/user_rx_reset] [get_bd_pins xxv_ethernet_0/user_rx_reset_0]
  connect_bd_net -net eth_10g_xcvr_x2_user_tx_reset_0 [get_bd_pins nfmac_eth0/user_tx_reset] [get_bd_pins xxv_ethernet_0/user_tx_reset_0]
  connect_bd_net -net gtwiz_reset_rx_datapath_0_1 [get_bd_pins sys_rstgen/peripheral_reset] [get_bd_pins xxv_ethernet_0/gt_drprst_0] [get_bd_pins xxv_ethernet_0/gt_drprst_1] [get_bd_pins xxv_ethernet_0/gtwiz_reset_rx_datapath_0] [get_bd_pins xxv_ethernet_0/gtwiz_reset_rx_datapath_1] [get_bd_pins xxv_ethernet_0/gtwiz_reset_tx_datapath_0] [get_bd_pins xxv_ethernet_0/gtwiz_reset_tx_datapath_1] [get_bd_pins xxv_ethernet_0/qpllreset_in_0] [get_bd_pins xxv_ethernet_0/sys_reset]
  connect_bd_net -net m_axi_mm2s_aclk_1 [get_bd_ports eth1_clk] [get_bd_pins axis_data_fifo_0/m_axis_aclk] [get_bd_pins axis_data_fifo_1/s_axis_aclk] [get_bd_pins nfmac_eth1/eth_clk] [get_bd_pins sys_rstgen2/slowest_sync_clk] [get_bd_pins xxv_ethernet_0/rx_core_clk_1] [get_bd_pins xxv_ethernet_0/tx_mii_clk_1]
  connect_bd_net -net nfmac_eth0_Res [get_bd_pins axis_data_fifo_0/s_axis_aresetn] [get_bd_pins nfmac_eth0/rx_axis_aresetn]
  connect_bd_net -net nfmac_eth1_Res [get_bd_pins axis_data_fifo_1/s_axis_aresetn] [get_bd_pins nfmac_eth1/rx_axis_aresetn]
  connect_bd_net -net nfmac_eth1_xgmii_txc [get_bd_pins nfmac_eth1/xgmii_txc] [get_bd_pins xxv_ethernet_0/tx_mii_c_1]
  connect_bd_net -net nfmac_eth1_xgmii_txd [get_bd_pins nfmac_eth1/xgmii_txd] [get_bd_pins xxv_ethernet_0/tx_mii_d_1]
  connect_bd_net -net rxoutclksel_in_0_1 [get_bd_pins outclk_TXPROGDIVCLK/dout] [get_bd_pins xxv_ethernet_0/rxoutclksel_in_0] [get_bd_pins xxv_ethernet_0/rxoutclksel_in_1] [get_bd_pins xxv_ethernet_0/txoutclksel_in_0] [get_bd_pins xxv_ethernet_0/txoutclksel_in_1]
  connect_bd_net -net sys_cpu_clk [get_bd_ports sys_clk] [get_bd_pins sys_rstgen/slowest_sync_clk] [get_bd_pins xxv_ethernet_0/dclk] [get_bd_pins xxv_ethernet_0/gt_drpclk_0] [get_bd_pins xxv_ethernet_0/gt_drpclk_1]
  connect_bd_net -net sys_rstgen1_peripheral_reset [get_bd_pins sys_rstgen1/peripheral_reset] [get_bd_pins xxv_ethernet_0/rx_reset_0] [get_bd_pins xxv_ethernet_0/tx_reset_0]
  connect_bd_net -net sys_rstgen2_peripheral_reset [get_bd_pins sys_rstgen2/peripheral_reset] [get_bd_pins xxv_ethernet_0/rx_reset_1] [get_bd_pins xxv_ethernet_0/tx_reset_1]
  connect_bd_net -net sys_rstn_1 [get_bd_ports sys_rstn] [get_bd_pins sys_rstgen/ext_reset_in] [get_bd_pins sys_rstgen1/ext_reset_in] [get_bd_pins sys_rstgen2/ext_reset_in]
  connect_bd_net -net tx_mii_c_0_1 [get_bd_pins nfmac_eth0/xgmii_txc] [get_bd_pins xxv_ethernet_0/tx_mii_c_0]
  connect_bd_net -net tx_mii_d_0_1 [get_bd_pins nfmac_eth0/xgmii_txd] [get_bd_pins xxv_ethernet_0/tx_mii_d_0]
  connect_bd_net -net user_rx_reset_1 [get_bd_pins nfmac_eth1/user_rx_reset] [get_bd_pins xxv_ethernet_0/user_rx_reset_1]
  connect_bd_net -net user_tx_reset_1 [get_bd_pins nfmac_eth1/user_tx_reset] [get_bd_pins xxv_ethernet_0/user_tx_reset_1]
  connect_bd_net -net xgmii_rxc_1 [get_bd_pins nfmac_eth1/xgmii_rxc] [get_bd_pins xxv_ethernet_0/rx_mii_c_1]
  connect_bd_net -net xgmii_rxd_1 [get_bd_pins nfmac_eth1/xgmii_rxd] [get_bd_pins xxv_ethernet_0/rx_mii_d_1]
  connect_bd_net -net xlconstant_0_dout [get_bd_pins gnd/dout] [get_bd_pins xxv_ethernet_0/ctl_tx_data_pattern_select_0] [get_bd_pins xxv_ethernet_0/ctl_tx_data_pattern_select_1] [get_bd_pins xxv_ethernet_0/ctl_tx_prbs31_test_pattern_enable_0] [get_bd_pins xxv_ethernet_0/ctl_tx_prbs31_test_pattern_enable_1] [get_bd_pins xxv_ethernet_0/ctl_tx_test_pattern_0] [get_bd_pins xxv_ethernet_0/ctl_tx_test_pattern_1] [get_bd_pins xxv_ethernet_0/ctl_tx_test_pattern_enable_0] [get_bd_pins xxv_ethernet_0/ctl_tx_test_pattern_enable_1] [get_bd_pins xxv_ethernet_0/ctl_tx_test_pattern_select_0] [get_bd_pins xxv_ethernet_0/ctl_tx_test_pattern_select_1] [get_bd_pins xxv_ethernet_0/gt_txelecidle_0] [get_bd_pins xxv_ethernet_0/gt_txelecidle_1]
  connect_bd_net -net xlconstant_1_dout [get_bd_pins vcc/dout] [get_bd_pins xxv_ethernet_0/gt_txpolarity_0] [get_bd_pins xxv_ethernet_0/gt_txpolarity_1]

  # Create address segments


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


