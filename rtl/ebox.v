`timescale 1ns / 1ps
module EBOX(input clk,

            output [13:35] eboxVMA,
            output [10:12] cacheClearer,

            output eboxReq,
            input cshEBOXT0,
            input  cshEBOXRetry,
            input mboxRespIn,

            output eboxSync,
            output mboxClk,

            input pfHold,
            input pfEBOXHandle,
            input pfPublic,

            output vmaACRef,

            input [27:35] mboxGateVMA,
            input [0:35] cacheData,

            output pageTestPriv,
            output pageIllEntry,
            output eboxUser,

            output eboxMayBePaged,
            output eboxCache,
            output eboxLookEn,
            output ki10PagingMode,
            output pageAdrCond,

            output eboxMap,

            output eboxRead,
            output eboxPSE,
            output eboxWrite,

            output upt,
            output ept,
            output userRef,

            output eboxCCA,
            output eboxUBR,
            output eboxERA,
            output eboxEnRefillRAMWr,
            output eboxSBUSDiag,
            output eboxLoadReg,
            output eboxReadReg,

            output ptDirWrite,
            output ptWr,
            output mboxCtl03,
            output mboxCtl06,
            output wrPtSel0,
            output wrPtSel1,

            input cshAdrParErr,
            input mbParErr,
            input sbusErr,
            input nxmErr,
            input mboxCDirParErr,
            output anyEboxError);

  wire [1:11] CRAM_J;
  wire [12:17] CRAM_AD;
  wire [18:20] CRAM_ADA;
  wire [18:18] CRAM_ADA_EN;
  wire [22:23] CRAM_ADB;
  wire [24:26] CRAM_AR;
  wire [27:29] CRAM_ARX;
  wire [30:30] CRAM_BR;
  wire [31:31] CRAM_BRX;
  wire [32:32] CRAM_MQ;
  wire [33:35] CRAM_FMADR;
  wire [36:38] CRAM_SCAD;
  wire [39:41] CRAM_SCADA;
  wire [39:39] CRAM_SCADA_EN;
  wire [43:44] CRAM_SCADB;
  wire [46:46] CRAM_SC;
  wire [47:47] CRAM_FE;
  wire [49:50] CRAM_SH;
  wire [49:50] CRAM_ARMM;
  wire [49:50] CRAM_VMAX;
  wire [52:53] CRAM_VMA;
  wire [54:55] CRAM_TIME;
  wire [56:59] CRAM_MEM;
  wire [60:65] CRAM_SKIP;
  wire [60:65] CRAM_COND;
  wire [66:66] CRAM_CALL;
  wire [67:71] CRAM_DISP;
  wire [67:71] CRAM_SPEC;
  wire [74:74] CRAM_MARK;
  wire [75:83] CRAM_magic;
  wire [75:80] CRAM_MAJVER;
  wire [81:83] CRAM_MINVER;
  wire [75:75] CRAM_KLPAGE;
  wire [76:76] CRAM_LONGPC;
  wire [77:77] CRAM_NONSTD;
  wire [78:78] CRAM_PV;
  wire [79:79] CRAM_PMOVE;
  wire [83:83] CRAM_ISTAT;
  wire [75:77] CRAM_PXCT;
  wire [77:79] CRAM_ACB;
  wire [80:83] CRAM_ACmagic;
  wire [75:79] CRAM_AC_OP;
  wire [76:76] CRAM_AR0_8;
  wire [77:80] CRAM_CLR;
  wire [81:83] CRAM_ARL;
  wire [75:77] CRAM_AR_CTL;
  wire [80:80] CRAM_EXP_TST;
  wire [82:83] CRAM_MQ_CTL;
  wire [75:83] CRAM_PC_FLAGS;
  wire [75:83] CRAM_FLAG_CTL;
  wire [75:83] CRAM_SPEC_INSTR;
  wire [75:83] CRAM_FETCH;
  wire [75:83] CRAM_EA_CALC;
  wire [75:83] CRAM_SP_MEM;
  wire [75:83] CRAM_MREG_FNC;
  wire [75:83] CRAM_MBOX_CTL;
  wire [81:83] CRAM_MTR_CTL;
  wire [75:83] CRAM_EBUS_CTL;
  wire [75:83] CRAM_DIAG_FUN;
  
  reg [0:35] EBUS;

  // TEMPORARY
  wire [7:0] fmAddress;
  wire FORCE1777;
  wire CONDAdr10;
  wire MULdone;

  // TEMPORARY
  assign fmAddress = 0;
  assign FORCE1777 = 0;
  assign CONDAdr10 = 0;
  assign MULdone = 0;

  CLK clkModule(.clk(clk),
                .mbXfer(mbXfer)
                );

  CON con(.clk(clk)
          );

  CRA cra(.clk(clk),
          .CRADR(CRADR),
          .DISP(CRAM_DISP),
          .FORCE1777(FORCE1777),
          .CONDA10(CONDAdr10),
          .MULDONE(MULdone),
          .COND(CRAM_COND),
          .SKIP(CRAM_SKIP),
          .CALL(SPECcall),
          .RET(DISPret),
          .J(CRAM_J),
          );

  CRAM cram(.clk(clk),
            .J(CRAM_J),
            .AD(CRAM_AD),
            .ADA(CRAM_ADA),
            .ADA_EN(CRAM_ADA_EN),
            .ADB(CRAM_ADB),
            .AR(CRAM_AR),
            .ARX(CRAM_ARX),
            .BR(CRAM_BR),
            .BRX(CRAM_BRX),
            .MQ(CRAM_MQ),
            .FMADR(CRAM_FMADR),
            .SCAD(CRAM_SCAD),
            .SCADA(CRAM_SCADA),
            .SCADA_EN(CRAM_SCADA_EN),
            .SCADB(CRAM_SCADB),
            .SC(CRAM_SC),
            .FE(CRAM_FE),
            .SH(CRAM_SH),
            .ARMM(CRAM_ARMM),
            .VMAX(CRAM_VMAX),
            .VMA(CRAM_VMA),
            .TIME(CRAM_TIME),
            .MEM(CRAM_MEM),
            .SKIP(CRAM_SKIP),
            .COND(CRAM_COND),
            .CALL(CRAM_CALL),
            .DISP(CRAM_DISP),
            .SPEC(CRAM_SPEC),
            .MARK(CRAM_MARK),
            .magic(CRAM_magic),
            .MAJVER(CRAM_MAJVER),
            .MINVER(CRAM_MINVER),
            .KLPAGE(CRAM_KLPAGE),
            .LONGPC(CRAM_LONGPC),
            .NONSTD(CRAM_NONSTD),
            .PV(CRAM_PV),
            .PMOVE(CRAM_PMOVE),
            .ISTAT(CRAM_ISTAT),
            .PXCT(CRAM_PXCT),
            .ACB(CRAM_ACB),
            .ACmagic(CRAM_ACmagic),
            .AC_OP(CRAM_AC_OP),
            .AR0_8(CRAM_AR0_8),
            .CLR(CRAM_CLR),
            .ARL(CRAM_ARL),
            .AR_CTL(CRAM_AR_CTL),
            .EXP_TST(CRAM_EXP_TST),
            .MQ_CTL(CRAM_MQ_CTL),
            .PC_FLAGS(CRAM_PC_FLAGS),
            .FLAG_CTL(CRAM_FLAG_CTL),
            .SPEC_INSTR(CRAM_SPEC_INSTR),
            .FETCH(CRAM_FETCH),
            .EA_CALC(CRAM_EA_CALC),
            .SP_MEM(CRAM_SP_MEM),
            .MREG_FNC(CRAM_MREG_FNC),
            .MBOX_CTL(CRAM_MBOX_CTL),
            .MTR_CTL(CRAM_MTR_CTL),
            .EBUS_CTL(CRAM_EBUS_CTL),
            .DIAG_FUNC(CRAM_DIAG_FUNC)
            );

  EDP edp(.clk(clk),
          .AD(EDP_AD),
          .ADX(EDP_ADX),
          .AR(EDP_AR),
          .ADcarry36(ADcarry36),
          .ADcarry_02(ADcarry_02),
          .fmAddress(fmAddress),
          .VMA(eboxVMA),
          .EBUS(EBUS)
          );

  IR ir(.clk(clk),
        .AD(EDP_AD),
        .ADcarry36(ADcarry36),
        .ADcarry_02(ADcarry_02),
        .EBUS(EBUS),
        .CRAM_magic(CRAM_magic),
        .mbXfer(mbXfer),
        .JRST0(JRST0),
        .DRAM_A(DRAM_A),
        .DRAM_B(DRAM_B),
        .DRAM_J(DRAM_J)
        );

  VMA vma(.clk(clk)
          );

  APR apr(.clk(clk));

  MCL mcl(.clk(clk));

  CTL ctl(.clk(clk));

  SCD scd(.clk(clk),
          .CRAM_SCAD(CRAM_SCAD),
          .CRAM_SCADA(CRAM_SCADA),
          .CRAM_SCADB(CRAM_SCADB),
          .CRAM_MAGIC(CRAM_MAGIC),
          .AR(EDP_AR),
          .DIAG(CRAM_DIAG_FUNC),
          .EBUS(EBUS)
          );

  SHM shm(.clk(clk),
          .AR(EDP_AR),
          .ARX(EDP_ARX),
          .AR36(ARcarry36),
          .ARX36(ARXcarry36),
          .longEnable(0),       // XXX
          .CRAM_SH(CRAM_SH)
          );

  CSH csh(.clk(clk)
          );

  CHA cha(.clk(clk)
          );

  CHX chx(.clk(clk)
          );

  PMA pma(.clk(clk)
          );

  PAG pag(.clk(clk)
          );

  CHD chd(.clk(clk)
          );

  MBC mbc(.clk(clk)
          );

  MBZ mbz(.clk(clk)
          );

  PIC pic(.clk(clk)
          );

  CHC chc(.clk(clk)
          );

  CCW ccw(.clk(clk)
          );

  CRC crc(.clk(clk)
          );

  CCL ccl(.clk(clk)
          );

  MTR mtr(.clk(clk)
          );

  DPS dps(.clk(clk)
          );
endmodule // EBOX
