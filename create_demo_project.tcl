# Typical usage: vivado -mode tcl -source demo_prj.tcl

# Close current open project
catch close_project

# Use script file location as working directory
cd [file dirname [file normalize [info script]]]

# Create the project and directory structure
create_project -force demo_prj ./demo_prj -part xczu4cg-fbvb900-1-e

# Set IP repository paths
set obj [get_filesets sources_1]
set_property "ip_repo_paths" "[file normalize "./"]" $obj

# Rebuild user ip_repo's index before adding any source files
update_ip_catalog -rebuild

#
# Add various sources to the project
add_files {./demo/system_top.v}
add_files -fileset constrs_1 ./demo/sfp.xdc

source ./demo/system_bd.tcl

set_property REGISTERED_WITH_MANAGER "1" [get_files system.bd ] 
set_property SYNTH_CHECKPOINT_MODE "Hierarchical" [get_files system.bd ] 

make_wrapper -files [get_files system.bd] -top
add_files -norecurse [file normalize "./demo_prj/demo_prj.srcs/sources_1/bd/system/hdl/system_wrapper.v" ]
update_compile_order -fileset sources_1
