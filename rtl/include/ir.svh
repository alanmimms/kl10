`ifndef _IR_INTERFACE_
 `define _IR_INTERFACE_ 1

interface iIR;
  logic ADeq0;
  logic IO_LEGAL;
  logic ADeq0;
  logic ACeq0;
  logic JRST0;
  logic TEST_SATISFIED;

  logic [8:10] NORM;
  logic [0:12] IR;
  logic [9:12] IRAC;
  logic [0:2] DRAM_A;
  logic [0:2] DRAM_B;
  logic [0:10] DRAM_J;
  logic DRAM_ODD_PARITY;
endinterface

`endif
