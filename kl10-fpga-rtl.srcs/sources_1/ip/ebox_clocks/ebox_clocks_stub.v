// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2.1 (lin64) Build 2729669 Thu Dec  5 04:48:12 MST 2019
// Date        : Thu Jan 16 15:27:50 2020
// Host        : alanm running 64-bit Ubuntu 19.10
// Command     : write_verilog -force -mode synth_stub
//               /home/alan/kl10-fpga-rtl/kl10-fpga-rtl.srcs/sources_1/ip/ebox_clocks/ebox_clocks_stub.v
// Design      : ebox_clocks
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module ebox_clocks(eboxClk, fastMemClk, clk_in1)
/* synthesis syn_black_box black_box_pad_pin="eboxClk,fastMemClk,clk_in1" */;
  output eboxClk;
  output fastMemClk;
  input clk_in1;
endmodule
