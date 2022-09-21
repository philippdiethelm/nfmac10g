# ----------------------------------------------------------------------------------

# Enclustra Mercury XU-8
# xczu4cg-fbvb900-1-e

set_property BITSTREAM.CONFIG.OVERTEMPSHUTDOWN ENABLE [current_design]

# ----------------------------------------------------------------------------------
# Important! Do not remove this constraint!
# This property ensures that all unused pins are set to high impedance.
# If the constraint is removed, all unused pins have to be set to HiZ in the top level file.
set_property BITSTREAM.CONFIG.UNUSEDPIN PULLNONE [current_design]
# ----------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------------------
# PL CLK 100 (bank 65)
# -------------------------------------------------------------------------------------------------
set_property PACKAGE_PIN AH6 [get_ports CLK100_p]
set_property PACKAGE_PIN AJ6 [get_ports CLK100_n]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports CLK100_p]

create_clock -period 10.000 -name CLK100 [get_ports CLK100_p]
set_clock_groups -asynchronous -group [get_clocks CLK100 -include_generated_clocks]

# SFP ##################################################################################################
#
# -------------------------------------------------------------------------------------------------
# bank 66
# -------------------------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------------------
# bank 223
# -------------------------------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN V5} [get_ports SFP0_TX_p]       ; ## P/N Swapped at SFP Module (and XCVR tx_polarity_0)
set_property -dict {PACKAGE_PIN V6} [get_ports SFP0_TX_n]       ; ## P/N Swapped at SFP Module (and XCVR tx_polarity_0)
set_property -dict {PACKAGE_PIN U4} [get_ports SFP0_RX_p]
set_property -dict {PACKAGE_PIN U3} [get_ports SFP0_RX_n]

set_property -dict {PACKAGE_PIN W3} [get_ports SFP1_TX_p]       ; ## P/N Swapped at SFP Module (and XCVR tx_polarity_1)
set_property -dict {PACKAGE_PIN W4} [get_ports SFP1_TX_n]       ; ## P/N Swapped at SFP Module (and XCVR tx_polarity_1)
set_property -dict {PACKAGE_PIN V2} [get_ports SFP1_RX_p]
set_property -dict {PACKAGE_PIN V1} [get_ports SFP1_RX_n]

# Refclk clock constraints
set_property PACKAGE_PIN R7 [get_ports RefCLK_SFP_n]
set_property PACKAGE_PIN R8 [get_ports RefCLK_SFP_p]

set_property PACKAGE_PIN AB8 [get_ports OE_Si750]
set_property IOSTANDARD LVCMOS18 [get_ports OE_Si750]

