`ifndef _MBOX_SVH_
 `define _MBOX_SVH_

interface iCSH;
  logic MBOX_RESP_IN;
  logic EBOX_RETRY_REQ;
  logic EBOX_T0_IN;
  logic PAGE_FAIL_HOLD;
endinterface


interface iPAG;
  logic PF_EBOX_HANDLE;
endinterface


interface iMBZ;
  logic RD_PSE_WR;
endinterface

`endif
  
    
