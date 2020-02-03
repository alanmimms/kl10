`ifndef _CLK_INTERFACE_
`define _CLK_INTERFACE_ 1

interface iCLK;
  logic CLK_EBOX_SYNC;
  logic CLK_EBUS_RESET;
  logic CLK_PAGE_ERROR;
  logic CLK_RESP_MBOX;
  logic CLK_RESP_SIM;
  logic CLK_SBR_CALL;
  logic CLR_PRIVATE_INSTR;
endinterface

`endif
