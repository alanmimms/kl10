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

  logic [0:83] CRAMdata;

  // XXX required to get CLK to run
  initial begin
    CRAMdata = '0;
  end

`ifdef KL10PV_TB
  sim_mem
    #(.SIZE(2048), .WIDTH(84), .NBYTES(1))
  cram
    (.clk(CLK.CRM),
     .din('0),                    // XXX
     .dout(CRAMdata),
     .addr(CRA.CRADR),
     .wea('0));                   // XXX
`else
  cram_mem cram(.clka(CLK.CRM),
                .addra(CRADR),
                .dina('0),
                .douta(CRAMdata),
                .wea('0));
`endif

  assign CRAM.J = tJ'(CRAMdata[1:11]);
  assign CRAM.AD = tAD'(CRAMdata[12:17]);
  assign CRAM.ADA = tADA'(CRAMdata[18:20]);
  assign CRAM.ADB = tADB'(CRAMdata[22:23]);
  assign CRAM.AR = tAR'(CRAMdata[24:26]);
  assign CRAM.ARX = tARX'(CRAMdata[27:29]);
  assign CRAM.BR = tBR'(CRAMdata[30:30]);
  assign CRAM.BRX = tBRX'(CRAMdata[31:31]);
  assign CRAM.MQ = tMQ'(CRAMdata[32:32]);
  assign CRAM.FMADR = tFMADR'(CRAMdata[33:35]);
  assign CRAM.SCAD = tSCAD'(CRAMdata[36:38]);
  assign CRAM.SCADA = tSCADA'(CRAMdata[39:41]);
  assign CRAM.SCADB = tSCADB'(CRAMdata[43:44]);
  assign CRAM.SC = tSC'(CRAMdata[46:46]);
  assign CRAM.FE = tFE'(CRAMdata[47:47]);
  assign CRAM.SH = tSH'(CRAMdata[49:50]);
  assign CRAM.VMA = tVMA'(CRAMdata[52:53]);
  assign CRAM._TIME = tTIME'(CRAMdata[54:55]);
  assign CRAM.MEM = tMEM'(CRAMdata[56:59]);
  assign CRAM.COND = tCOND'(CRAMdata[60:65]);
  assign CRAM.CALL = CRAMdata[66:66];
  assign CRAM.DISP = tDISP'(CRAMdata[67:71]);
  assign CRAM.MARK = CRAMdata[74:74];
  assign CRAM.MAGIC = tMAGIC'(CRAMdata[75:83]);
endmodule
// Local Variables:
// verilog-library-files:("../ip/cram_mem/cram_mem_stub.v")
// End:
