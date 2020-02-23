`timescale 1ns/1ns
// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2 (lin64) Build 2708876 Wed Nov  6 21:39:14 MST 2019
// Date        : Tue Jan 28 12:50:23 2020
// Host        : alanm running 64-bit Ubuntu 19.10
// Command     : write_verilog -force -mode synth_stub
//               /home/alan/kl10-rtl/kl10-rtl.runs/ebox_clocks_synth_1/ebox_clocks_stub.v
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


// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2 (lin64) Build 2708876 Wed Nov  6 21:39:14 MST 2019
// Date        : Mon Jan 27 11:55:11 2020
// Host        : alanm running 64-bit Ubuntu 19.10
// Command     : write_verilog -force -mode synth_stub
//               /home/alan/kl10-rtl/kl10-rtl.runs/cram_mem_synth_1/cram_mem_stub.v
// Design      : cram_mem
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_4,Vivado 2019.2" *)
module cram_mem(clka, wea, addra, dina, douta)
/* synthesis syn_black_box black_box_pad_pin="clka,wea[0:0],addra[10:0],dina[83:0],douta[83:0]" */;
  input clka;
  input [0:0]wea;
  input [10:0]addra;
  input [83:0]dina;
  output [83:0]douta;
endmodule


// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2.1 (lin64) Build 2729669 Thu Dec  5 04:48:12 MST 2019
// Date        : Thu Jan 16 13:10:10 2020
// Host        : alanm running 64-bit Ubuntu 19.10
// Command     : write_verilog -force -mode synth_stub
//               /home/alan/kl10-rtl/kl10-rtl.srcs/sources_1/ip/dram_mem/dram_mem_stub.v
// Design      : dram_mem
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_4,Vivado 2019.2.1" *)
module dram_mem(clka, ena, wea, addra, dina, douta)
/* synthesis syn_black_box black_box_pad_pin="clka,ena,wea[0:0],addra[8:0],dina[14:0],douta[14:0]" */;
  input clka;
  input ena;
  input [0:0]wea;
  input [8:0]addra;
  input [14:0]dina;
  output [14:0]douta;
endmodule


// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2.1 (lin64) Build 2729669 Thu Dec  5 04:48:12 MST 2019
// Date        : Mon Jan 13 17:26:28 2020
// Host        : alanm running 64-bit Ubuntu 19.10
// Command     : write_verilog -force -mode synth_stub -rename_top fake_mem -prefix
//               fake_mem_ FAKE_MEM_stub.v
// Design      : FAKE_MEM
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_4,Vivado 2019.2.1" *)
module fake_mem(clka, ena, wea, addra, dina, douta)
/* synthesis syn_black_box black_box_pad_pin="clka,ena,wea[0:0],addra[11:0],dina[35:0],douta[35:0]" */;
  input clka;
  input ena;
  input [0:0]wea;
  input [11:0]addra;
  input [35:0]dina;
  output [35:0]douta;
endmodule


// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2 (lin64) Build 2708876 Wed Nov  6 21:39:14 MST 2019
// Date        : Mon Jan 27 15:35:59 2020
// Host        : alanm running 64-bit Ubuntu 19.10
// Command     : write_verilog -force -mode synth_stub
//               /home/alan/kl10-rtl/kl10-rtl.runs/fm_mem_synth_1/fm_mem_stub.v
// Design      : fm_mem
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_4,Vivado 2019.2" *)
module fm_mem(clka, wea, addra, dina, douta)
/* synthesis syn_black_box black_box_pad_pin="clka,wea[3:0],addra[6:0],dina[35:0],douta[35:0]" */;
  input clka;
  input [3:0]wea;
  input [6:0]addra;
  input [35:0]dina;
  output [35:0]douta;
endmodule

// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2 (lin64) Build 2708876 Wed Nov  6 21:39:14 MST 2019
// Date        : Sun Feb 23 11:22:30 2020
// Host        : alanm running 64-bit Ubuntu 19.10
// Command     : write_verilog -force -mode synth_stub /home/alan/kl10/kl10.runs/kl_delays_synth_1/kl_delays_stub.v
// Design      : kl_delays
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module kl_delays(ph5, ph10, ph20, ph30, ph40, ph50, ph60, locked, clk_in1)
/* synthesis syn_black_box black_box_pad_pin="ph5,ph10,ph20,ph30,ph40,ph50,ph60,locked,clk_in1" */;
  output ph5;
  output ph10;
  output ph20;
  output ph30;
  output ph40;
  output ph50;
  output ph60;
  output locked;
  input clk_in1;
endmodule
