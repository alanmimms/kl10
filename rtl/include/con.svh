`ifndef _CON_INTERFACE_
`define _CON_INTERFACE_ 1

interface iCON;
  
  // XXX These are not driven anywhere in CON?
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
  logic CON_MB_XFER;
  logic CON_FM_XFER;
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
endinterface

`endif
