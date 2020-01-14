`timescale 1ns / 1ps
// M8548 CRAM
module CRAM(input clk,
            input [11:0] CRADR,
            output [1:11] J,
            output [12:17] AD,
            output [18:20] ADA,
            output [18:18] ADA_EN,
            output [22:23] ADB,
            output [24:26] AR,
            output [27:29] ARX,
            output [30:30] BR,
            output [31:31] BRX,
            output [32:32] MQ,
            output [33:35] FMADR,
            output [36:38] SCAD,
            output [39:41] SCADA,
            output [39:39] SCADA_EN,
            output [43:44] SCADB,
            output [46:46] SC,
            output [47:47] FE,
            output [49:50] SH,
            output [49:50] ARMM,
            output [49:50] VMAX,
            output [52:53] VMA,
            output [54:55] TIME,
            output [56:59] MEM,
            output [60:65] SKIP,
            output [60:65] COND,
            output [66:66] CALL,
            output [67:71] DISP,
            output [67:71] SPEC,
            output [74:74] MARK,
            output [75:83] magic,
            output [75:80] MAJVER,
            output [81:83] MINVER,
            output [75:75] KLPAGE,
            output [76:76] LONGPC,
            output [77:77] NONSTD,
            output [78:78] PV,
            output [79:79] PMOVE,
            output [83:83] ISTAT,
            output [75:77] PXCT,
            output [77:79] ACB,
            output [80:83] ACmagic,
            output [75:79] AC_OP,
            output [76:76] AR0_8,
            output [77:80] CLR,
            output [81:83] ARL,
            output [75:77] AR_CTL,
            output [80:80] EXP_TST,
            output [82:83] MQ_CTL,
            output [75:83] PC_FLAGS,
            output [75:83] FLAG_CTL,
            output [75:83] SPEC_INSTR,
            output [75:83] FETCH,
            output [75:83] EA_CALC,
            output [75:83] SP_MEM,
            output [75:83] MREG_FNC,
            output [75:83] MBOX_CTL,
            output [81:83] MTR_CTL,
            output [75:83] EBUS_CTL,
            output [75:83] DIAG_FUNC
            );

  // CRAM write port is never needed?
  reg [83:0] CRAMwriteData;
  reg [11:0] CRAMwriteAddr;
  wire CRAMwriteClk;
  wire CRAMwriteEnable;
  reg [83:0] CRAMdata;

  initial CRAMwriteEnable = 0;
  initial CRAMwriteClk = 0;

  assign J = CRAMdata[1:11];
  assign AD = CRAMdata[12:17];
  assign ADA = CRAMdata[18:20];
  assign ADA_EN = CRAMdata[18:18];
  assign ADB = CRAMdata[22:23];
  assign AR = CRAMdata[24:26];
  assign ARX = CRAMdata[27:29];
  assign BR = CRAMdata[30:30];
  assign BRX = CRAMdata[31:31];
  assign MQ = CRAMdata[32:32];
  assign FMADR = CRAMdata[33:35];
  assign SCAD = CRAMdata[36:38];
  assign SCADA = CRAMdata[39:41];
  assign SCADA_EN = CRAMdata[39:39];
  assign SCADB = CRAMdata[43:44];
  assign SC = CRAMdata[46:46];
  assign FE = CRAMdata[47:47];
  assign SH = CRAMdata[49:50];
  assign ARMM = CRAMdata[49:50];
  assign VMAX = CRAMdata[49:50];
  assign VMA = CRAMdata[52:53];
  assign TIME = CRAMdata[54:55];
  assign MEM = CRAMdata[56:59];
  assign SKIP = CRAMdata[60:65];
  assign COND = CRAMdata[60:65];
  assign CALL = CRAMdata[66:66];
  assign DISP = CRAMdata[67:71];
  assign SPEC = CRAMdata[67:71];
  assign MARK = CRAMdata[74:74];
  assign magic = CRAMdata[75:83];
  assign MAJVER = CRAMdata[75:80];
  assign MINVER = CRAMdata[81:83];
  assign KLPAGE = CRAMdata[75:75];
  assign LONGPC = CRAMdata[76:76];
  assign NONSTD = CRAMdata[77:77];
  assign PV = CRAMdata[78:78];
  assign PMOVE = CRAMdata[79:79];
  assign ISTAT = CRAMdata[83:83];
  assign PXCT = CRAMdata[75:77];
  assign ACB = CRAMdata[77:79];
  assign ACmagic = CRAMdata[80:83];
  assign AC_OP = CRAMdata[75:79];
  assign AR0_8 = CRAMdata[76:76];
  assign CLR = CRAMdata[77:80];
  assign ARL = CRAMdata[81:83];
  assign AR_CTL = CRAMdata[75:77];
  assign EXP_TST = CRAMdata[80:80];
  assign MQ_CTL = CRAMdata[82:83];
  assign PC_FLAGS = CRAMdata[75:83];
  assign FLAG_CTL = CRAMdata[75:83];
  assign SPEC_INSTR = CRAMdata[75:83];
  assign FETCH = CRAMdata[75:83];
  assign EA_CALC = CRAMdata[75:83];
  assign SP_MEM = CRAMdata[75:83];
  assign MREG_FNC = CRAMdata[75:83];
  assign MBOX_CTL = CRAMdata[75:83];
  assign MTR_CTL = CRAMdata[81:83];
  assign EBUS_CTL = CRAMdata[75:83];
  assign DIAG_FUNC = CRAMdata[75:83]; 

 CRAMblockRAM cramRAM(.clka(CRAMwriteClk),
                       .addra(CRAMwriteAddr),
                       .dina(CRAMwriteData),
                       .wea(CRAMwriteEnable),

                       .clkb(clk),
                       .addrb(CRADR),
                       .doutb(CRAMdata),
                       .enb(1)
                       );
endmodule // CRAM
