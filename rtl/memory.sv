`timescale 1ns/1ns
`include "ebox.svh"

// This module pretends to be a MF20 MOS memory.
module memory(iSBUS SBUS);

  bit [0:35] dataIn, dataOut;
  bit read, write;

`ifdef KL10PV_TB
  sim_mem
    #(.SIZE(4096), .WIDTH(36), .NBYTES(1))
  mem0
  (.clk(SBUS.CLK_EXT),
   .din(dataIn),
   .dout(dataOut),
   .addr(SBUS.ADR[24:35]),
   .wea(1'b0));                 // XXX Fix this

  always_comb begin

  end
`else
`endif

endmodule


