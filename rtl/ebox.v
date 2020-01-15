`timescale 1ns / 1ps
module ebox(input clk,

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
            output anyEboxError/*AUTOARG*/);

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
  
  // This is the multiplexed current EBUS multiplexed by each the
  // XXXdrivingEBUS signal coming from each module to determine who
  // gets to provide EBUS its content.
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

  clk clk0(
           /*AUTOINST*/
           // Outputs
           .mbXfer                      (mbXfer),
           // Inputs
           .clk                         (clk));

  con con0(
           /*AUTOINST*/
           // Inputs
           .clk                         (clk));

  cra cra0(.DISP(CRAM_DISP),
          .CONDA10(CONDAdr10),
          .MULDONE(MULdone),
          .COND(CRAM_COND),
          .SKIP(CRAM_SKIP),
          .CALL(SPECcall),
          .RET(DISPret),
          .J(CRAM_J),
           /*AUTOINST*/
           // Outputs
           .j                           (j[10:0]),
           .ad                          (ad[5:0]),
           .ada                         (ada[2:0]),
           .adaEn                       (adaEn),
           .adb                         (adb[1:0]),
           .ar                          (ar[2:0]),
           .arx                         (arx[2:0]),
           .br                          (br),
           .brx                         (brx),
           .mq                          (mq),
           .fmadr                       (fmadr[2:0]),
           .scad                        (scad[2:0]),
           .scada                       (scada[1:0]),
           .scadb                       (scadb[1:0]),
           .sc                          (sc),
           .fe                          (fe),
           .sh                          (sh[1:0]),
           .armm                        (armm[1:0]),
           .vmax                        (vmax[1:0]),
           .vma                         (vma[1:0]),
           .time_                       (time_[1:0]),
           .mem                         (mem[3:0]),
           .skip                        (skip[5:0]),
           .cond                        (cond[5:0]),
           .call                        (call),
           .disp                        (disp[4:0]),
           .spec                        (spec[4:0]),
           .mark                        (mark),
           .magic                       (magic[8:0]),
           // Inputs
           .clkForce1777                (clkForce1777),
           .DRAMa                       (DRAMa[0:3]),
           .DRAMb                       (DRAMb[0:3]),
           .DRAMj                       (DRAMj[0:9]),
           .dispIn                      (dispIn[7:10]),
           .condIn                      (condIn[8:0]));

  cram cram0(.J(CRAM_J),
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
            .DIAG_FUNC(CRAM_DIAG_FUNC),
             /*AUTOINST*/
             // Inputs
             .clk                       (clk),
             .CRADR                     (CRADR[11:0]));

  edp edp0(.AD(EDP_AD),
          .ADX(EDP_ADX),
          .AR(EDP_AR),
          .VMA(eboxVMA),
          .ebusIn(EBUS),
          .drivingEBUS(EDPdrivingEBUS),
          .EBUS(EDP_EBUS),
           /*AUTOINST*/
           // Outputs
           .MQ                          (MQ[0:35]),
           .ad6Beq0                     (ad6Beq0[0:5]),
           .ADoverflow00                (ADoverflow00),
           .ARout                       (ARout[0:35]),
           .fmWrite                     (fmWrite),
           .fmParity                    (fmParity),
           .ADcarry36                   (ADcarry36),
           // Inputs
           .clk                         (clk),
           .ADXcarry36                  (ADXcarry36),
           .ADlong                      (ADlong),
           .ARLsel                      (ARLsel[0:2]),
           .ARRsel                      (ARRsel[0:2]),
           .AR00to08load                (AR00to08load),
           .AR09to17load                (AR09to17load),
           .ARRload                     (ARRload),
           .BRload                      (BRload),
           .BRXload                     (BRXload),
           .ARXLsel                     (ARXLsel[2:0]),
           .ARXRsel                     (ARXRsel[2:0]),
           .ARXload                     (ARXload),
           .MQsel                       (MQsel[0:1]),
           .MQMsel                      (MQMsel[0:1]),
           .MQMen                       (MQMen),
           .AR00to11clr                 (AR00to11clr),
           .AR12to17clr                 (AR12to17clr),
           .ARRclr                      (ARRclr),
           .ARMM                        (ARMM[0:35]),
           .cacheData                   (cacheData[0:35]),
           .SH                          (SH[0:35]),
           .adToEBUS_L                  (adToEBUS_L),
           .adToEBUS_R                  (adToEBUS_R),
           .ADbool                      (ADbool),
           .ADsel                       (ADsel[0:3]),
           .ADAsel                      (ADAsel[0:1]),
           .ADBsel                      (ADBsel[0:1]),
           .ADAen                       (ADAen[0:35]),
           .fmBlk                       (fmBlk[0:2]),
           .fmAdr                       (fmAdr[0:3]),
           .fmWrite00_17                (fmWrite00_17),
           .fmWrite18_35                (fmWrite18_35),
           .diag                        (diag[0:8]),
           .diagReadFunc12X             (diagReadFunc12X),
           .VMAheldOrPC                 (VMAheldOrPC[0:35]),
           .magic                       (magic[0:8]));

  ir ir0(.AD(EDP_AD),
        .drivingEBUS(IRdrivingEBUS),
        .EBUS(IR_EBUS),
         /*AUTOINST*/
         // Outputs
         .IOlegal                       (IOlegal),
         .ACeq0                         (ACeq0),
         .JRST0                         (JRST0),
         .testSatisfied                 (testSatisfied),
         .IR                            (IR[0:12]),
         .IRAC                          (IRAC[9:12]),
         .DRAM_A                        (DRAM_A[2:0]),
         .DRAM_B                        (DRAM_B[2:0]),
         .DRAM_J                        (DRAM_J[10:0]),
         .DRAM_ODD_PARITY               (DRAM_ODD_PARITY),
         // Inputs
         .clk                           (clk),
         .cacheData                     (cacheData[0:35]),
         .CRAM_magic                    (CRAM_magic[0:8]),
         .mbXfer                        (mbXfer),
         .loadIR                        (loadIR),
         .loadDRAM                      (loadDRAM),
         .diag                          (diag[4:6]),
         .diagLoadFunc06X               (diagLoadFunc06X),
         .diagReadFunc13X               (diagReadFunc13X),
         .inhibitCarry18                (inhibitCarry18),
         .SPEC_genCarry18               (SPEC_genCarry18),
         .genCarry36                    (genCarry36),
         .ADcarry_02                    (ADcarry_02),
         .ADcarry12                     (ADcarry12),
         .ADcarry18                     (ADcarry18),
         .ADcarry24                     (ADcarry24),
         .ADcarry30                     (ADcarry30),
         .ADcarry36                     (ADcarry36),
         .ADXcarry12                    (ADXcarry12),
         .ADXcarry24                    (ADXcarry24));

  vma vma0(
           /*AUTOINST*/
           // Inputs
           .clk                         (clk));

  apr apr0(
           /*AUTOINST*/
           // Outputs
           .fmOut                       (fmOut[0:35]),
           .ebusReturn                  (ebusReturn),
           .ebusReq                     (ebusReq),
           .ebusDemand                  (ebusDemand),
           .disableCS                   (disableCS),
           .ebusF01                     (ebusF01),
           .coniOrDATAI                 (coniOrDATAI),
           .sendF02                     (sendF02),
           .aprPhysNum                  (aprPhysNum),
           // Inouts
           .ebusD                       (ebusD[0:35]),
           // Inputs
           .fmIn                        (fmIn[0:35]),
           .irAC                        (irAC[9:12]),
           .ad                          (ad[0:35]),
           .cshAdrParErr                (cshAdrParErr),
           .mbParErr                    (mbParErr),
           .sbusErr                     (sbusErr),
           .nxmErr                      (nxmErr),
           .mboxCDirParErr              (mboxCDirParErr),
           .ds                          (ds[0:7]),
           .ebusDSStrobe                (ebusDSStrobe));

  mcl mcl0(
           /*AUTOINST*/
           // Outputs
           .eboxReqIn                   (eboxReqIn),
           .mboxRespIn                  (mboxRespIn),
           .eboxSync                    (eboxSync),
           .mboxClk                     (mboxClk),
           .mboxXfer                    (mboxXfer),
           .pfHold                      (pfHold),
           .ptPublic                    (ptPublic),
           .clkForce1777                (clkForce1777),
           // Inputs
           .cshEBOXT0                   (cshEBOXT0),
           .cshEBOXRetry                (cshEBOXRetry),
           .pfEBOXHandle                (pfEBOXHandle),
           .pcp                         (pcp),
           .iot                         (iot),
           .user                        (user),
           .public                      (public));

  ctl ctl0(
           /*AUTOINST*/
           // Outputs
           .ADXcarry36                  (ADXcarry36),
           // Inputs
           .clk                         (clk),
           .CRAM_ADcarry                (CRAM_ADcarry),
           .ar                          (ar[0:35]),
           .PCplus1inh                  (PCplus1inh));

  scd scd0(.AR(EDP_AR),
          .DIAG(CRAM_DIAG_FUNC),
          .ebusIn(EBUS),
          .drivingEBUS(SCDdrivingEBUS),
          .EBUS(SCD_EBUS),
           /*AUTOINST*/
           // Outputs
           .ARMM                        (ARMM[0:35]),
           .FE                          (FE[0:9]),
           .SC                          (SC[0:9]),
           .SCADA                       (SCADA[0:35]),
           .SCADB                       (SCADB[0:35]),
           .SC_GE_36                    (SC_GE_36),
           .OV                          (OV),
           .CRY0                        (CRY0),
           .CRY1                        (CRY1),
           .FOV                         (FOV),
           .FXU                         (FXU),
           .FPD                         (FPD),
           .PCP                         (PCP),
           .DIV_CHK                     (DIV_CHK),
           .TRAP_REQ1                   (TRAP_REQ1),
           .TRAP_REQ2                   (TRAP_REQ2),
           .TRAP_CYC1                   (TRAP_CYC1),
           .TRAP_CYC2                   (TRAP_CYC2),
           .USER                        (USER),
           .USER_IOT                    (USER_IOT),
           .PUBLIC                      (PUBLIC),
           .PRIVATE                     (PRIVATE),
           .ADR_BRK_PREVENT             (ADR_BRK_PREVENT),
           // Inputs
           .clk                         (clk),
           .CRAM_SCAD                   (CRAM_SCAD[2:0]),
           .CRAM_SCADA                  (CRAM_SCADA[1:0]),
           .CRAM_SCADB                  (CRAM_SCADB[1:0]),
           .CRAM_MAGIC                  (CRAM_MAGIC[0:8]),
           .DIAG_READ_FUNC_13X          (DIAG_READ_FUNC_13X));

  shm shm0(.AR(EDP_AR),
          .ARX(EDP_ARX),
          .AR36(ARcarry36),
          .ARX36(ARXcarry36),
          .longEnable(0),       // XXX
           /*AUTOINST*/
           // Outputs
           .XR                          (XR[3:0]),
           .indexed                     (indexed),
           .ARextended                  (ARextended),
           .ARparityOdd                 (ARparityOdd),
           // Inputs
           .clk                         (clk),
           .CRAM_SH                     (CRAM_SH[1:0]));

  csh csh0(
           /*AUTOINST*/
           // Inputs
           .clk                         (clk));

  cha cha0(
           /*AUTOINST*/
           // Inputs
           .clk                         (clk));

  chx chx0(
           /*AUTOINST*/
           // Inputs
           .clk                         (clk));

  pma pma0(
           /*AUTOINST*/
           // Inputs
           .clk                         (clk));

  pag pag0(
           /*AUTOINST*/
           // Inputs
           .clk                         (clk));

  chd chd0(
           /*AUTOINST*/
           // Inputs
           .clk                         (clk));

  mbc mbc0(
           /*AUTOINST*/
           // Inputs
           .clk                         (clk));

  mbz mbz0(
           /*AUTOINST*/
           // Inputs
           .clk                         (clk));

  pic pic0(
           /*AUTOINST*/
           // Inputs
           .clk                         (clk));

  chc chc0(
           /*AUTOINST*/
           // Inputs
           .clk                         (clk));

  ccw ccw0(
           /*AUTOINST*/
           // Inputs
           .clk                         (clk));

  crc crc0(
           /*AUTOINST*/
           // Inputs
           .clk                         (clk));

  ccl ccl0(
           /*AUTOINST*/
           // Inputs
           .clk                         (clk));

  mtr mtr0(
           /*AUTOINST*/
           // Inputs
           .clk                         (clk));

  dps dps0(
           /*AUTOINST*/
           // Inputs
           .clk                         (clk));
endmodule // ebox
