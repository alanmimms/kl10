// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2.1 (lin64) Build 2729669 Thu Dec  5 04:48:12 MST 2019
// Date        : Fri Jan 17 15:10:35 2020
// Host        : alanm running 64-bit Ubuntu 19.10
// Command     : write_verilog -force -mode synth_stub
//               /home/alan/kl10-fpga-rtl/kl10-fpga-rtl.srcs/sources_1/ip/fm_mem/fm_mem_stub.v
// Design      : fm_mem
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_4,Vivado 2019.2.1" *)
module fm_mem(clka, wea, addra, dina, douta)
/* synthesis syn_black_box black_box_pad_pin="clka,wea[3:0],addra[6:0],dina[35:0],douta[35:0]" */;
  input clka;
  input [3:0]wea;
  input [6:0]addra;
  input [35:0]dina;
  output [35:0]douta;
endmodule
