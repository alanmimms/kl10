`timescale 1ns/1ns
`include "cram-defs.svh"
`include "ebus-defs.svh"

module ebox(input eboxClk,
            input fastMemClk,

            input eboxReset,

            input CSH_PAR_BIT_A,
            input CSH_PAR_BIT_B,
            input cshEBOXT0,
            input cshEBOXRetry,
            input mboxRespIn,

            input MCL_SHORT_STACK,
            input MCL_18_BIT_EA,
            input MCL_23_BIT_EA,
            input MCL_MEM_ARL_IND,
            input MCL_VMA_SECTION_0,
            input MCL_MBOX_CYC_REQ,
            input MCL_VMA_FETCH,
            input MCL_LOAD_AR,
            input MCL_LOAD_ARX,
            input MCL_LOAD_VMA,
            input MCL_STORE_AR,
            input MCL_SKIP_SATISFIED,

            input pfHold,
            input pfEBOXHandle,
            input pfPublic,

            input [0:10] pfDisp,
            input cshAdrParErr,
            input mbParErr,
            input sbusErr,
            input nxmErr,
            input mboxCDirParErr,

            input [27:35] MBOX_GATE_VMA,
            input [0:35] cacheDataRead,

            tEBUSdriver APR_EBUS,
            tEBUSdriver CON_EBUS,
            tEBUSdriver CRA_EBUS,
            tEBUSdriver CTL_EBUS,
            tEBUSdriver EDP_EBUS,
            tEBUSdriver IR_EBUS,
            tEBUSdriver PI_EBUS,

            output [0:35] cacheDataWrite,

            output logic pageTestPriv,
            output logic pageIllEntry,
            output logic eboxUser,

            output logic eboxMayBePaged,
            output logic eboxCache,
            output logic eboxLookEn,
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

            output logic anyEboxError,

            output logic [13:35] EBOX_VMA,
            output logic [10:12] cacheClearer,
            output logic EBOX_REQ,
            output logic CLK_EBOX_SYNC,
            output logic mboxClk,

            iEBUS EBUS);

  logic EBUS_PARITY_E;
  logic EBUS_PARITY_ACTIVE_E;

  logic [0:2] APR_FMblk;
  logic [0:3] APR_FMadr;
  logic APR_CLK;
  logic APR_CONO_OR_DATAO;
  logic APR_CONI_OR_DATAI;
  logic APR_EBUS_RETURN;
  logic APR_FM_BIT_36;

  logic [0:35] SHM_SH;
  logic SHM_AR_PAR_ODD;

  logic loadIR;
  logic loadDRAM;
  logic [0:8] CTL_REG_CTL;
  logic CTL_AD_LONG;
  logic CTL_AD_CRY_36;
  logic CTL_ADX_CRY_36;
  logic CTL_INH_CRY_18;
  logic CTL_GEN_CRY_18;

  logic [8:10] norm;
  logic [0:12] IR;
  logic [9:12] IRAC;
  logic [0:2] DRAM_A;
  logic [0:2] DRAM_B;
  logic [0:10] DRAM_J;
  logic DRAM_ODD_PARITY;

  logic [0:10] NICOND;

  logic [0:3] SR;

  logic CTL_AR00to08_LOAD;
  logic CTL_AR09to17_LOAD;
  logic CTL_ARR_LOAD;

  logic CTL_AR_CLR;
  logic CTL_AR00to11_CLR;
  logic CTL_AR12to17_CLR;
  logic CTL_ARR_CLR;
  logic CTL_ARX_CLR;
  logic CTL_ARL_IND;
  logic [0:1] CTL_ARL_IND_SEL;
  logic CTL_MQ_CLR;

  logic [0:2] CTL_ARL_SEL;
  logic [0:2] CTL_ARR_SEL;
  logic [0:2] CTL_ARXL_SEL;
  logic [0:2] CTL_ARXR_SEL;
  logic CTL_ARX_LOAD;

  logic [0:1] CTL_MQ_SEL;
  logic [0:1] CTL_MQM_SEL;
  logic CTL_MQM_EN;

  logic CTL_adToEBUS_L;
  logic CTL_adToEBUS_R;

  logic CTL_SPEC_GEN_CRY18;
  logic CTL_SPEC_AD_LONG;
  logic CTL_SPEC_SCM_ALT;
  logic CTL_SPEC_CLR_FPD;
  logic CTL_SPEC_FLAG_CTL;
  logic CTL_SPEC_SP_MEM_CYCLE;
  logic CTL_SPEC_SAVE_FLAGS;
  logic CTL_SPEC_ADX_CRY_36;
  logic CTL_SPEC_CALL;
  logic CTL_SPEC_SBR_CALL;
  logic CTL_SPEC_XCRY_AR0;

  logic CTL_COND_REG_CTL;
  logic CTL_COND_AR_EXP;
  logic CTL_COND_ARR_LOAD;
  logic CTL_COND_ARLR_LOAD;
  logic CTL_COND_ARLL_LOAD;
  logic CTL_COND_AR_CLR;
  logic CTL_COND_ARX_CLR;

  logic CTL_DIAG_CTL_FUNC_00x;
  logic CTL_DIAG_LD_FUNC_04x;
  logic CTL_DIAG_LOAD_FUNC_06x;
  logic CTL_DIAG_LOAD_FUNC_07x;
  logic CTL_DIAG_LOAD_FUNC_072;
  logic CTL_DIAG_LD_FUNC_073;
  logic CTL_DIAG_LD_FUNC_074;
  logic CTL_DIAG_SYNC_FUNC_075;
  logic CTL_DIAG_LD_FUNC_076;
  logic CTL_DIAG_CLK_EDP;
  logic CTL_DIAG_READ_FUNC_11x;
  logic CTL_DIAG_READ_FUNC_12x;
  logic CTL_DIAG_READ_FUNC_13x;
  logic CTL_DIAG_READ_FUNC_14x;

  logic CTL_diaFunc051;
  logic CTL_diaFunc052;  

  logic CTL_DISP_NICOND;
  logic CTL_DISP_RET;

  logic CTL_PI_CYCLE_SAVE_FLAGS;
  logic CTL_LOAD_PC;

  logic CTL_DIAG_STROBE;
  logic CTL_DIAG_READ;
  logic CTL_DIAG_AR_LOAD;
  logic CTL_DIAG_LD_EBUS_REG;
  logic CTL_EBUS_XFER;

  logic CTL_AD_TO_EBUS_L;
  logic CTL_AD_TO_EBUS_R;
  logic CTL_EBUS_T_TO_E_EN;
  logic CTL_EBUS_E_TO_T_EN;

  logic CTL_EBUS_PARITY_OUT;

  logic DIAG_CHANNEL_CLK_STOP;
  logic CTL_DIAG_FORCE_EXTEND;
  logic [0:6] CTL_DIAG_DIAG;
  logic [4:6] DIAG;

  logic CON_SKIP_EN40_47;
  logic CON_SKIP_EN50_57;
  logic CON_SKIP_EN60_67;
  logic CON_SKIP_EN70_77;

  logic CON_START;
  logic CON_RUN;
  logic CON_EBOX_HALTED;

  logic CON_KL10_PAGING_MODE;
  logic CON_KI10_PAGING_MODE;

  logic CON_COND_EN00_07;
  logic CON_COND_EN10_17;
  logic CON_COND_EN20_27;
  logic CON_COND_EN30_37;
  logic CON_COND_EN40_47;
  logic CON_COND_EN50_57;
  logic CON_COND_EN60_67;
  logic CON_COND_EN70_77;
  logic CON_COND_PCF_MAGIC;
  logic CON_COND_FE_SHRT;
  logic CON_COND_AD_FLAGS;
  logic CON_COND_SEL_VMA;
  logic CON_COND_DIAG_FUNC;
  logic CON_COND_EBUS_CTL;
  logic CON_COND_MBOX_CTL;
  logic CON_COND_024;
  logic CON_COND_026;
  logic CON_COND_027;
  logic CON_COND_VMA_MAGIC;
  logic CON_COND_LOAD_VMA_HELD;
  logic CON_COND_INSTR_ABORT;
  logic CON_COND_ADR_10;
  logic CON_COND_LOAD_IR;
  logic CON_COND_EBUS_STATE;

  logic CON_LONG_EN;
  logic CON_PI_CYCLE;
  logic CON_PCplus1_INH;
  logic CON_FM_XFER;
  logic CON_MB_XFER;
  logic CON_CACHE_LOOK_EN;
  logic CON_LOAD_ACCESS_COND;
  logic CON_LOAD_DRAM;
  logic CON_LOAD_IR;

  logic CON_FM_WRITE00_17;
  logic CON_FM_WRITE18_35;
  logic CON_FM_WRITE_PAR;

  logic CON_IO_LEGAL;
  logic CON_EBUS_GRANT;

  logic CON_CONO_PI;
  logic CON_CONO_PAG;
  logic CON_CONO_APR;
  logic CON_DATAO_APR;
  logic CON_CONO_200000;

  logic CON_SEL_EN;
  logic CON_SEL_DIS;
  logic CON_SEL_CLR;
  logic CON_SEL_SET;

  logic CON_UCODE_STATE1;
  logic CON_UCODE_STATE3;
  logic CON_UCODE_STATE5;
  logic CON_UCODE_STATE7;

  logic CON_PI_DISABLE;
  logic CON_CLR_PRIVATE_INSTR;
  logic CON_TRAP_EN;
  logic CON_NICOND_TRAP_EN;
  logic [7:9] CON_NICOND;
  logic [0:3] CON_SR;
  logic CON_LOAD_SPEC_INSTR;
  logic [0:1] CON_VMA_SEL;

  logic CON_WR_EVEN_PAR_ADR;
  logic CON_DELAY_REQ;
  logic CON_AR_36;
  logic CON_ARX_36;
  logic CON_CACHE_LOAD_EN;
  logic CON_EBUS_REL;

  logic MTR_INTERRUPT_REQ;
  
  logic MR_RESET;
  logic CLK_SBR_CALL;
  logic CLK_RESP_MBOX;
  logic CLK_RESP_SIM;
  logic CLK_PAGE_ERROR;

  logic PI_READY;
  logic PI_EBUS_CP_GRANT;
  logic PI_EXT_TRAN_REC;

  logic P15_GATE_TTL_TO_ECL;

  logic IR_ADeq0;
  logic IR_IO_LEGAL;
  logic IR_ACeq0;
  logic IR_JRST0;
  logic IR_TEST_SATISFIED;

  logic [0:8] SCD_ARMM_UPPER;
  logic [13:17] SCD_ARMM_LOWER;
  logic [0:9] SCD_FE;
  logic [0:9] SCD_SC;
  logic [0:35] SCD_SCADA;
  logic [0:35] SCD_SCADB;
  logic SCD_SC_GE_36;
  logic SCD_SCADeq0;
  logic SCD_SCAD_SIGN;
  logic SCD_SC_SIGN;
  logic SCD_FE_SIGN;
  logic SCD_OV;
  logic SCD_CRY0;
  logic SCD_CRY1;
  logic SCD_FOV;
  logic SCD_FXU;
  logic SCD_FPD;
  logic SCD_PCP;
  logic SCD_DIV_CHK;
  logic SCD_TRAP_REQ1;
  logic SCD_TRAP_REQ2;
  logic SCD_TRAP_CYC1;
  logic SCD_TRAP_CYC2;
  logic SCD_USER;
  logic SCD_USER_IOT;
  logic SCD_PUBLIC;
  logic SCD_PRIVATE;
  logic SCD_ADR_BRK_PREVENT;

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
  logic indexed;
  logic FEsign;
  logic SCsign;
  logic SCADsign;
  logic SCADeq0;
  logic FPD;
  logic ARparityOdd;

  logic [10:1] AREAD;
  logic dispParity;

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
  con con0(.*, .EBUSdriver(CON_EBUS));
  cra cra0(.*, .EBUSdriver(CRA_EBUS));
  crm crm0(.*);
  ctl ctl0(.*, .EBUSdriver(CTL_EBUS));
  edp edp0(.*, .EBUSdriver(EDP_EBUS));
  ir  ir0 (.*, .EBUSdriver(IR_EBUS));
  pic pic0(.*, .EBUSdriver(PI_EBUS));
endmodule // ebox
