`ifndef _MBOX_SVH_
 `define _MBOX_SVH_

interface iMBOX;
  logic MB_PAR_ERR;
  logic NXM_ERR;
endinterface

interface iCSH;
  logic MBOX_RESP_IN;
  logic EBOX_RETRY_REQ;
  logic EBOX_T0_IN;
  logic PAGE_FAIL_HOLD;
  logic GATE_VMA_27_33;
endinterface


interface iPAG;
  logic PF_EBOX_HANDLE;
  logic PT_PUBLIC;
endinterface


interface iMBZ;
  logic RD_PSE_WR;
endinterface

`endif
