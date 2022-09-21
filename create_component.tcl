# Close current open project
catch close_project

# Use script file location as working directory
cd [file dirname [file normalize [info script]]]

# Create Core
create_project nfmac10g_ip . -part xczu4ev-sfvc784-1-i -force

# Set IP repository paths
set obj [get_filesets sources_1]
set_property "ip_repo_paths" "[file normalize "[pwd]/.."]" $obj

# Rebuild user ip_repo's index before adding any source files
update_ip_catalog -rebuild

ipx::infer_core -verbose -vendor user.org -library user -name nfmac10g -taxonomy /UserIP ./src

ipx::infer_bus_interface tx_clk0 xilinx.com:signal:clock_rtl:1.0 [ipx::current_core]
ipx::infer_bus_interface rx_clk0 xilinx.com:signal:clock_rtl:1.0 [ipx::current_core]
ipx::associate_bus_interfaces -busif tx_axis -clock tx_clk0 [ipx::current_core]
ipx::associate_bus_interfaces -busif rx_axis -clock rx_clk0 [ipx::current_core]
ipx::update_source_project_archive -component [ipx::current_core]
ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]

# Rebuild user ip_repo's index before adding any source files
update_ip_catalog -rebuild
