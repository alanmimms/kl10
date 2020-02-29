`ifndef _MBOX_SVH_
 `define _MBOX_SVH_

interface iMBOX;
  bit [27:35] MBOX_GATE_VMA;
  bit [0:10] pfDisp;
  bit CSH_ADR_PAR_ERR;
  bit MB_PAR_ERR;
  bit ADR_PAR_ERR;
  bit NXM_ERR;
  bit SBUS_ERR;
  bit SEL_1;
  bit SEL_2;
endinterface


interface iCHA;
endinterface


interface iCCL;
  bit CHAN_REQ;
  bit CHAN_TO_MEM;
  bit CHAN_EPT;
endinterface


interface iCCW;
endinterface


interface iCRC;
endinterface


interface iCSH;
  tEBUSdriver EBUSdriver;
  bit MBOX_RESP_IN;
  bit MB_REQ_GRANT;
  bit CCA_REQ_GRANT;
  bit CHAN_REQ_GRANT;
  bit EBOX_REQ_GRANT;
  bit EBOX_ERA_GRANT;
  bit EBOX_CCA_GRANT;
  bit EBOX_RETRY_REQ;
  bit EBOX_T0_IN;
  bit PAGE_FAIL_HOLD;
  bit GATE_VMA_27_33;
  bit PAR_BIT_A;
  bit PAR_BIT_B;
  bit MB_CYC;
  bit ADR_READY;
  bit CLEAR_WR_T0;
  bit CHAN_CYC;
  bit T2;
  bit _0_VALID_MATCH;
  bit _1_VALID_MATCH;
  bit _2_VALID_MATCH;
  bit _3_VALID_MATCH;
  bit _0_ANY_WR;
  bit _1_ANY_WR;
  bit _2_ANY_WR;
  bit _3_ANY_WR;
  bit LRU_1;
  bit LRU_2;
  bit MATCH_HOLD_1_IN;
  bit MATCH_HOLD_2_IN;
  bit WR_FROM_MEM_NXT;
  bit ANY_VALID_HOLD_IN;
  bit ADR_PMA_EN;
  bit REFILL_RAM_WR;
  bit ONE_WORD_WR_T0;
  bit WRITEBACK_T1;
  bit DATA_CLR_DONE;
  bit PAGE_REFILL_T9;
  bit EBOX_CYC;
  bit CCA_CYC;
  bit ANY_VAL_HOLD;
  bit ANY_VAL_HOLD_IN;
  bit PAGE_REFILL_T8;
  bit PAGE_REFILL_T12;
  bit PAGE_REFILL_T13;
  bit CHAN_WR_T5_IN;
  bit CHAN_T3;
  bit CHAN_T4;
  bit CHAN_RD_T5;
  bit EBOX_T3;
  bit CHAN_WR_CACHE;
  bit PAGE_REFILL_ERROR;
  bit CCA_INVAL_T4;
  bit CCA_CYC_DONE;
  bit USE_HOLD;
  bit USE_WR_EN;
  bit CACHE_WR_IN;
  bit MBOX_PT_DIR_WR;
  bit FILL_CACHE_RD;
  bit CCA_WRITEBACK;
  bit EBOX_LOAD_REG;
  bit E_WRITEBACK;
  bit PAGE_REFILL_T0;
  bit PAGE_REFILL_T4;
  bit E_CACHE_WR_CYC;
  bit MB_WR_RQ_CLR_NXT;
  bit ONE_WORD_RD;
  bit RD_PAUSE_2ND_HALF;
  bit READY_TO_GO;
  bit PGRF_CYC;
endinterface


interface iMBC;
  bit CORE_DATA_VALminus1;
  bit WRITE_OK;
  bit CORE_DATA_VALID;
  bit CSH_DATA_CLR_T1;
  bit CSH_DATA_CLR_T2;
  bit CSH_DATA_CLR_T3;
  bit DATA_CLR_DONE_IN;
endinterface


interface iMBX;
  bit CCA_REQ;
  bit SBUS_DIAG_3;
  bit MB_REQ_IN;
  bit CACHE_BIT;
  bit [34:35] CACHE_TO_MB;
  bit CACHE_TO_MB_DONE;
  bit REFILL_ADR_EN_NXT;
  bit CSH_CCA_VAL_CORE;
  bit MB_SEL_HOLD_FF;
  bit CSH_CCA_INVAL_CSH;
  bit CCA_ALL_PAGES_CYC;
  bit EBOX_LOAD_REG;
  bit WRITEBACK_T2;
endinterface


interface iMBZ;
  bit RD_PSE_WR;
endinterface

interface iPAG;
  bit PF_EBOX_HANDLE;
  bit PAGE_OK;
  bit PAGE_FAIL;
  bit PAGE_REFILL;
  bit PAGE_REFILL_CYC;
  bit [14:35] PT;
  bit [0:35] PT_IN;
  bit PT_ACCESS;
  bit PT_PUBLIC;
  bit PT_WRITABLE;
  bit PT_SOFTWARE;
  bit PT_CACHE;
  bit [18:26] PT_ADR;
  bit MB_00to17_PAR;
  bit MB_18to35_PAR;
endinterface


interface iPMA;
  bit CSH_WRITEBACK_CYC;
  bit PAGE_REFILL_CYC;
  bit CCA_CRY_OUT;
  bit ADR_PAR;
  bit _14_26_PAR;
  bit CSH_EBOX_CYC;
  bit CYC_TYPE_HOLD;
  bit [14:35] CCW_CHA;
  bit EBOX_PAGED;
  bit [14:35] PMA;
  bit [14:35] PA;
endinterface

`endif
