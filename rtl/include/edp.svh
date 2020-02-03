`ifndef _EDP_INTERFACE_
`define _EDP_INTERFACE_ 1

interface iEDP;
  logic [-2:35] AD;
  logic [0:35] ADX;
  logic [0:35] BR;
  logic [0:35] BRX;
  logic [0:35] MQ;
  logic [0:35] AR;
  logic [0:35] ARX;
  logic [-2:35] AD_EX;
  logic [-2:36] ADcarry;
  logic [0:36] ADXcarry;
  logic [0:35] ADoverflow;
  logic GEN_CRY_36;
  logic DIAG_READ_FUNC_10x;
endinterface

`endif
