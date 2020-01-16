`timescale 1ns / 1ps
// M8548 CRM
//
// 2K words of CRAM storage.
//
// In a real KL10PV there are five instances of M8548. This is coded
// to do perform as all five slots.
module crm(input clk,
           input [11:0] CRADR,
           output [11:0] J,
           output [6:0] AD,
           output [3:0] ADA,
           output [1:0] ADA_EN,
           output [2:0] ADB,
           output [3:0] AR,
           output [3:0] ARX,
           output [1:0] BR,
           output [1:0] BRX,
           output [1:0] MQ,
           output [3:0] FMADR,
           output [3:0] SCAD,
           output [3:0] SCADA,
           output [1:0] SCADA_EN,
           output [2:0] SCADB,
           output [1:0] SC,
           output [1:0] FE,
           output [2:0] SH,
           output [2:0] ARMM,
           output [2:0] VMAX,
           output [2:0] VMA,
           output [2:0] TIME,
           output [4:0] MEM,
           output [6:0] SKIP,
           output [6:0] COND,
           output [1:0] CALL,
           output [5:0] DISP,
           output [5:0] SPEC,
           output [1:0] MARK,
           output [9:0] magic,
           output [6:0] MAJVER,
           output [3:0] MINVER,
           output [1:0] KLPAGE,
           output [1:0] LONGPC,
           output [1:0] NONSTD,
           output [1:0] PV,
           output [1:0] PMOVE,
           output [1:0] ISTAT,
           output [3:0] PXCT,
           output [3:0] ACB,
           output [4:0] ACmagic,
           output [5:0] AC_OP,
           output [1:0] AR0_8,
           output [4:0] CLR,
           output [3:0] ARL,
           output [3:0] AR_CTL,
           output [1:0] EXP_TST,
           output [2:0] MQ_CTL,
           output [9:0] PC_FLAGS,
           output [9:0] FLAG_CTL,
           output [9:0] SPEC_INSTR,
           output [9:0] FETCH,
           output [9:0] EA_CALC,
           output [9:0] SP_MEM,
           output [9:0] MREG_FNC,
           output [9:0] MBOX_CTL,
           output [3:0] MTR_CTL,
           output [9:0] EBUS_CTL,
           output [9:0] DIAG_FUNC
           );

  wire [0:83] CRAMdata;

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

  cram_mem cram0(.clka(clk),
                 .addra(CRADR),
                 .dina(0),
                 .douta(CRAMdata),
                 .wea(0)
                 );
endmodule
