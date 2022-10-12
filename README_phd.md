# NFMAC10G modified by phd

## Notes
- Updated to use Xilinx Vivado 2021.1

## VHDL port status
Done:
- NFMAC10G core ported to VHDL
- TX seems to work
- RX mostly untested

Todo:
- Test Tx and Rx
- Fix simulation and cross-check with verilog implementation

## Simulation
Done:
- Verilog simulation fixed to run with Vivado 2021.1
- Also fixed SystemVerilog name collisions to get simulation going

Todo:
- Use existinbg simulation to cross check with VHDL implementation

## Plan
- use GHDL / Osvvm testbench for new VHDL simulation
