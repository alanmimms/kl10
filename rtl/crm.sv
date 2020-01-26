`timescale 1ns / 1ps

`include "cram-defs.svh"

// M8548 CRM
//
// 2K words of CRAM storage.
//
// In a real KL10PV there are five instances of M8548. This is coded
// to do perform as all five slots.
module crm(input eboxClk,
           input [0:11] CRADR,
           output [0:10] CRAM_J,
           output tCRAM_AD CRAM_AD,
           output tCRAM_ADA CRAM_ADA,
           output tCRAM_ADA_EN CRAM_ADA_EN,
           output tCRAM_ADB CRAM_ADB,
           output tCRAM_AR CRAM_AR,
           output tCRAM_ARX CRAM_ARX,
           output tCRAM_BR CRAM_BR,
           output tCRAM_BRX CRAM_BRX,
           output tCRAM_MQ CRAM_MQ,
           output tCRAM_FMADR CRAM_FMADR,
           output tCRAM_SCAD CRAM_SCAD,
           output tCRAM_SCADA CRAM_SCADA,
           output tCRAM_SCADA_EN CRAM_SCADA_EN,
           output tCRAM_SCADB CRAM_SCADB,
           output tCRAM_SC CRAM_SC,
           output tCRAM_FE CRAM_FE,
           output tCRAM_SH CRAM_SH,
           output tCRAM_ARMM CRAM_ARMM,
           output tCRAM_VMAX CRAM_VMAX,
           output tCRAM_VMA CRAM_VMA,
           output tCRAM_TIME CRAM_TIME,
           output tCRAM_MEM CRAM_MEM,
           output tCRAM_SKIP CRAM_SKIP,
           output tCRAM_COND CRAM_COND,
           output CRAM_CALL,
           output tCRAM_DISP CRAM_DISP,
           output tCRAM_SPEC CRAM_SPEC,
           output CRAM_MARK,
           output tCRAM_MAGIC CRAM_MAGIC,
           output [0:5] CRAM_MAJVER,
           output [0:2]  CRAM_MINVER,
           output CRAM_KLPAGE,
           output CRAM_LONGPC,
           output CRAM_NONSTD,
           output CRAM_PV,
           output CRAM_PMOVE,
           output CRAM_ISTAT,
           output [0:2] CRAM_PXCT,
           output tCRAM_ACB CRAM_ACB,
           output [0:3] CRAM_ACmagic,
           output tCRAM_AC_OP CRAM_AC_OP,
           output CRAM_AR0_8,
           output tCRAM_CLR CRAM_CLR,
           output tCRAM_ARL CRAM_ARL,
           output tCRAM_AR_CTL CRAM_AR_CTL,
           output CRAM_EXP_TST,
           output tCRAM_MQ_CTL CRAM_MQ_CTL,
           output tCRAM_PC_FLAGS CRAM_PC_FLAGS,
           output tCRAM_FLAG_CTL CRAM_FLAG_CTL,
           output tCRAM_SPEC_INSTR CRAM_SPEC_INSTR,
           output tCRAM_FETCH CRAM_FETCH,
           output tCRAM_EA_CALC CRAM_EA_CALC,
           output tCRAM_SP_MEM CRAM_SP_MEM,
           output tCRAM_MREG_FNC CRAM_MREG_FNC,
           output tCRAM_MBOX_CTL CRAM_MBOX_CTL,
           output tCRAM_MTR_CTL CRAM_MTR_CTL,
           output tCRAM_EBUS_CTL CRAM_EBUS_CTL,
           output tCRAM_DIAG_FUNC CRAM_DIAG_FUNC
           /*AUTOARG*/);

  wire [0:83] CRAMdata;

  /*AUTOWIRE*/
  /*AUTOREG*/
  // Beginning of automatic regs (for this module's undeclared outputs)
  reg [0:3]             CRAM_ACmagic;
  reg                   CRAM_AR0_8;
  reg                   CRAM_CALL;
  reg                   CRAM_EXP_TST;
  reg                   CRAM_ISTAT;
  reg [0:10]            CRAM_J;
  reg                   CRAM_KLPAGE;
  reg                   CRAM_LONGPC;
  reg [0:5]             CRAM_MAJVER;
  reg                   CRAM_MARK;
  reg [0:2]             CRAM_MINVER;
  reg                   CRAM_NONSTD;
  reg                   CRAM_PMOVE;
  reg                   CRAM_PV;
  reg [0:2]             CRAM_PXCT;
  // End of automatics

  cram_mem cram0(.clka(clk),
                 .addra(CRADR),
                 .dina(0),
                 .douta(CRAMdata),
                 .wea(0)
                 /*AUTOINST*/);

  always @(*) begin
    CRAM_J = CRAM_J'(CRAMdata[1:11]);
    CRAM_AD = CRAM_AD'(CRAMdata[12:17]);
    CRAM_ADA = CRAM_ADA'(CRAMdata[18:20]);
    CRAM_ADA_EN = CRAM_ADA_EN'(CRAMdata[18:18]);
    CRAM_ADB = CRAM_ADB'(CRAMdata[22:23]);
    CRAM_AR = CRAM_AR'(CRAMdata[24:26]);
    CRAM_ARX = CRAM_ARX'(CRAMdata[27:29]);
    CRAM_BR = CRAM_BR'(CRAMdata[30:30]);
    CRAM_BRX = CRAM_BRX'(CRAMdata[31:31]);
    CRAM_MQ = CRAM_MQ'(CRAMdata[32:32]);
    CRAM_FMADR = CRAM_FMADR'(CRAMdata[33:35]);
    CRAM_SCAD = CRAM_SCAD'(CRAMdata[36:38]);
    CRAM_SCADA = CRAM_SCADA'(CRAMdata[39:41]);
    CRAM_SCADA_EN = CRAM_SCADA_EN'(CRAMdata[39:39]);
    CRAM_SCADB = CRAM_SCADB'(CRAMdata[43:44]);
    CRAM_SC = CRAM_SC'(CRAMdata[46:46]);
    CRAM_FE = CRAM_FE'(CRAMdata[47:47]);
    CRAM_SH = CRAM_SH'(CRAMdata[49:50]);
    CRAM_ARMM = CRAM_ARMM'(CRAMdata[49:50]);
    CRAM_VMAX = CRAM_VMAX'(CRAMdata[49:50]);
    CRAM_VMA = CRAM_VMA'(CRAMdata[52:53]);
    CRAM_TIME = CRAM_TIME'(CRAMdata[54:55]);
    CRAM_MEM = CRAM_MEM'(CRAMdata[56:59]);
    CRAM_SKIP = CRAM_SKIP'(CRAMdata[60:65]);
    CRAM_COND = CRAM_COND'(CRAMdata[60:65]);
    CRAM_CALL = CRAM_CALL'(CRAMdata[66:66]);
    CRAM_DISP = CRAM_DISP'(CRAMdata[67:71]);
    CRAM_SPEC = CRAM_SPEC'(CRAMdata[67:71]);
    CRAM_MARK = CRAM_MARK'(CRAMdata[74:74]);
    CRAM_MAGIC = CRAM_MAGIC'(CRAMdata[75:83]);
    CRAM_MAJVER = CRAM_MAJVER'(CRAMdata[75:80]);
    CRAM_MINVER = CRAM_MINVER'(CRAMdata[81:83]);
    CRAM_KLPAGE = CRAM_KLPAGE'(CRAMdata[75:75]);
    CRAM_LONGPC = CRAM_LONGPC'(CRAMdata[76:76]);
    CRAM_NONSTD = CRAM_NONSTD'(CRAMdata[77:77]);
    CRAM_PV = CRAM_PV'(CRAMdata[78:78]);
    CRAM_PMOVE = CRAM_PMOVE'(CRAMdata[79:79]);
    CRAM_ISTAT = CRAM_ISTAT'(CRAMdata[83:83]);
    CRAM_PXCT = CRAM_PXCT'(CRAMdata[75:77]);
    CRAM_ACB = CRAM_ACB'(CRAMdata[77:79]);
    CRAM_ACmagic = CRAM_ACmagic'(CRAMdata[80:83]);
    CRAM_AC_OP = CRAM_AC_OP'(CRAMdata[75:79]);
    CRAM_AR0_8 = CRAM_AR0_8'(CRAMdata[76:76]);
    CRAM_CLR = CRAM_CLR'(CRAMdata[77:80]);
    CRAM_ARL = CRAM_ARL'(CRAMdata[81:83]);
    CRAM_AR_CTL = CRAM_AR_CTL'(CRAMdata[75:77]);
    CRAM_EXP_TST = CRAM_EXP_TST'(CRAMdata[80:80]);
    CRAM_MQ_CTL = CRAM_MQ_CTL'(CRAMdata[82:83]);
    CRAM_PC_FLAGS = CRAM_PC_FLAGS'(CRAMdata[75:83]);
    CRAM_FLAG_CTL = CRAM_FLAG_CTL'(CRAMdata[75:83]);
    CRAM_SPEC_INSTR = CRAM_SPEC_INSTR'(CRAMdata[75:83]);
    CRAM_FETCH = CRAM_FETCH'(CRAMdata[75:83]);
    CRAM_EA_CALC = CRAM_EA_CALC'(CRAMdata[75:83]);
    CRAM_SP_MEM = CRAM_SP_MEM'(CRAMdata[75:83]);
    CRAM_MREG_FNC = CRAM_MREG_FNC'(CRAMdata[75:83]);
    CRAM_MBOX_CTL = CRAM_MBOX_CTL'(CRAMdata[75:83]);
    CRAM_MTR_CTL = CRAM_MTR_CTL'(CRAMdata[81:83]);
    CRAM_EBUS_CTL = CRAM_EBUS_CTL'(CRAMdata[75:83]);
    CRAM_DIAG_FUNC = CRAM_DIAG_FUNC'(CRAMdata[75:83]);
  end
endmodule
// Local Variables:
// verilog-library-files:("../ip/cram_mem/cram_mem_stub.v")
// End:
