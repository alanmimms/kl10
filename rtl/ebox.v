`timescale 1ns / 1ps
module ebox(input eboxClk,
            input fastMemClk,

            output reg [13:35] EBOX_VMA,
            output reg [10:12] cacheClearer,

            output reg eboxReq,
            input cshEBOXT0,
            input  cshEBOXRetry,
            input mboxRespIn,

            output reg eboxSync,
            output reg mboxClk,

            input pfHold,
            input pfEBOXHandle,
            input pfPublic,

            output reg vmaACRef,

            input [27:35] mboxGateVMA,
            input [0:35] cacheDataRead,
            output [0:35] cacheDataWrite,

            output reg pageTestPriv,
            output reg pageIllEntry,
            output reg eboxUser,

            output reg eboxMayBePaged,
            output reg eboxCache,
            output reg eboxLookEn,
            output reg ki10PagingMode,
            output reg pageAdrCond,

            output reg eboxMap,

            output reg eboxRead,
            output reg eboxPSE,
            output reg eboxWrite,

            output reg upt,
            output reg ept,
            output reg userRef,

            output reg eboxCCA,
            output reg eboxUBR,
            output reg eboxERA,
            output reg eboxEnRefillRAMWr,
            output reg eboxSBUSDiag,
            output reg eboxLoadReg,
            output reg eboxReadReg,

            output reg ptDirWrite,
            output reg ptWr,
            output reg mboxCtl03,
            output reg mboxCtl06,
            output reg wrPtSel0,
            output reg wrPtSel1,

            input [0:10] pfDisp,
            input cshAdrParErr,
            input mbParErr,
            input sbusErr,
            input nxmErr,
            input mboxCDirParErr,
            output reg anyEboxError,

            input [0:35] EBUS,
            input [0:7] EBUS_DS,
            output reg APRdrivingEBUS,
            output reg [0:35] APR_EBUS,

            output reg CRAdrivingEBUS,
            output reg [0:35] CRA_EBUS,

            output reg EDPdrivingEBUS,
            output reg [0:35] EDP_EBUS,

            output reg IRdrivingEBUS,
            output reg [0:35] IR_EBUS,

            output reg SCDdrivingEBUS,
            output reg [0:35] SCD_EBUS

            /*AUTOARG*/);

  // TEMPORARY
  wire force1777;
  wire CONDAdr10;
  wire MULdone;

  // TEMPORARY
  assign FORCE1777 = 0;
  assign CONDAdr10 = 0;
  assign MULdone = 0;

  /*AUTOWIRE*/
  // Beginning of automatic wires (for undeclared instantiated-module outputs)
  wire                  ACeq0;                  // From ir0 of ir.v
  wire                  ADR_BRK_PREVENT;        // From scd0 of scd.v
  wire                  ADeq0;                  // From ir0 of ir.v
  wire [0:3]            APR_FMadr;              // From apr0 of apr.v
  wire [0:2]            APR_FMblk;              // From apr0 of apr.v
  wire [1:10]           AREAD;                  // From cra0 of cra.v
  wire                  ARextended;             // From shm0 of shm.v
  wire                  ARparityOdd;            // From shm0 of shm.v
  wire                  CONIorDATAI;            // From apr0 of apr.v
  wire                  CON_fmWrite00_17;       // From con0 of con.v
  wire                  CON_fmWrite18_35;       // From con0 of con.v
  wire [11:0]           CRADR;                  // From cra0 of cra.v
  wire [0:3]            CRAM_ACB;               // From crm0 of crm.v
  wire [0:5]            CRAM_AC_OP;             // From crm0 of crm.v
  wire [0:4]            CRAM_ACmagic;           // From crm0 of crm.v
  wire [0:5]            CRAM_AD;                // From crm0 of crm.v
  wire [0:3]            CRAM_ADA;               // From crm0 of crm.v
  wire [0:1]            CRAM_ADA_EN;            // From crm0 of crm.v
  wire [0:2]            CRAM_ADB;               // From crm0 of crm.v
  wire [0:3]            CRAM_AR;                // From crm0 of crm.v
  wire [0:1]            CRAM_AR0_8;             // From crm0 of crm.v
  wire [0:3]            CRAM_ARL;               // From crm0 of crm.v
  wire [0:2]            CRAM_ARMM;              // From crm0 of crm.v
  wire [0:3]            CRAM_ARX;               // From crm0 of crm.v
  wire [0:3]            CRAM_AR_CTL;            // From crm0 of crm.v
  wire [0:1]            CRAM_BR;                // From crm0 of crm.v
  wire [0:1]            CRAM_BRX;               // From crm0 of crm.v
  wire [0:1]            CRAM_CALL;              // From crm0 of crm.v
  wire [0:4]            CRAM_CLR;               // From crm0 of crm.v
  wire [0:6]            CRAM_COND;              // From crm0 of crm.v
  wire [0:9]            CRAM_DIAG_FUNC;         // From crm0 of crm.v
  wire [0:5]            CRAM_DISP;              // From crm0 of crm.v
  wire [0:9]            CRAM_EA_CALC;           // From crm0 of crm.v
  wire [0:9]            CRAM_EBUS_CTL;          // From crm0 of crm.v
  wire [0:1]            CRAM_EXP_TST;           // From crm0 of crm.v
  wire [0:1]            CRAM_FE;                // From crm0 of crm.v
  wire [0:9]            CRAM_FETCH;             // From crm0 of crm.v
  wire [0:9]            CRAM_FLAG_CTL;          // From crm0 of crm.v
  wire [0:3]            CRAM_FMADR;             // From crm0 of crm.v
  wire [0:1]            CRAM_ISTAT;             // From crm0 of crm.v
  wire [0:11]           CRAM_J;                 // From crm0 of crm.v
  wire [0:1]            CRAM_KLPAGE;            // From crm0 of crm.v
  wire [0:1]            CRAM_LONGPC;            // From crm0 of crm.v
  wire [0:9]            CRAM_MAGIC;             // From crm0 of crm.v
  wire [0:6]            CRAM_MAJVER;            // From crm0 of crm.v
  wire [0:1]            CRAM_MARK;              // From crm0 of crm.v
  wire [0:9]            CRAM_MBOX_CTL;          // From crm0 of crm.v
  wire [0:4]            CRAM_MEM;               // From crm0 of crm.v
  wire [0:3]            CRAM_MINVER;            // From crm0 of crm.v
  wire [0:1]            CRAM_MQ;                // From crm0 of crm.v
  wire [0:2]            CRAM_MQ_CTL;            // From crm0 of crm.v
  wire [0:9]            CRAM_MREG_FNC;          // From crm0 of crm.v
  wire [0:3]            CRAM_MTR_CTL;           // From crm0 of crm.v
  wire [0:1]            CRAM_NONSTD;            // From crm0 of crm.v
  wire [0:9]            CRAM_PC_FLAGS;          // From crm0 of crm.v
  wire [0:1]            CRAM_PMOVE;             // From crm0 of crm.v
  wire [0:1]            CRAM_PV;                // From crm0 of crm.v
  wire [0:3]            CRAM_PXCT;              // From crm0 of crm.v
  wire [0:1]            CRAM_SC;                // From crm0 of crm.v
  wire [0:3]            CRAM_SCAD;              // From crm0 of crm.v
  wire [0:3]            CRAM_SCADA;             // From crm0 of crm.v
  wire [0:1]            CRAM_SCADA_EN;          // From crm0 of crm.v
  wire [0:2]            CRAM_SCADB;             // From crm0 of crm.v
  wire [0:2]            CRAM_SH;                // From crm0 of crm.v
  wire [0:6]            CRAM_SKIP;              // From crm0 of crm.v
  wire [0:5]            CRAM_SPEC;              // From crm0 of crm.v
  wire [0:9]            CRAM_SPEC_INSTR;        // From crm0 of crm.v
  wire [0:9]            CRAM_SP_MEM;            // From crm0 of crm.v
  wire [0:2]            CRAM_TIME;              // From crm0 of crm.v
  wire [0:2]            CRAM_VMA;               // From crm0 of crm.v
  wire [0:2]            CRAM_VMAX;              // From crm0 of crm.v
  wire                  CRY0;                   // From scd0 of scd.v
  wire                  CRY1;                   // From scd0 of scd.v
  wire                  CTL_ADXcarry36;         // From ctl0 of ctl.v
  wire                  CTL_ADcarry36;          // From ctl0 of ctl.v
  wire                  CTL_ADlong;             // From ctl0 of ctl.v
  wire                  CTL_AR00to08load;       // From ctl0 of ctl.v
  wire                  CTL_AR00to11clr;        // From ctl0 of ctl.v
  wire                  CTL_AR09to17load;       // From ctl0 of ctl.v
  wire                  CTL_AR12to17clr;        // From ctl0 of ctl.v
  wire [0:2]            CTL_ARL_SEL;            // From ctl0 of ctl.v
  wire [0:2]            CTL_ARR_SEL;            // From ctl0 of ctl.v
  wire                  CTL_ARRclr;             // From ctl0 of ctl.v
  wire                  CTL_ARRload;            // From ctl0 of ctl.v
  wire [2:0]            CTL_ARXL_SEL;           // From ctl0 of ctl.v
  wire [2:0]            CTL_ARXR_SEL;           // From ctl0 of ctl.v
  wire                  CTL_ARX_LOAD;           // From ctl0 of ctl.v
  wire                  CTL_MQM_EN;             // From ctl0 of ctl.v
  wire [0:1]            CTL_MQM_SEL;            // From ctl0 of ctl.v
  wire [0:1]            CTL_MQ_SEL;             // From ctl0 of ctl.v
  wire                  CTL_SPEC_genCarry18;    // From ctl0 of ctl.v
  wire                  CTL_adToEBUS_L;         // From ctl0 of ctl.v
  wire                  CTL_adToEBUS_R;         // From ctl0 of ctl.v
  wire                  CTL_inhibitCarry18;     // From ctl0 of ctl.v
  wire                  DIV_CHK;                // From scd0 of scd.v
  wire [2:0]            DRAM_A;                 // From ir0 of ir.v
  wire [2:0]            DRAM_B;                 // From ir0 of ir.v
  wire [10:0]           DRAM_J;                 // From ir0 of ir.v
  wire                  DRAM_ODD_PARITY;        // From ir0 of ir.v
  wire [-2:35]          EDP_AD;                 // From edp0 of edp.v
  wire [0:35]           EDP_ADX;                // From edp0 of edp.v
  wire [0:36]           EDP_ADXcarry;           // From edp0 of edp.v
  wire [-2:35]          EDP_AD_EX;              // From edp0 of edp.v
  wire [-2:36]          EDP_ADcarry;            // From edp0 of edp.v
  wire [0:35]           EDP_ADoverflow;         // From edp0 of edp.v
  wire [0:35]           EDP_AR;                 // From edp0 of edp.v
  wire [0:35]           EDP_ARX;                // From edp0 of edp.v
  wire [0:35]           EDP_BR;                 // From edp0 of edp.v
  wire [0:35]           EDP_BRX;                // From edp0 of edp.v
  wire [0:35]           EDP_MQ;                 // From edp0 of edp.v
  wire                  EDP_genCarry36;         // From edp0 of edp.v
  wire                  FEsign;                 // From scd0 of scd.v
  wire [0:35]           FM;                     // From edp0 of edp.v
  wire                  FOV;                    // From scd0 of scd.v
  wire                  FPD;                    // From scd0 of scd.v
  wire                  FXU;                    // From scd0 of scd.v
  wire                  IOlegal;                // From ir0 of ir.v
  wire [0:12]           IR;                     // From ir0 of ir.v
  wire [9:12]           IRAC;                   // From ir0 of ir.v
  wire                  JRST0;                  // From ir0 of ir.v
  wire                  OV;                     // From scd0 of scd.v
  wire                  PCP;                    // From scd0 of scd.v
  wire                  PRIVATE;                // From scd0 of scd.v
  wire                  PUBLIC;                 // From scd0 of scd.v
  wire                  SCADeq0;                // From scd0 of scd.v
  wire                  SCADsign;               // From scd0 of scd.v
  wire [13:17]          SCD_ARMMlower;          // From scd0 of scd.v
  wire [0:8]            SCD_ARMMupper;          // From scd0 of scd.v
  wire [0:9]            SCD_FE;                 // From scd0 of scd.v
  wire [0:9]            SCD_SC;                 // From scd0 of scd.v
  wire [0:35]           SCD_SCADA;              // From scd0 of scd.v
  wire [0:35]           SCD_SCADB;              // From scd0 of scd.v
  wire                  SC_GE_36;               // From scd0 of scd.v
  wire                  SCsign;                 // From scd0 of scd.v
  wire [0:35]           SHM_SH;                 // From shm0 of shm.v
  wire [3:0]            SHM_XR;                 // From shm0 of shm.v
  wire                  TRAP_CYC1;              // From scd0 of scd.v
  wire                  TRAP_CYC2;              // From scd0 of scd.v
  wire                  TRAP_REQ1;              // From scd0 of scd.v
  wire                  TRAP_REQ2;              // From scd0 of scd.v
  wire                  USER;                   // From scd0 of scd.v
  wire                  USER_IOT;               // From scd0 of scd.v
  wire [0:35]           VMA_VMAheldOrPC;        // From vma0 of vma.v
  wire                  aprPhysNum;             // From apr0 of apr.v
  wire                  disableCS;              // From apr0 of apr.v
  wire                  dispParity;             // From cra0 of cra.v
  wire                  eboxReqIn;              // From mcl0 of mcl.v
  wire                  ebusDemand;             // From apr0 of apr.v
  wire                  ebusF01;                // From apr0 of apr.v
  wire                  ebusReq;                // From apr0 of apr.v
  wire                  ebusReturn;             // From apr0 of apr.v
  wire                  fmParity;               // From edp0 of edp.v
  wire                  indexed;                // From shm0 of shm.v
  wire                  loadDRAM;               // From con0 of con.v
  wire                  loadIR;                 // From con0 of con.v
  wire                  localACAddress;         // From vma0 of vma.v
  wire                  longEnable;             // From con0 of con.v
  wire                  mboxXfer;               // From mcl0 of mcl.v
  wire [8:10]           norm;                   // From ir0 of ir.v
  wire                  ptPublic;               // From mcl0 of mcl.v
  wire                  sendF02;                // From apr0 of apr.v
  wire                  testSatisfied;          // From ir0 of ir.v
  // End of automatics

  /*AUTOREG*/

  reg [0:10] NICOND;
  reg [0:3] SR;

  con con0(/*AUTOINST*/
           // Outputs
           .loadIR                      (loadIR),
           .loadDRAM                    (loadDRAM),
           .longEnable                  (longEnable),
           .CON_fmWrite00_17            (CON_fmWrite00_17),
           .CON_fmWrite18_35            (CON_fmWrite18_35),
           // Inputs
           .eboxClk                     (eboxClk));

  cra cra0(/*AUTOINST*/
           // Outputs
           .CRADR                       (CRADR[11:0]),
           .AREAD                       (AREAD[1:10]),
           .dispParity                  (dispParity),
           .CRAdrivingEBUS              (CRAdrivingEBUS),
           .CRA_EBUS                    (CRA_EBUS[0:35]),
           // Inputs
           .eboxClk                     (eboxClk),
           .fastMemClk                  (fastMemClk),
           .force1777                   (force1777),
           .MULdone                     (MULdone),
           .DRAM_A                      (DRAM_A[0:3]),
           .DRAM_B                      (DRAM_B[0:3]),
           .DRAM_J                      (DRAM_J[0:9]),
           .CRAM_J                      (CRAM_J[10:0]),
           .CRAM_MEM                    (CRAM_MEM[3:0]),
           .CRAM_SKIP                   (CRAM_SKIP[5:0]),
           .CRAM_COND                   (CRAM_COND[5:0]),
           .CRAM_CALL                   (CRAM_CALL),
           .CRAM_DISP                   (CRAM_DISP[4:0]),
           .CRAM_SPEC                   (CRAM_SPEC[4:0]),
           .CRAM_DIAG_FUNC              (CRAM_DIAG_FUNC[0:8]),
           .CRAM_MARK                   (CRAM_MARK),
           .CRAM_MAGIC                  (CRAM_MAGIC[8:0]),
           .EBUS                        (EBUS[0:35]),
           .norm                        (norm[8:10]),
           .NICOND                      (NICOND[0:10]),
           .SR                          (SR[0:3]),
           .SHM_SH                      (SHM_SH[0:35]),
           .EDP_MQ                      (EDP_MQ[0:35]),
           .EDP_BR                      (EDP_BR[0:35]),
           .EDP_AD                      (EDP_AD[0:35]),
           .EDP_ADX                     (EDP_ADX[0:35]),
           .EDP_AR                      (EDP_AR[0:35]),
           .EDP_ARX                     (EDP_ARX[0:35]),
           .EDP_ADcarry                 (EDP_ADcarry[-2:36]),
           .pfDisp                      (pfDisp[0:10]),
           .skipEn40_47                 (skipEn40_47),
           .skipEn50_57                 (skipEn50_57),
           .diagReadFunc14X             (diagReadFunc14X),
           .diaFunc051                  (diaFunc051),
           .diaFunc052                  (diaFunc052),
           .pcSection0                  (pcSection0),
           .localACAddress              (localACAddress),
           .longEnable                  (longEnable),
           .indexed                     (indexed),
           .ADeq0                       (ADeq0),
           .ACeq0                       (ACeq0),
           .FEsign                      (FEsign),
           .SCsign                      (SCsign),
           .SCADsign                    (SCADsign),
           .SCADeq0                     (SCADeq0),
           .FPD                         (FPD),
           .ARparityOdd                 (ARparityOdd));

  crm crm0(/*AUTOINST*/
           // Outputs
           .CRAM_J                      (CRAM_J[0:11]),
           .CRAM_AD                     (CRAM_AD[0:5]),
           .CRAM_ADA                    (CRAM_ADA[0:3]),
           .CRAM_ADA_EN                 (CRAM_ADA_EN[0:1]),
           .CRAM_ADB                    (CRAM_ADB[0:2]),
           .CRAM_AR                     (CRAM_AR[0:3]),
           .CRAM_ARX                    (CRAM_ARX[0:3]),
           .CRAM_BR                     (CRAM_BR[0:1]),
           .CRAM_BRX                    (CRAM_BRX[0:1]),
           .CRAM_MQ                     (CRAM_MQ[0:1]),
           .CRAM_FMADR                  (CRAM_FMADR[0:3]),
           .CRAM_SCAD                   (CRAM_SCAD[0:3]),
           .CRAM_SCADA                  (CRAM_SCADA[0:3]),
           .CRAM_SCADA_EN               (CRAM_SCADA_EN[0:1]),
           .CRAM_SCADB                  (CRAM_SCADB[0:2]),
           .CRAM_SC                     (CRAM_SC[0:1]),
           .CRAM_FE                     (CRAM_FE[0:1]),
           .CRAM_SH                     (CRAM_SH[0:2]),
           .CRAM_ARMM                   (CRAM_ARMM[0:2]),
           .CRAM_VMAX                   (CRAM_VMAX[0:2]),
           .CRAM_VMA                    (CRAM_VMA[0:2]),
           .CRAM_TIME                   (CRAM_TIME[0:2]),
           .CRAM_MEM                    (CRAM_MEM[0:4]),
           .CRAM_SKIP                   (CRAM_SKIP[0:6]),
           .CRAM_COND                   (CRAM_COND[0:6]),
           .CRAM_CALL                   (CRAM_CALL[0:1]),
           .CRAM_DISP                   (CRAM_DISP[0:5]),
           .CRAM_SPEC                   (CRAM_SPEC[0:5]),
           .CRAM_MARK                   (CRAM_MARK[0:1]),
           .CRAM_MAGIC                  (CRAM_MAGIC[0:9]),
           .CRAM_MAJVER                 (CRAM_MAJVER[0:6]),
           .CRAM_MINVER                 (CRAM_MINVER[0:3]),
           .CRAM_KLPAGE                 (CRAM_KLPAGE[0:1]),
           .CRAM_LONGPC                 (CRAM_LONGPC[0:1]),
           .CRAM_NONSTD                 (CRAM_NONSTD[0:1]),
           .CRAM_PV                     (CRAM_PV[0:1]),
           .CRAM_PMOVE                  (CRAM_PMOVE[0:1]),
           .CRAM_ISTAT                  (CRAM_ISTAT[0:1]),
           .CRAM_PXCT                   (CRAM_PXCT[0:3]),
           .CRAM_ACB                    (CRAM_ACB[0:3]),
           .CRAM_ACmagic                (CRAM_ACmagic[0:4]),
           .CRAM_AC_OP                  (CRAM_AC_OP[0:5]),
           .CRAM_AR0_8                  (CRAM_AR0_8[0:1]),
           .CRAM_CLR                    (CRAM_CLR[0:4]),
           .CRAM_ARL                    (CRAM_ARL[0:3]),
           .CRAM_AR_CTL                 (CRAM_AR_CTL[0:3]),
           .CRAM_EXP_TST                (CRAM_EXP_TST[0:1]),
           .CRAM_MQ_CTL                 (CRAM_MQ_CTL[0:2]),
           .CRAM_PC_FLAGS               (CRAM_PC_FLAGS[0:9]),
           .CRAM_FLAG_CTL               (CRAM_FLAG_CTL[0:9]),
           .CRAM_SPEC_INSTR             (CRAM_SPEC_INSTR[0:9]),
           .CRAM_FETCH                  (CRAM_FETCH[0:9]),
           .CRAM_EA_CALC                (CRAM_EA_CALC[0:9]),
           .CRAM_SP_MEM                 (CRAM_SP_MEM[0:9]),
           .CRAM_MREG_FNC               (CRAM_MREG_FNC[0:9]),
           .CRAM_MBOX_CTL               (CRAM_MBOX_CTL[0:9]),
           .CRAM_MTR_CTL                (CRAM_MTR_CTL[0:3]),
           .CRAM_EBUS_CTL               (CRAM_EBUS_CTL[0:9]),
           .CRAM_DIAG_FUNC              (CRAM_DIAG_FUNC[0:9]),
           // Inputs
           .eboxClk                     (eboxClk),
           .CRADR                       (CRADR[0:11]));

  edp edp0(/*AUTOINST*/
           // Outputs
           .cacheDataWrite              (cacheDataWrite[0:35]),
           .EDP_AD                      (EDP_AD[-2:35]),
           .EDP_ADX                     (EDP_ADX[0:35]),
           .EDP_BR                      (EDP_BR[0:35]),
           .EDP_BRX                     (EDP_BRX[0:35]),
           .EDP_MQ                      (EDP_MQ[0:35]),
           .EDP_AR                      (EDP_AR[0:35]),
           .EDP_ARX                     (EDP_ARX[0:35]),
           .FM                          (FM[0:35]),
           .fmParity                    (fmParity),
           .EDP_AD_EX                   (EDP_AD_EX[-2:35]),
           .EDP_ADcarry                 (EDP_ADcarry[-2:36]),
           .EDP_ADXcarry                (EDP_ADXcarry[0:36]),
           .EDP_ADoverflow              (EDP_ADoverflow[0:35]),
           .EDP_genCarry36              (EDP_genCarry36),
           .EDPdrivingEBUS              (EDPdrivingEBUS),
           .EDP_EBUS                    (EDP_EBUS[0:35]),
           // Inputs
           .eboxClk                     (eboxClk),
           .fastMemClk                  (fastMemClk),
           .CTL_ADcarry36               (CTL_ADcarry36),
           .CTL_ADXcarry36              (CTL_ADXcarry36),
           .CTL_ADlong                  (CTL_ADlong),
           .CRAM_AD                     (CRAM_AD[0:5]),
           .CRAM_ADA                    (CRAM_ADA[0:3]),
           .CRAM_ADA_EN                 (CRAM_ADA_EN[0:1]),
           .CRAM_ADB                    (CRAM_ADB[0:1]),
           .CRAM_AR                     (CRAM_AR[0:3]),
           .CRAM_ARX                    (CRAM_ARX[0:3]),
           .CRAM_MAGIC                  (CRAM_MAGIC[0:8]),
           .CRAM_BRload                 (CRAM_BRload),
           .CRAM_BRXload                (CRAM_BRXload),
           .CTL_ARL_SEL                 (CTL_ARL_SEL[0:2]),
           .CTL_ARR_SEL                 (CTL_ARR_SEL[0:2]),
           .CTL_AR00to08load            (CTL_AR00to08load),
           .CTL_AR09to17load            (CTL_AR09to17load),
           .CTL_ARRload                 (CTL_ARRload),
           .CTL_AR00to11clr             (CTL_AR00to11clr),
           .CTL_AR12to17clr             (CTL_AR12to17clr),
           .CTL_ARRclr                  (CTL_ARRclr),
           .CTL_ARXL_SEL                (CTL_ARXL_SEL[0:2]),
           .CTL_ARXR_SEL                (CTL_ARXR_SEL[0:2]),
           .CTL_ARX_LOAD                (CTL_ARX_LOAD),
           .CTL_MQ_SEL                  (CTL_MQ_SEL[0:1]),
           .CTL_MQM_SEL                 (CTL_MQM_SEL[0:1]),
           .CTL_MQM_EN                  (CTL_MQM_EN),
           .CTL_inhibitCarry18          (CTL_inhibitCarry18),
           .CTL_SPEC_genCarry18         (CTL_SPEC_genCarry18),
           .cacheDataRead               (cacheDataRead[0:35]),
           .EBUS                        (EBUS[0:35]),
           .SHM_SH                      (SHM_SH[0:35]),
           .SCD_ARMMupper               (SCD_ARMMupper[0:8]),
           .SCD_ARMMlower               (SCD_ARMMlower[13:17]),
           .CTL_adToEBUS_L              (CTL_adToEBUS_L),
           .CTL_adToEBUS_R              (CTL_adToEBUS_R),
           .APR_FMblk                   (APR_FMblk[0:2]),
           .APR_FMadr                   (APR_FMadr[0:3]),
           .CON_fmWrite00_17            (CON_fmWrite00_17),
           .CON_fmWrite18_35            (CON_fmWrite18_35),
           .CRAM_DIAG_FUNC              (CRAM_DIAG_FUNC[0:8]),
           .diagReadFunc12X             (diagReadFunc12X),
           .VMA_VMAheldOrPC             (VMA_VMAheldOrPC[0:35]));

  ir ir0(/*AUTOINST*/
         // Outputs
         .ADeq0                         (ADeq0),
         .IOlegal                       (IOlegal),
         .ACeq0                         (ACeq0),
         .JRST0                         (JRST0),
         .testSatisfied                 (testSatisfied),
         .IRdrivingEBUS                 (IRdrivingEBUS),
         .IR_EBUS                       (IR_EBUS[0:35]),
         .norm                          (norm[8:10]),
         .IR                            (IR[0:12]),
         .IRAC                          (IRAC[9:12]),
         .DRAM_A                        (DRAM_A[2:0]),
         .DRAM_B                        (DRAM_B[2:0]),
         .DRAM_J                        (DRAM_J[10:0]),
         .DRAM_ODD_PARITY               (DRAM_ODD_PARITY),
         // Inputs
         .eboxClk                       (eboxClk),
         .cacheDataRead                 (cacheDataRead[0:35]),
         .EDP_AD                        (EDP_AD[0:35]),
         .CRAM_DIAG_FUNC                (CRAM_DIAG_FUNC[0:8]),
         .CRAM_MAGIC                    (CRAM_MAGIC[0:8]),
         .mbXfer                        (mbXfer),
         .loadIR                        (loadIR),
         .loadDRAM                      (loadDRAM),
         .diagLoadFunc06X               (diagLoadFunc06X),
         .diagReadFunc13X               (diagReadFunc13X),
         .inhibitCarry18                (inhibitCarry18),
         .SPEC_genCarry18               (SPEC_genCarry18),
         .genCarry36                    (genCarry36),
         .EDP_ADcarry                   (EDP_ADcarry[-2:36]),
         .EDP_ADXcarry                  (EDP_ADXcarry[0:36]));

  vma vma0(
           /*AUTOINST*/
           // Outputs
           .VMA_VMAheldOrPC             (VMA_VMAheldOrPC[0:35]),
           .localACAddress              (localACAddress),
           // Inputs
           .eboxClk                     (eboxClk));

  apr apr0(/*AUTOINST*/
           // Outputs
           .ebusReturn                  (ebusReturn),
           .ebusReq                     (ebusReq),
           .ebusDemand                  (ebusDemand),
           .disableCS                   (disableCS),
           .ebusF01                     (ebusF01),
           .CONIorDATAI                 (CONIorDATAI),
           .sendF02                     (sendF02),
           .aprPhysNum                  (aprPhysNum),
           .APR_FMblk                   (APR_FMblk[0:2]),
           .APR_FMadr                   (APR_FMadr[0:3]),
           .APRdrivingEBUS              (APRdrivingEBUS),
           .APR_EBUS                    (APR_EBUS[0:35]),
           // Inputs
           .FM                          (FM[0:35]),
           .IRAC                        (IRAC[9:12]),
           .EDP_AD                      (EDP_AD[0:35]),
           .cshAdrParErr                (cshAdrParErr),
           .mbParErr                    (mbParErr),
           .sbusErr                     (sbusErr),
           .nxmErr                      (nxmErr),
           .mboxCDirParErr              (mboxCDirParErr),
           .EBUS                        (EBUS[0:35]),
           .EBUS_DS                     (EBUS_DS[0:7]),
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
           .eboxClk                     (eboxClk),
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
           .CTL_AR00to08load            (CTL_AR00to08load),
           .CTL_AR09to17load            (CTL_AR09to17load),
           .CTL_ARRload                 (CTL_ARRload),
           .CTL_AR00to11clr             (CTL_AR00to11clr),
           .CTL_AR12to17clr             (CTL_AR12to17clr),
           .CTL_ARRclr                  (CTL_ARRclr),
           .CTL_ARL_SEL                 (CTL_ARL_SEL[0:2]),
           .CTL_ARR_SEL                 (CTL_ARR_SEL[0:2]),
           .CTL_ARXL_SEL                (CTL_ARXL_SEL[2:0]),
           .CTL_ARXR_SEL                (CTL_ARXR_SEL[2:0]),
           .CTL_ARX_LOAD                (CTL_ARX_LOAD),
           .CTL_MQ_SEL                  (CTL_MQ_SEL[0:1]),
           .CTL_MQM_SEL                 (CTL_MQM_SEL[0:1]),
           .CTL_MQM_EN                  (CTL_MQM_EN),
           .CTL_inhibitCarry18          (CTL_inhibitCarry18),
           .CTL_SPEC_genCarry18         (CTL_SPEC_genCarry18),
           .CTL_adToEBUS_L              (CTL_adToEBUS_L),
           .CTL_adToEBUS_R              (CTL_adToEBUS_R),
           .CTL_ADcarry36               (CTL_ADcarry36),
           .CTL_ADXcarry36              (CTL_ADXcarry36),
           .CTL_ADlong                  (CTL_ADlong),
           // Inputs
           .eboxClk                     (eboxClk),
           .CRAM_ADcarry                (CRAM_ADcarry),
           .EDP_AR                      (EDP_AR[0:35]),
           .PCplus1inh                  (PCplus1inh));

  scd scd0(/*AUTOINST*/
           // Outputs
           .SCDdrivingEBUS              (SCDdrivingEBUS),
           .SCD_EBUS                    (SCD_EBUS[0:35]),
           .SCD_ARMMupper               (SCD_ARMMupper[0:8]),
           .SCD_ARMMlower               (SCD_ARMMlower[13:17]),
           .SCD_FE                      (SCD_FE[0:9]),
           .SCD_SC                      (SCD_SC[0:9]),
           .SCD_SCADA                   (SCD_SCADA[0:35]),
           .SCD_SCADB                   (SCD_SCADB[0:35]),
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
           .eboxClk                     (eboxClk),
           .CRAM_SCAD                   (CRAM_SCAD[2:0]),
           .CRAM_SCADA                  (CRAM_SCADA[1:0]),
           .CRAM_SCADB                  (CRAM_SCADB[1:0]),
           .EDP_AR                      (EDP_AR[0:35]),
           .CRAM_MAGIC                  (CRAM_MAGIC[0:8]),
           .CRAM_DIAG_FUNC              (CRAM_DIAG_FUNC[0:8]),
           .DIAG_READ_FUNC_13X          (DIAG_READ_FUNC_13X));

  shm shm0(/*AUTOINST*/
           // Outputs
           .SHM_SH                      (SHM_SH[0:35]),
           .SHM_XR                      (SHM_XR[3:0]),
           .indexed                     (indexed),
           .ARextended                  (ARextended),
           .ARparityOdd                 (ARparityOdd),
           // Inputs
           .eboxClk                     (eboxClk),
           .EDP_AR                      (EDP_AR[0:35]),
           .EDP_ARX                     (EDP_ARX[0:35]),
           .ARcarry36                   (ARcarry36),
           .ARXcarry36                  (ARXcarry36),
           .longEnable                  (longEnable),
           .CRAM_SH                     (CRAM_SH[1:0]));

  csh csh0(/*AUTOINST*/
           // Inputs
           .eboxClk                     (eboxClk));

  cha cha0(/*AUTOINST*/
           // Inputs
           .eboxClk                     (eboxClk));

  chx chx0(/*AUTOINST*/
           // Inputs
           .eboxClk                     (eboxClk));

  pma pma0(/*AUTOINST*/
           // Inputs
           .eboxClk                     (eboxClk));

  pag pag0(/*AUTOINST*/
           // Inputs
           .eboxClk                     (eboxClk));

  chd chd0(/*AUTOINST*/
           // Inputs
           .eboxClk                     (eboxClk));

  mbc mbc0(/*AUTOINST*/
           // Inputs
           .eboxClk                     (eboxClk));

  mbz mbz0(/*AUTOINST*/
           // Inputs
           .eboxClk                     (eboxClk));

  pic pic0(/*AUTOINST*/
           // Inputs
           .eboxClk                     (eboxClk));

  chc chc0(/*AUTOINST*/
           // Inputs
           .eboxClk                     (eboxClk));

  ccw ccw0(/*AUTOINST*/
           // Inputs
           .eboxClk                     (eboxClk));

  crc crc0(/*AUTOINST*/
           // Inputs
           .eboxClk                     (eboxClk));

  ccl ccl0(/*AUTOINST*/
           // Inputs
           .eboxClk                     (eboxClk));

  mtr mtr0(/*AUTOINST*/
           // Inputs
           .eboxClk                     (eboxClk));

  dps dps0(/*AUTOINST*/
           // Inputs
           .eboxClk                     (eboxClk));
endmodule // ebox
