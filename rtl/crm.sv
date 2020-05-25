`timescale 1ns/1ns
`include "ebox.svh"

// M8548 CRM
//
// 2K words of CRAM storage.
//
// In a real KL10PV there are five instances of M8548. This is coded
// to act as all five slots.
module crm(iCLK CLK,
           iCRA CRA,
           iCRM CRM,
           iCRAM CRAM
           );

  bit [0:83] CRAMdata;

`ifdef KL10PV_TB
  sim_mem
    #(.SIZE(2048), .WIDTH(84), .NBYTES(1))
  cram
    (.clk(CLK.CRM),
     .din('0),                    // XXX
     .dout(CRAMdata),
     .addr(CRA.CRADR),
     .oe(1'b1),
     .wea(1'b0));                   // XXX
`else
  cram_mem cram(.clka(CLK.CRM),
                .addra(CRADR),
                .dina('0),
                .douta(CRAMdata),
                .wea(1'b0));
`endif

  assign CRAM.J = CRAMdata[1:11];
  assign CRAM.AD = CRAMdata[12:17];
  assign CRAM.ADA = CRAMdata[18:20];
  assign CRAM.ADB = CRAMdata[22:23];
  assign CRAM.AR = CRAMdata[24:26];
  assign CRAM.ARX = CRAMdata[27:29];
  assign CRAM.BR = CRAMdata[30:30];
  assign CRAM.BRX = CRAMdata[31:31];
  assign CRAM.MQ = CRAMdata[32:32];
  assign CRAM.FMADR = CRAMdata[33:35];
  assign CRAM.SCAD = CRAMdata[36:38];
  assign CRAM.SCADA = CRAMdata[39:41];
  assign CRAM.SCADB = CRAMdata[43:44];
  assign CRAM.SC = CRAMdata[46:46];
  assign CRAM.FE = CRAMdata[47:47];
  assign CRAM.SH = CRAMdata[49:50];
  assign CRAM.VMA = CRAMdata[52:53];
  assign CRAM._TIME = CRAMdata[54:55];
  assign CRAM.MEM = CRAMdata[56:59];
  assign CRAM.COND = CRAMdata[60:65];
  assign CRAM.CALL = CRAMdata[66:66];
  assign CRAM.DISP = CRAMdata[67:71];
  assign CRAM.SPEC = CRAMdata[67:71]; // ALIAS
  assign CRAM.MARK = CRAMdata[74:74];
  assign CRAM.MAGIC = CRAMdata[75:83];
endmodule
// Local Variables:
// verilog-library-files:("../ip/cram_mem/cram_mem_stub.v")
// End:
