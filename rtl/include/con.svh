`ifndef _CON_INTERFACE_
`define _CON_INTERFACE_ 1

interface iCON;
  
  // XXX These are not driven anywhere in CON?
  logic SKIP_EN40_47;
  logic SKIP_EN50_57;
  logic SKIP_EN60_67;
  logic SKIP_EN70_77;

  logic START;
  logic RUN;
  logic EBOX_HALTED;

  logic KL10_PAGING_MODE;
  logic KI10_PAGING_MODE;

  logic COND_EN00_07;
  logic COND_EN10_17;
  logic COND_EN20_27;
  logic COND_EN30_37;
  logic SKIP_EN40_47;
  logic SKIP_EN50_57;
  logic SKIP_EN60_67;
  logic SKIP_EN70_77;

  logic COND_PCF_MAGIC;
  logic COND_FE_SHRT;
  logic COND_AD_FLAGS;
  logic COND_SEL_VMA;
  logic COND_DIAG_FUNC;
  logic COND_EBUS_CTL;
  logic COND_MBOX_CTL;
  logic COND_024;
  logic COND_026;
  logic COND_027;
  logic COND_VMA_MAGIC;
  logic COND_LOAD_VMA_HELD;
  logic COND_INSTR_ABORT;
  logic COND_ADR_10;
  logic COND_LOAD_IR;
  logic COND_EBUS_STATE;

  logic LONG_EN;
  logic PI_CYCLE;
  logic PCplus1_INH;
  logic MB_XFER;
  logic FM_XFER;
  logic CACHE_LOOK_EN;
  logic LOAD_ACCESS_COND;
  logic LOAD_DRAM;
  logic LOAD_IR;

  logic FM_WRITE00_17;
  logic FM_WRITE18_35;
  logic FM_WRITE_PAR;

  logic IO_LEGAL;
  logic EBUS_GRANT;

  logic CONO_PI;
  logic CONO_PAG;
  logic CONO_APR;
  logic DATAO_APR;
  logic CONO_200000;

  logic SEL_EN;
  logic SEL_DIS;
  logic SEL_CLR;
  logic SEL_SET;

  logic UCODE_STATE1;
  logic UCODE_STATE3;
  logic UCODE_STATE5;
  logic UCODE_STATE7;

  logic PI_DISABLE;
  logic CLR_PRIVATE_INSTR;
  logic TRAP_EN;
  logic NICOND_TRAP_EN;
  logic [7:9] NICOND;
  logic [0:3] SR;
  logic LOAD_SPEC_INSTR;
  logic [0:1] VMA_SEL;

  logic WR_EVEN_PAR_ADR;
  logic DELAY_REQ;
  logic AR_36;
  logic ARX_36;
  logic CACHE_LOAD_EN;
  logic EBUS_REL;
endinterface

`endif
