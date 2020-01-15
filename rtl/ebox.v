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
  wire FORCE1777;
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
           // Inputs
           .clk                         (clk));

  cra cra0(.CONDA10(CONDAdr10),
           .J(CRAM_J),
           .AD(CRAM_AD),
           .ADA(CRAM_ADA),
           .ADAEN(CRAM_ADAEN),
           .ADB(CRAM_ADB),
           .AR(CRAM_AR),
           .ARX(CRAM_ARX),
           .BR(CRAM_BR),
           .BRX(CRAM_BRX),
           .MQ(CRAM_MQ),
           .FMADR(CRAM_FMADR),
           .SCAD(CRAM_SCAD),
           .SCADA(CRAM_SCADA),
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

           /*AUTOINST*/
           // Outputs
           .CRADR                       (CRADR),
           // Inputs
           .clkForce1777                (clkForce1777),
           .MULdone                     (MULdone),
           .DRAM_A                      (DRAM_A),
           .DRAM_B                      (DRAM_B),
           .DRAM_J                      (DRAM_J),
           .dispIn                      (dispIn),
           .condIn                      (condIn));

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
             .CRADR                     (CRADR));

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
           .ARXLsel                     (ARXLsel),
           .ARXRsel                     (ARXRsel),
           .ARXload                     (ARXload),
           .AR00to11clr                 (AR00to11clr),
           .AR12to17clr                 (AR12to17clr),
           .ARRclr                      (ARRclr),
           .cacheData                   (cacheData),
           .adToEBUS_L                  (adToEBUS_L),
           .adToEBUS_R                  (adToEBUS_R),
           .ADbool                      (ADbool),
           .fmBlk                       (fmBlk),
           .fmAdr                       (fmAdr),
           .fmWrite00_17                (fmWrite00_17),
           .fmWrite18_35                (fmWrite18_35),
           .diag                        (diag),
           .diagReadFunc12X             (diagReadFunc12X),
           .VMAheldOrPC                 (VMAheldOrPC));

  ir ir0(.AD(AD),
         .drivingEBUS(IRdrivingEBUS),
         .ebusOut(IR_EBUS),
         /*AUTOINST*/
         // Outputs
         .IOlegal                       (IOlegal),
         .ACeq0                         (ACeq0),
         .JRST0                         (JRST0),
         .testSatisfied                 (testSatisfied),
         .IR                            (IR),
         .IRAC                          (IRAC),
         .DRAM_A                        (DRAM_A),
         .DRAM_B                        (DRAM_B),
         .DRAM_J                        (DRAM_J),
         .DRAM_ODD_PARITY               (DRAM_ODD_PARITY),
         // Inputs
         .clk                           (clk),
         .cacheData                     (cacheData),
         .CRAM_magic                    (CRAM_magic),
         .mbXfer                        (mbXfer),
         .loadIR                        (loadIR),
         .loadDRAM                      (loadDRAM),
         .diag                          (diag),
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
           .ebusIn(EBUS),
           /*AUTOINST*/
           // Outputs
           .fmOut                       (fmOut),
           .ebusReturn                  (ebusReturn),
           .ebusReq                     (ebusReq),
           .ebusDemand                  (ebusDemand),
           .disableCS                   (disableCS),
           .ebusF01                     (ebusF01),
           .coniOrDATAI                 (coniOrDATAI),
           .sendF02                     (sendF02),
           .aprPhysNum                  (aprPhysNum),
           // Inouts
           .ebusD                       (ebusD),
           // Inputs
           .fmIn                        (fmIn),
           .irAC                        (irAC),
           .ad                          (ad),
           .cshAdrParErr                (cshAdrParErr),
           .mbParErr                    (mbParErr),
           .sbusErr                     (sbusErr),
           .nxmErr                      (nxmErr),
           .mboxCDirParErr              (mboxCDirParErr),
           .ds                          (ds),
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
           .ADLONG                      (ADLONG),
           // Inputs
           .clk                         (clk),
           .CRAM_ADcarry                (CRAM_ADcarry),
           .ar                          (ar),
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
           .CRAM_SCAD                   (CRAM_SCAD),
           .CRAM_SCADA                  (CRAM_SCADA),
           .CRAM_SCADB                  (CRAM_SCADB),
           .CRAM_MAGIC                  (CRAM_MAGIC),
           .DIAG_READ_FUNC_13X          (DIAG_READ_FUNC_13X));

  shm shm0(.AR(EDP_AR),
           .ARX(EDP_ARX),
           .AR36(ARcarry36),
           .ARX36(ARXcarry36),
           .longEnable(0),       // XXX
           /*AUTOINST*/
           // Outputs
           .XR                          (XR),
           .indexed                     (indexed),
           .ARextended                  (ARextended),
           .ARparityOdd                 (ARparityOdd),
           // Inputs
           .clk                         (clk),
           .CRAM_SH                     (CRAM_SH));

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
