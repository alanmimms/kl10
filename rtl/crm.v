`timescale 1ns / 1ps
// M8548 CRM
//
// 2K words of CRAM storage.
//
// In a real KL10PV there are five instances of M8548. This is coded
// to do perform as all five slots.
module crm(input clk,
           input [11:0] CRADR,
           output reg [11:0] CRAM_J,
           output reg [6:0] CRAM_AD,
           output reg [3:0] CRAM_ADA,
           output reg [1:0] CRAM_ADA_EN,
           output reg [2:0] CRAM_ADB,
           output reg [3:0] CRAM_AR,
           output reg [3:0] CRAM_ARX,
           output reg [1:0] CRAM_BR,
           output reg [1:0] CRAM_BRX,
           output reg [1:0] CRAM_MQ,
           output reg [3:0] CRAM_FMADR,
           output reg [3:0] CRAM_SCAD,
           output reg [3:0] CRAM_SCADA,
           output reg [1:0] CRAM_SCADA_EN,
           output reg [2:0] CRAM_SCADB,
           output reg [1:0] CRAM_SC,
           output reg [1:0] CRAM_FE,
           output reg [2:0] CRAM_SH,
           output reg [2:0] CRAM_ARMM,
           output reg [2:0] CRAM_VMAX,
           output reg [2:0] CRAM_VMA,
           output reg [2:0] CRAM_TIME,
           output reg [4:0] CRAM_MEM,
           output reg [6:0] CRAM_SKIP,
           output reg [6:0] CRAM_COND,
           output reg [1:0] CRAM_CALL,
           output reg [5:0] CRAM_DISP,
           output reg [5:0] CRAM_SPEC,
           output reg [1:0] CRAM_MARK,
           output reg [9:0] CRAM_magic,
           output reg [6:0] CRAM_MAJVER,
           output reg [3:0] CRAM_MINVER,
           output reg [1:0] CRAM_KLPAGE,
           output reg [1:0] CRAM_LONGPC,
           output reg [1:0] CRAM_NONSTD,
           output reg [1:0] CRAM_PV,
           output reg [1:0] CRAM_PMOVE,
           output reg [1:0] CRAM_ISTAT,
           output reg [3:0] CRAM_PXCT,
           output reg [3:0] CRAM_ACB,
           output reg [4:0] CRAM_ACmagic,
           output reg [5:0] CRAM_AC_OP,
           output reg [1:0] CRAM_AR0_8,
           output reg [4:0] CRAM_CLR,
           output reg [3:0] CRAM_ARL,
           output reg [3:0] CRAM_AR_CTL,
           output reg [1:0] CRAM_EXP_TST,
           output reg [2:0] CRAM_MQ_CTL,
           output reg [9:0] CRAM_PC_FLAGS,
           output reg [9:0] CRAM_FLAG_CTL,
           output reg [9:0] CRAM_SPEC_INSTR,
           output reg [9:0] CRAM_FETCH,
           output reg [9:0] CRAM_EA_CALC,
           output reg [9:0] CRAM_SP_MEM,
           output reg [9:0] CRAM_MREG_FNC,
           output reg [9:0] CRAM_MBOX_CTL,
           output reg [3:0] CRAM_MTR_CTL,
           output reg [9:0] CRAM_EBUS_CTL,
           output reg [9:0] CRAM_DIAG_FUNC
           /*AUTOARG*/);

  wire [0:83] CRAMdata;

  assign CRAM_J = CRAMdata[1:11];
  assign CRAM_AD = CRAMdata[12:17];
  assign CRAM_ADA = CRAMdata[18:20];
  assign CRAM_ADA_EN = CRAMdata[18:18];
  assign CRAM_ADB = CRAMdata[22:23];
  assign CRAM_AR = CRAMdata[24:26];
  assign CRAM_ARX = CRAMdata[27:29];
  assign CRAM_BR = CRAMdata[30:30];
  assign CRAM_BRX = CRAMdata[31:31];
  assign CRAM_MQ = CRAMdata[32:32];
  assign CRAM_FMADR = CRAMdata[33:35];
  assign CRAM_SCAD = CRAMdata[36:38];
  assign CRAM_SCADA = CRAMdata[39:41];
  assign CRAM_SCADA_EN = CRAMdata[39:39];
  assign CRAM_SCADB = CRAMdata[43:44];
  assign CRAM_SC = CRAMdata[46:46];
  assign CRAM_FE = CRAMdata[47:47];
  assign CRAM_SH = CRAMdata[49:50];
  assign CRAM_ARMM = CRAMdata[49:50];
  assign CRAM_VMAX = CRAMdata[49:50];
  assign CRAM_VMA = CRAMdata[52:53];
  assign CRAM_TIME = CRAMdata[54:55];
  assign CRAM_MEM = CRAMdata[56:59];
  assign CRAM_SKIP = CRAMdata[60:65];
  assign CRAM_COND = CRAMdata[60:65];
  assign CRAM_CALL = CRAMdata[66:66];
  assign CRAM_DISP = CRAMdata[67:71];
  assign CRAM_SPEC = CRAMdata[67:71];
  assign CRAM_MARK = CRAMdata[74:74];
  assign CRAM_magic = CRAMdata[75:83];
  assign CRAM_MAJVER = CRAMdata[75:80];
  assign CRAM_MINVER = CRAMdata[81:83];
  assign CRAM_KLPAGE = CRAMdata[75:75];
  assign CRAM_LONGPC = CRAMdata[76:76];
  assign CRAM_NONSTD = CRAMdata[77:77];
  assign CRAM_PV = CRAMdata[78:78];
  assign CRAM_PMOVE = CRAMdata[79:79];
  assign CRAM_ISTAT = CRAMdata[83:83];
  assign CRAM_PXCT = CRAMdata[75:77];
  assign CRAM_ACB = CRAMdata[77:79];
  assign CRAM_ACmagic = CRAMdata[80:83];
  assign CRAM_AC_OP = CRAMdata[75:79];
  assign CRAM_AR0_8 = CRAMdata[76:76];
  assign CRAM_CLR = CRAMdata[77:80];
  assign CRAM_ARL = CRAMdata[81:83];
  assign CRAM_AR_CTL = CRAMdata[75:77];
  assign CRAM_EXP_TST = CRAMdata[80:80];
  assign CRAM_MQ_CTL = CRAMdata[82:83];
  assign CRAM_PC_FLAGS = CRAMdata[75:83];
  assign CRAM_FLAG_CTL = CRAMdata[75:83];
  assign CRAM_SPEC_INSTR = CRAMdata[75:83];
  assign CRAM_FETCH = CRAMdata[75:83];
  assign CRAM_EA_CALC = CRAMdata[75:83];
  assign CRAM_SP_MEM = CRAMdata[75:83];
  assign CRAM_MREG_FNC = CRAMdata[75:83];
  assign CRAM_MBOX_CTL = CRAMdata[75:83];
  assign CRAM_MTR_CTL = CRAMdata[81:83];
  assign CRAM_EBUS_CTL = CRAMdata[75:83];
  assign CRAM_DIAG_FUNC = CRAMdata[75:83]; 

  cram_mem cram0(.clka(clk),
                 .addra(CRADR),
                 .dina(0),
                 .douta(CRAMdata),
                 .wea(0)
                 /*AUTOINST*/);
endmodule
// Local Variables:
// verilog-library-files:("../ip/cram_mem/cram_mem_stub.v")
// End:
