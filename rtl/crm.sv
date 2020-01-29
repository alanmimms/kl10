`timescale 1ns/1ns
`include "cram-defs.svh"

// M8548 CRM
//
// 2K words of CRAM storage.
//
// In a real KL10PV there are five instances of M8548. This is coded
// to act as all five slots.
module crm(input eboxClk,
           tCRADR CRADR,
           iCRAM CRAM);

  logic [0:83] CRAMdata;

`ifdef KL10PV_TB
  sim_mem
    #(.SIZE(2048), .WIDTH(84), .NBYTES(1))
  cram
  (.clk(eboxClk),
   .din('0),                    // XXX
   .dout(CRAMdata),
   .addr(CRADR),
   .wea('0));                   // XXX
`else
  cram_mem cram(.clka(eboxClk),
                .addra(CRADR),
                .dina('0),
                .douta(CRAMdata),
                .wea('0));
`endif

  always_comb begin
    CRAM.J = tJ'(CRAMdata[1:11]);
    CRAM.AD = tAD'(CRAMdata[12:17]);
    CRAM.ADA = tADA'(CRAMdata[18:20]);
    CRAM.ADB = tADB'(CRAMdata[22:23]);
    CRAM.AR = tAR'(CRAMdata[24:26]);
    CRAM.ARX = tARX'(CRAMdata[27:29]);
    CRAM.BR = tBR'(CRAMdata[30:30]);
    CRAM.BRX = tBRX'(CRAMdata[31:31]);
    CRAM.MQ = tMQ'(CRAMdata[32:32]);
    CRAM.FMADR = tFMADR'(CRAMdata[33:35]);
    CRAM.SCAD = tSCAD'(CRAMdata[36:38]);
    CRAM.SCADA = tSCADA'(CRAMdata[39:41]);
    CRAM.SCADB = tSCADB'(CRAMdata[43:44]);
    CRAM.SC = tSC'(CRAMdata[46:46]);
    CRAM.FE = tFE'(CRAMdata[47:47]);
    CRAM.SH = tSH'(CRAMdata[49:50]);
    CRAM.VMA = tVMA'(CRAMdata[52:53]);
    CRAM.TIME = tTIME'(CRAMdata[54:55]);
    CRAM.MEM = tMEM'(CRAMdata[56:59]);
    CRAM.COND = tCOND'(CRAMdata[60:65]);
    CRAM.CALL = CRAMdata[66:66];
    CRAM.DISP = tDISP'(CRAMdata[67:71]);
    CRAM.MARK = CRAMdata[74:74];
    CRAM.MAGIC = tMAGIC'(CRAMdata[75:83]);
  end
endmodule
// Local Variables:
// verilog-library-files:("../ip/cram_mem/cram_mem_stub.v")
// End:
