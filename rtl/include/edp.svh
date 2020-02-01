`ifndef _EDP_INTERFACE_
`define _EDP_INTERFACE_ 1

interface iEDP;
  logic [-2:35] EDP_AD;
  logic [0:35] EDP_ADX;
  logic [0:35] EDP_BR;
  logic [0:35] EDP_BRX;
  logic [0:35] EDP_MQ;
  logic [0:35] EDP_AR;
  logic [0:35] EDP_ARX;
  logic [-2:35] EDP_AD_EX;
  logic [-2:36] EDP_ADcarry;
  logic [0:36] EDP_ADXcarry;
  logic [0:35] EDP_ADoverflow;
  logic EDP_genCarry36;
endinterface

`endif
