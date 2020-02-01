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
            output logic [10:12] CACHE_CLEARER,
            output logic EBOX_REQ,
            output logic CLK_EBOX_SYNC,
            output logic mboxClk,

            iEBUS EBUS);

  logic EBUS_PARITY_E;
  logic EBUS_PARITY_ACTIVE_E;

  logic [0:2] APR.FMblk;
  logic [0:3] APR.FMadr;
  logic APR_CLK;
  logic APR_CONO_OR_DATAO;
  logic APR_CONI_OR_DATAI;
  logic APR_EBUS_RETURN;
  logic APR_FM_BIT_36;

  logic [0:35] SHM.SH;
  logic SHM.AR_PAR_ODD;

  logic CON.LOAD_IR;
  logic CON.LOAD_DRAM;
  logic [0:8] CTL.REG_CTL;
  logic CTL.AD_LONG;
  logic CTL_AD_CRY_36;
  logic CTL.ADX_CRY_36;
  logic CTL.INH_CRY_18;
  logic CTL.GEN_CRY_18;

  logic [8:10] norm;
  logic [0:12] IR;
  logic [9:12] IRAC;
  logic [0:2] DRAM_A;
  logic [0:2] DRAM_B;
  logic [0:10] DRAM_J;
  logic DRAM_ODD_PARITY;

  logic [0:10] NICOND;

  logic [0:3] SR;

  logic CTL.AR00to08_LOAD;
  logic CTL.AR09to17_LOAD;
  logic CTL.ARR_LOAD;

  logic CTL_AR_CLR;
  logic CTL.AR00to11_CLR;
  logic CTL.AR12to17_CLR;
  logic CTL.ARR_CLR;
  logic CTL.ARX_CLR;
  logic CTL.ARL_IND;
  logic [0:1] CTL.ARL_IND_SEL;
  logic CTL.MQ_CLR;

  logic [0:2] CTL.ARL_SEL;
  logic [0:2] CTL.ARR_SEL;
  logic [0:2] CTL.ARXL_SEL;
  logic [0:2] CTL.ARXR_SEL;
  logic CTL.ARX_LOAD;

  logic [0:1] CTL.MQ_SEL;
  logic [0:1] CTL.MQM_SEL;
  logic CTL.MQM_EN;

  logic CTL.AD_TO_EBUS_L;
  logic CTL.AD_TO_EBUS_R;

  logic CTL.SPEC_GEN_CRY_18;
  logic CTL_SPEC_AD_LONG;
  logic CTL.SPEC_SCM_ALT;
  logic CTL.SPEC_CLR_FPD;
  logic CTL.SPEC_FLAG_CTL;
  logic CTL.SPEC_SP_MEM_CYCLE;
  logic CTL.SPEC_SAVE_FLAGS;
  logic CTL.SPEC_ADX_CRY_36;
  logic CTL.SPEC_CALL;
  logic CTL.SPEC_SBR_CALL;
  logic CTL.SPEC_XCRY_AR0;

  logic CTL_COND_REG_CTL;
  logic CTL_COND_AR_EXP;
  logic CTL.COND_ARR_LOAD;
  logic CTL.COND_ARLR_LOAD;
  logic CTL.COND_ARLL_LOAD;
  logic CTL.COND_AR_CLR;
  logic CTL.COND_ARX_CLR;

  logic CTL.DIAG_CTL_FUNC_00x;
  logic CTL.DIAG_LD_FUNC_04x;
  logic CTL.DIAG_LOAD_FUNC_06x;
  logic CTL.DIAG_LOAD_FUNC_07x;
  logic CTL.DIAG_LOAD_FUNC_072;
  logic CTL.DIAG_LD_FUNC_073;
  logic CTL.DIAG_LD_FUNC_074;
  logic CTL.DIAG_SYNC_FUNC_075;
  logic CTL.DIAG_LD_FUNC_076;
  logic CTL.DIAG_CLK_EDP;
  logic CTL.DIAG_READ_FUNC_11x;
  logic CTL.DIAG_READ_FUNC_12x;
  logic CTL.DIAG_READ_FUNC_13x;
  logic CTL.DIAG_READ_FUNC_14x;

  logic CTL_diaFunc051;
  logic CTL_diaFunc052;  

  logic CTL.DISP_NICOND;
  logic CTL.DISP_RET;

  logic CTL.PI_CYCLE_SAVE_FLAGS;
  logic CTL.LOAD_PC;

  logic CTL.DIAG_STROBE;
  logic CTL.DIAG_READ;
  logic CTL.DIAG_AR_LOAD;
  logic CTL.DIAG_LD_EBUS_REG;
  logic CTL.EBUS_XFER;

  logic CTL.AD_TO_EBUS_L;
  logic CTL.AD_TO_EBUS_R;
  logic CTL.EBUS_T_TO_E_EN;
  logic CTL.EBUS_E_TO_T_EN;

  logic CTL.EBUS_PARITY_OUT;

  logic DIAG_CHANNEL_CLK_STOP;
  logic CTL.DIAG_FORCE_EXTEND;
  logic [0:6] CTL.DIAG_DIAG;
  logic [4:6] DIAG;

  logic CON.SKIP_EN40_47;
  logic CON.SKIP_EN50_57;
  logic CON.SKIP_EN60_67;
  logic CON.SKIP_EN70_77;

  logic CON.START;
  logic CON.RUN;
  logic CON.EBOX_HALTED;

  logic CON.KL10_PAGING_MODE;
  logic CON.KI10_PAGING_MODE;

  logic CON.COND_EN00_07;
  logic CON.COND_EN10_17;
  logic CON.COND_EN20_27;
  logic CON.COND_EN30_37;
  logic CON.COND_EN40_47;
  logic CON.COND_EN50_57;
  logic CON.COND_EN60_67;
  logic CON.COND_EN70_77;
  logic CON.COND_PCF_MAGIC;
  logic CON.COND_FE_SHRT;
  logic CON_COND_AD_FLAGS;
  logic CON.COND_SEL_VMA;
  logic CON.COND_DIAG_FUNC;
  logic CON.COND_EBUS_CTL;
  logic CON.COND_MBOX_CTL;
  logic CON.COND_024;
  logic CON.COND_026;
  logic CON.COND_027;
  logic CON.COND_VMA_MAGIC;
  logic CON_COND_LOAD_VMA_HELD;
  logic CON.COND_INSTR_ABORT;
  logic CON.COND_ADR_10;
  logic CON.COND_LOAD_IR;
  logic CON.COND_EBUS_STATE;

  logic CON.LONG_EN;
  logic CON.PI_CYCLE;
  logic CON.PCplus1_INH;
  logic CON.FM_XFER;
  logic CON.MB_XFER;
  logic CON.CACHE_LOOK_EN;
  logic CON.LOAD_ACCESS_COND;
  logic CON.LOAD_DRAM;
  logic CON.LOAD_IR;

  logic CON.FM_WRITE00_17;
  logic CON.FM_WRITE18_35;
  logic CON.FM_WRITE_PAR;

  logic CON.IO_LEGAL;
  logic CON.EBUS_GRANT;

  logic CON.CONO_PI;
  logic CON.CONO_PAG;
  logic CON.CONO_APR;
  logic CON.DATAO_APR;
  logic CON.CONO_200000;

  logic CON.SEL_EN;
  logic CON.SEL_DIS;
  logic CON.SEL_CLR;
  logic CON.SEL_SET;

  logic CON.UCODE_STATE1;
  logic CON.UCODE_STATE3;
  logic CON.UCODE_STATE5;
  logic CON.UCODE_STATE7;

  logic CON.PI_DISABLE;
  logic CON.CLR_PRIVATE_INSTR;
  logic CON.TRAP_EN;
  logic CON.NICOND_TRAP_EN;
  logic [7:9] CON.NICOND;
  logic [0:3] CON.SR;
  logic CON.LOAD_SPEC_INSTR;
  logic [0:1] CON.VMA_SEL;

  logic CON.WR_EVEN_PAR_ADR;
  logic CON.DELAY_REQ;
  logic CON.AR_36;
  logic CON.ARX_36;
  logic CON.CACHE_LOAD_EN;
  logic CON.EBUS_REL;

  logic MTR_INTERRUPT_REQ;
  
  logic MR_RESET;
  logic CLK_SBR_CALL;
  logic CLK_RESP_MBOX;
  logic CLK_RESP_SIM;
  logic CLK_PAGE_ERROR;

  logic PI.READY;
  logic PI.EBUS_CP_GRANT;
  logic PI.EXT_TRAN_REC;

  logic P15_GATE_TTL_TO_ECL;

  logic IR.ADeq0;
  logic IR.IO_LEGAL;
  logic IR_ACeq0;
  logic IR.JRST0;
  logic IR.TEST_SATISFIED;

  logic [0:8] SCD.ARMM_UPPER;
  logic [13:17] SCD.ARMM_LOWER;
  logic [0:9] SCD.FE;
  logic [0:9] SCD.SC;
  logic [0:35] SCD.SCADA;
  logic [0:35] SCD.SCADB;
  logic SCD.SC_GE_36;
  logic SCD.SCADeq0;
  logic SCD.SCAD_SIGN;
  logic SCD.SC_SIGN;
  logic SCD.FE_SIGN;
  logic SCD.OV;
  logic SCD.CRY0;
  logic SCD.CRY1;
  logic SCD.FOV;
  logic SCD.FXU;
  logic SCD.FPD;
  logic SCD.PCP;
  logic SCD.DIV_CHK;
  logic SCD.TRAP_REQ1;
  logic SCD.TRAP_REQ2;
  logic SCD.TRAP_CYC1;
  logic SCD.TRAP_CYC2;
  logic SCD.USER;
  logic SCD.USER_IOT;
  logic SCD.PUBLIC;
  logic SCD.PRIVATE;
  logic SCD.ADR_BRK_PREVENT;

  logic [0:35] VMA.VMA_HELD_OR_PC;

  logic [-2:35] EDP.AD;
  logic [0:35] EDP.ADX;
  logic [0:35] EDP.BR;
  logic [0:35] EDP.BRX;
  logic [0:35] EDP.MQ;
  logic [0:35] EDP.AR;
  logic [0:35] EDP.ARX;
  logic [0:35] FM;
  logic fmParity;

  logic [-2:35] EDP.AD_EX;
  logic [-2:36] EDP.AD_CRY;
  logic [0:36] EDP.ADX_CRY;
  logic [0:35] EDP.AD_OV;
  logic EDP_GEN_CRY_36;


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
  clk clk0(.*);
  con con0(.*, .EBUSdriver(CON_EBUS));
  cra cra0(.*, .EBUSdriver(CRA_EBUS));
  crm crm0(.*);
  ctl ctl0(.*, .EBUSdriver(CTL_EBUS));
  edp edp0(.*, .EBUSdriver(EDP_EBUS));
  ir  ir0 (.*, .EBUSdriver(IR_EBUS));
  mcl mcl0(.*);
  mtr mtr0(.*);
  pi  pi0(.*, .EBUSdriver(PI_EBUS));
  scd scd0(.*);
  shm shm0(.*);
  vma vma0(.*);
endmodule // ebox
