`timescale 1ns/1ns
`include "cram-defs.svh"
`include "ebus-defs.svh"

module ebox(input eboxClk,
            input fastMemClk,

            input eboxReset,

            output logic [13:35] EBOX_VMA,
            output logic [10:12] cacheClearer,

            output logic eboxReq,
            input cshEBOXT0,
            input  cshEBOXRetry,
            input mboxRespIn,

            output logic eboxSync,
            output logic mboxClk,

            input pfHold,
            input pfEBOXHandle,
            input pfPublic,

            output logic vmaACRef,

            input [27:35] mboxGateVMA,
            input [0:35] cacheDataRead,
            output [0:35] cacheDataWrite,

            output logic pageTestPriv,
            output logic pageIllEntry,
            output logic eboxUser,

            output logic eboxMayBePaged,
            output logic eboxCache,
            output logic eboxLookEn,
            output logic ki10PagingMode,
            output logic pageAdrCond,

            output logic eboxMap,

            output logic eboxRead,
            output logic eboxPSE,
            output logic eboxWrite,

            output logic upt,
            output logic ept,
            output logic userRef,

            output logic eboxCCA,
            output logic eboxUBR,
            output logic eboxERA,
            output logic eboxEnRefillRAMWr,
            output logic eboxSBUSDiag,
            output logic eboxLoadReg,
            output logic eboxReadReg,

            output logic ptDirWrite,
            output logic ptWr,
            output logic mboxCtl03,
            output logic mboxCtl06,
            output logic wrPtSel0,
            output logic wrPtSel1,

            input [0:10] pfDisp,
            input cshAdrParErr,
            input mbParErr,
            input sbusErr,
            input nxmErr,
            input mboxCDirParErr,
            output logic anyEboxError,

            iEBUS EBUS);

  tEBUSdriver APR_EBUS;
  tEBUSdriver CRA_EBUS;
  tEBUSdriver CTL_EBUS;
  tEBUSdriver EDP_EBUS;
  tEBUSdriver IR_EBUS;

  logic [0:2] APR_FMblk;
  logic [0:3] APR_FMadr;

  logic [0:35] SHM_SH;

  logic loadIR;
  logic loadDRAM;
  logic longEnable;
  logic CTL_ADcarry36;
  logic CTL_ADXcarry36;

  logic CON_fmWrite00_17;
  logic CON_fmWrite18_35;

  logic [8:10] norm;
  logic [0:12] IR;
  logic [9:12] IRAC;
  logic [0:2] DRAM_A;
  logic [0:2] DRAM_B;
  logic [0:10] DRAM_J;
  logic DRAM_ODD_PARITY;

  logic [0:10] NICOND;
  logic PCplus1inh;

  logic [0:3] SR;

  logic CTL_SPEC_AD_LONG;
  logic CTL_AR00to08load;
  logic CTL_AR09to17load;
  logic CTL_ARRload;

  logic CTL_AR00to11clr;
  logic CTL_AR12to17clr;
  logic CTL_ARRclr;

  logic [0:2] CTL_ARL_SEL;
  logic [0:2] CTL_ARR_SEL;
  logic [0:2] CTL_ARXL_SEL;
  logic [0:2] CTL_ARXR_SEL;
  logic CTL_ARX_LOAD;

  logic [0:1] CTL_MQ_SEL;
  logic [0:1] CTL_MQM_SEL;
  logic CTL_MQM_EN;
  logic CTL_inhibitCarry18;
  logic CTL_SPEC_genCarry18;

  logic CTL_adToEBUS_L;
  logic CTL_adToEBUS_R;

  logic CTL_DISP_NICOND;
  logic CTL_SPEC_SCM_ALT;
  logic CTL_SPEC_CLR_FPD;
  logic CTL_SPEC_FLAG_CTL;
  logic CTL_SPEC_SP_MEM_CYCLE;
  logic CTL_SPEC_SAVE_FLAGS;

  logic CTL_diagLoadFunc06x;
  logic CTL_diagReadFunc13x;
  logic CTL_diagReadFunc14X;
  logic CTL_diagReadFunc12x;
  logic CTL_diaFunc051;
  logic CTL_diaFunc052;

  logic inhibitCarry18;
  logic SPEC_genCarry18;
  logic genCarry36;

  logic ADeq0;
  logic IOlegal;
  logic ACeq0;
  logic JRST0;
  logic testSatisfied;


  logic [0:8] SCD_ARMMupper;
  logic [13:17] SCD_ARMMlower;


  logic [0:35] VMA_VMAheldOrPC;

  logic [-2:35] EDP_AD;
  logic [0:35] EDP_ADX;
  logic [0:35] EDP_BR;
  logic [0:35] EDP_BRX;
  logic [0:35] EDP_MQ;
  logic [0:35] EDP_AR;
  logic [0:35] EDP_ARX;
  logic [0:35] FM;
  logic fmParity;

  logic [-2:35] EDP_AD_EX;
  logic [-2:36] EDP_ADcarry;
  logic [0:36] EDP_ADXcarry;
  logic [0:35] EDP_ADoverflow;
  logic EDP_genCarry36;


  logic skipEn40_47;
  logic skipEn50_57;

  logic pcSection0;
  logic localACAddress;
  logic longEnable;
  logic indexed;
  logic FEsign;
  logic SCsign;
  logic SCADsign;
  logic SCADeq0;
  logic FPD;
  logic ARparityOdd;

  logic [10:1] AREAD;
  logic dispParity;

  logic mbXfer;

  tCRADR CRADR;

  iCRAM CRAM();

  // TEMPORARY
  logic force1777;
  logic CONDAdr10;
  logic MULdone;

  // TEMPORARY
  assign force1777 = 0;
  assign CONDAdr10 = 0;
  assign MULdone = 0;

  apr apr0(.*, .EBUSdriver(APR_EBUS));
  con con0(.*);
  cra cra0(.*, .EBUSdriver(CRA_EBUS));
  crm crm0(.*);
  ctl ctl0(.*, .EBUSdriver(CTL_EBUS));
  edp edp0(.*, .EBUSdriver(EDP_EBUS));
  ir  ir0 (.*, .EBUSdriver(IR_EBUS));
endmodule // ebox
