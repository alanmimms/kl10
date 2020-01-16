`timescale 1ns / 1ps
// M8548 CRM
//
// 2K words of CRAM storage.
//
// In a real KL10PV there are five instances of M8548. This is coded
// to do perform as all five slots.
module crm(input eboxClk,
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
           output reg [9:0] CRAM_MAGIC,
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

  /*AUTOWIRE*/
  /*AUTOREG*/

  cram_mem cram0(.clka(clk),
                 .addra(CRADR),
                 .dina(0),
                 .douta(CRAMdata),
                 .wea(0)
                 /*AUTOINST*/);

  always @(*) begin
    CRAM_J = CRAMdata[1:11];
    CRAM_AD = CRAMdata[12:17];
    CRAM_ADA = CRAMdata[18:20];
    CRAM_ADA_EN = CRAMdata[18:18];
    CRAM_ADB = CRAMdata[22:23];
    CRAM_AR = CRAMdata[24:26];
    CRAM_ARX = CRAMdata[27:29];
    CRAM_BR = CRAMdata[30:30];
    CRAM_BRX = CRAMdata[31:31];
    CRAM_MQ = CRAMdata[32:32];
    CRAM_FMADR = CRAMdata[33:35];
    CRAM_SCAD = CRAMdata[36:38];
    CRAM_SCADA = CRAMdata[39:41];
    CRAM_SCADA_EN = CRAMdata[39:39];
    CRAM_SCADB = CRAMdata[43:44];
    CRAM_SC = CRAMdata[46:46];
    CRAM_FE = CRAMdata[47:47];
    CRAM_SH = CRAMdata[49:50];
    CRAM_ARMM = CRAMdata[49:50];
    CRAM_VMAX = CRAMdata[49:50];
    CRAM_VMA = CRAMdata[52:53];
    CRAM_TIME = CRAMdata[54:55];
    CRAM_MEM = CRAMdata[56:59];
    CRAM_SKIP = CRAMdata[60:65];
    CRAM_COND = CRAMdata[60:65];
    CRAM_CALL = CRAMdata[66:66];
    CRAM_DISP = CRAMdata[67:71];
    CRAM_SPEC = CRAMdata[67:71];
    CRAM_MARK = CRAMdata[74:74];
    CRAM_MAGIC = CRAMdata[75:83];
    CRAM_MAJVER = CRAMdata[75:80];
    CRAM_MINVER = CRAMdata[81:83];
    CRAM_KLPAGE = CRAMdata[75:75];
    CRAM_LONGPC = CRAMdata[76:76];
    CRAM_NONSTD = CRAMdata[77:77];
    CRAM_PV = CRAMdata[78:78];
    CRAM_PMOVE = CRAMdata[79:79];
    CRAM_ISTAT = CRAMdata[83:83];
    CRAM_PXCT = CRAMdata[75:77];
    CRAM_ACB = CRAMdata[77:79];
    CRAM_ACmagic = CRAMdata[80:83];
    CRAM_AC_OP = CRAMdata[75:79];
    CRAM_AR0_8 = CRAMdata[76:76];
    CRAM_CLR = CRAMdata[77:80];
    CRAM_ARL = CRAMdata[81:83];
    CRAM_AR_CTL = CRAMdata[75:77];
    CRAM_EXP_TST = CRAMdata[80:80];
    CRAM_MQ_CTL = CRAMdata[82:83];
    CRAM_PC_FLAGS = CRAMdata[75:83];
    CRAM_FLAG_CTL = CRAMdata[75:83];
    CRAM_SPEC_INSTR = CRAMdata[75:83];
    CRAM_FETCH = CRAMdata[75:83];
    CRAM_EA_CALC = CRAMdata[75:83];
    CRAM_SP_MEM = CRAMdata[75:83];
    CRAM_MREG_FNC = CRAMdata[75:83];
    CRAM_MBOX_CTL = CRAMdata[75:83];
    CRAM_MTR_CTL = CRAMdata[81:83];
    CRAM_EBUS_CTL = CRAMdata[75:83];
    CRAM_DIAG_FUNC = CRAMdata[75:83]; 
  end
endmodule
// Local Variables:
// verilog-library-files:("../ip/cram_mem/cram_mem_stub.v")
// End:
