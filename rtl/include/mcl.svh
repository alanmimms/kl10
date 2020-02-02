`ifndef _MCL_INTERFACE_
 `define _MCL_INTERFACE_ 1

interface iCLK;
  logic MCL_18_BIT_EA;
  logic MCL_23_BIT_EA;
  logic MCL_LOAD_AR;
  logic MCL_LOAD_ARX;
  logic MCL_LOAD_VMA;
  logic MCL_MBOX_CYC_REQ;
  logic MCL_MEM_ARL_IND;
  logic MCL_SHORT_STACK;
  logic MCL_SKIP_SATISFIED;
  logic MCL_STORE_AR;
  logic MCL_VMA_FETCH;
  logic MCL_VMA_SECTION_0;
endinterface

`endif
