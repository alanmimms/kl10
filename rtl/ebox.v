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

  // TEMPORARY
  wire [7:0] fmAddress;
  wire force1777;
  wire CONDAdr10;
  wire MULdone;

  // TEMPORARY
  assign fmAddress = 0;
  assign FORCE1777 = 0;
  assign CONDAdr10 = 0;
  assign MULdone = 0;

  // This is the multiplexed current EBUS multiplexed by each the
  // XXXdrivingEBUS signal coming from each module to determine who
  // gets to provide EBUS its content.
  reg [0:35] EBUS;

  // EBUS is muxed in this design based on each module output
  // XXXdrivingEBUS.
  always @(posedge clk) begin

    if (EDPdrivingEBUS)
      EBUS <= EDP_EBUS;
    else if (IRdrivingEBUS)
      EBUS <= IR_EBUS;
         else if (SCDdrivingEBUS)
           EBUS <= SCD_EBUS;
  end

  clk clk0(
           /*AUTOINST*/
           // Outputs
           .mbXfer                      (mbXfer),
           // Inputs
           .clk                         (clk));

  con con0(
           /*AUTOINST*/
           // Outputs
           .loadIR                      (loadIR),
           .loadDRAM                    (loadDRAM),
           .longEnable                  (longEnable),
           // Inputs
           .clk                         (clk));

  cra cra0(/*AUTOINST*/
           // Outputs
           .CRADR                       (CRADR[11:0]),
           .AREAD                       (AREAD[1:10]),
           .dispParity                  (dispParity),
           .drivingEBUS                 (drivingEBUS),
           .ebusOut                     (ebusOut[0:35]),
           // Inputs
           .clk                         (clk),
           .force1777                   (force1777),
           .MULdone                     (MULdone),
           .DRAM_A                      (DRAM_A[0:3]),
           .DRAM_B                      (DRAM_B[0:3]),
           .DRAM_J                      (DRAM_J[0:9]),
           .J                           (J[10:0]),
           .MEM                         (MEM[3:0]),
           .SKIP                        (SKIP[5:0]),
           .COND                        (COND[5:0]),
           .CALL                        (CALL),
           .DISP                        (DISP[4:0]),
           .SPEC                        (SPEC[4:0]),
           .MARK                        (MARK),
           .magic                       (magic[8:0]),
           .ebusIn                      (ebusIn[0:35]),
           .diag                        (diag[4:6]),
           .norm                        (norm[8:10]),
           .NICOND                      (NICOND[0:10]),
           .SR                          (SR[0:3]),
           .SH                          (SH[0:35]),
           .MQ                          (MQ[0:35]),
           .BR                          (BR[0:35]),
           .AD                          (AD[0:35]),
           .ADX                         (ADX[0:35]),
           .AR                          (AR[0:35]),
           .ARX                         (ARX[0:35]),
           .pfDisp                      (pfDisp[0:10]),
           .eaType                      (eaType[7:10]),
           .skipEn40_47                 (skipEn40_47),
           .skipEn50_57                 (skipEn50_57),
           .diagReadFunc14X             (diagReadFunc14X),
           .pcSection0                  (pcSection0),
           .localACAddress              (localACAddress),
           .longEnable                  (longEnable),
           .indexed                     (indexed),
           .ADcarry_02                  (ADcarry_02),
           .ADeq0                       (ADeq0),
           .ACeq0                       (ACeq0),
           .FEsign                      (FEsign),
           .SCsign                      (SCsign),
           .SCADsign                    (SCADsign),
           .SCADeq0                     (SCADeq0),
           .FPD                         (FPD),
           .ARparityOdd                 (ARparityOdd));

  crm crm0(.J(CRAM_J),
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
           .clk                         (clk),
           .CRADR                       (CRADR[11:0]));

  edp edp0(.AD(EDP_AD),
           .ADX(EDP_ADX),
           .AR(EDP_AR),
           .VMA(eboxVMA),
           .ebusIn(EBUS),
           .drivingEBUS(EDPdrivingEBUS),
           .ebusOut(EDP_EBUS),

           .MQ(EDP_MQ),
           .AR(EDP_AR),
           .ARX(EDP_ARX),

           .ARMM                        (CRAM_ARMM),
           .ADsel                       (CRAM_AD),
           .ADAsel                      (CRAM_ADA),
           .ADBsel                      (CRAM_ADB),
           .ADAen                       (CRAM_ADAEN),
           .SH                          (CRAM_SH),
           .ARLsel                      (CRAM_ARL),
           .ARRsel                      (CRAM_ARR),
           .MQsel                       (CRAM_MQ),
           .MQMsel                      (CRAM_MQMSEL),
           .MQMen                       (CRAM_MQMEN),
           .magic                       (CRAM_magic),

           /*AUTOINST*/
           // Outputs
           .ADoverflow00                (ADoverflow00),
           .fmWrite                     (fmWrite),
           .fmParity                    (fmParity),
           .ADcarry36                   (ADcarry36),
           // Inputs
           .clk                         (clk),
           .ADXcarry36                  (ADXcarry36),
           .ADlong                      (ADlong),
           .AR00to08load                (AR00to08load),
           .AR09to17load                (AR09to17load),
           .ARRload                     (ARRload),
           .BRload                      (BRload),
           .BRXload                     (BRXload),
           .ARXLsel                     (ARXLsel[2:0]),
           .ARXRsel                     (ARXRsel[2:0]),
           .ARXload                     (ARXload),
           .AR00to11clr                 (AR00to11clr),
           .AR12to17clr                 (AR12to17clr),
           .ARRclr                      (ARRclr),
           .cacheData                   (cacheData[0:35]),
           .adToEBUS_L                  (adToEBUS_L),
           .adToEBUS_R                  (adToEBUS_R),
           .ADbool                      (ADbool),
           .fmBlk                       (fmBlk[0:2]),
           .fmAdr                       (fmAdr[0:3]),
           .fmWrite00_17                (fmWrite00_17),
           .fmWrite18_35                (fmWrite18_35),
           .diag                        (diag[0:8]),
           .diagReadFunc12X             (diagReadFunc12X),
           .VMAheldOrPC                 (VMAheldOrPC[0:35]));

  ir ir0(.AD(AD),
         .drivingEBUS(IRdrivingEBUS),
         .ebusOut(IR_EBUS),
         /*AUTOINST*/
         // Outputs
         .ADeq0                         (ADeq0),
         .IOlegal                       (IOlegal),
         .ACeq0                         (ACeq0),
         .JRST0                         (JRST0),
         .testSatisfied                 (testSatisfied),
         .norm                          (norm[8:10]),
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
           // Outputs
           .localACAddress              (localACAddress),
           // Inputs
           .clk                         (clk));

  apr apr0(
           .ebusIn(EBUS),
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
           .force1777                   (force1777),
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
           .ADlong                      (ADlong),
           // Inputs
           .clk                         (clk),
           .CRAM_ADcarry                (CRAM_ADcarry),
           .ar                          (ar[0:35]),
           .PCplus1inh                  (PCplus1inh));

  scd scd0(.AR(AR),
           .DIAG(CRAM_DIAG_FUNC),
           .ebusIn(EBUS),
           .drivingEBUS(SCDdrivingEBUS),
           .ebusOut(SCD_EBUS),

           .ARMM(CRAM_CRAM_ARMM),
           .FE(CRAM_FE),
           .SC(CRAM_SC),
           .SCADA(CRAM_SCADA),
           .SCADB(CRAM_SCADB),

           /*AUTOINST*/
           // Outputs
           .SC_GE_36                    (SC_GE_36),
           .SCADeq0                     (SCADeq0),
           .SCADsign                    (SCADsign),
           .SCsign                      (SCsign),
           .FEsign                      (FEsign),
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
           .SH                          (SHM_SH),
           .XR                          (SHM_XR),
           .CRAM_SH                     (CRAM_SH),
           /*AUTOINST*/
           // Outputs
           .indexed                     (indexed),
           .ARextended                  (ARextended),
           .ARparityOdd                 (ARparityOdd),
           // Inputs
           .clk                         (clk),
           .ARcarry36                   (ARcarry36),
           .ARXcarry36                  (ARXcarry36),
           .longEnable                  (longEnable));

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
