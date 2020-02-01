`ifndef _SCD_INTERFACE_
`define _SCD_INTERFACE_ 1

interface iSCD;
  logic [0:8] SCD_ARMM_UPPER;
  logic [13:17] SCD_ARMM_LOWER;
  logic [0:9] SCD_FE;
  logic [0:9] SCD_SC;
  logic [0:35] SCD_SCADA;
  logic [0:35] SCD_SCADB;
  logic SCD_SC_GE_36;
  logic SCD_SCADeq0;
  logic SCD_SCAD_SIGN;
  logic SCD_SC_SIGN;
  logic SCD_FE_SIGN;
  logic SCD_OV;
  logic SCD_CRY0;
  logic SCD_CRY1;
  logic SCD_FOV;
  logic SCD_FXU;
  logic SCD_FPD;
  logic SCD_PCP;
  logic SCD_DIV_CHK;
  logic SCD_TRAP_REQ1;
  logic SCD_TRAP_REQ2;
  logic SCD_TRAP_CYC1;
  logic SCD_TRAP_CYC2;
  logic SCD_USER;
  logic SCD_USER_IOT;
  logic SCD_PUBLIC;
  logic SCD_PRIVATE;
  logic SCD_ADR_BRK_PREVENT;
endinterface

`endif
