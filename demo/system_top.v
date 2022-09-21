`timescale 1ns / 100ps

module system_top (

    // SFP / 10G Ethernet
    output OE_Si750,      // Enable Si750
    input  RefCLK_SFP_p,  // 156.250 MHz Refclk from SI750
    input  RefCLK_SFP_n,

    input  SFP0_RX_p,  // SFP0: 10G Ethernet #0
    input  SFP0_RX_n,
    output SFP0_TX_p,
    output SFP0_TX_n,

    input  SFP1_RX_p,  // SFP1: 10G Ethernet #1
    input  SFP1_RX_n,
    output SFP1_TX_p,
    output SFP1_TX_n,

    // PL CLOCK
    input CLK100_p,
    input CLK100_n
);

    assign OE_Si750 = 1'b1;

    // Sysclock IBUFDS instantiation
    wire sys_clk;

    IBUFGDS #(
        .DIFF_TERM("FALSE")
    ) u_ibufgds (
        .I (CLK100_p),
        .IB(CLK100_n),
        .O (sys_clk)
    );

    // System Reset
    reg [15:0] sys_rstn_cntr = ~0;
    always @(posedge sys_clk) begin
        if (sys_rstn_cntr != 0) begin
            sys_rstn_cntr <= sys_rstn_cntr - 1;
        end;
    end
    wire sys_rstn = sys_rstn_cntr == 0;

    system_wrapper i_system_wrapper (
        // 10G Ethernet
        .RefCLK_SFP_clk_n(RefCLK_SFP_n),
        .RefCLK_SFP_clk_p(RefCLK_SFP_p),

        .SFP_RX_gt_port_0_n(SFP0_RX_n),
        .SFP_RX_gt_port_0_p(SFP0_RX_p),
        .SFP_TX_gt_port_0_n(SFP0_TX_p),
        .SFP_TX_gt_port_0_p(SFP0_TX_n),

        .SFP_RX_gt_port_1_n(SFP1_RX_n),
        .SFP_RX_gt_port_1_p(SFP1_RX_p),
        .SFP_TX_gt_port_1_n(SFP1_TX_p),
        .SFP_TX_gt_port_1_p(SFP1_TX_n),

        // System
        .sys_clk (sys_clk),
        .sys_rstn(sys_rstn)
    );

endmodule

// ***************************************************************************
// ***************************************************************************
