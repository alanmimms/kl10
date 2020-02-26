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
endinterface

interface iCSH;
  bit MBOX_RESP_IN;
  bit EBOX_RETRY_REQ;
  bit EBOX_T0_IN;
  bit PAGE_FAIL_HOLD;
  bit GATE_VMA_27_33;
  bit PAR_BIT_A;
  bit PAR_BIT_B;
endinterface


interface iPAG;
  bit PF_EBOX_HANDLE;
  bit PT_PUBLIC;
endinterface


interface iMBZ;
  bit RD_PSE_WR;
endinterface

`endif
