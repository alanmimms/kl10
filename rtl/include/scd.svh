`ifndef _SCD_INTERFACE_
`define _SCD_INTERFACE_ 1

interface iSCD;
  logic [0:8] ARMM_UPPER;
  logic [13:17] ARMM_LOWER;
  logic [0:9] FE;
  logic [0:9] SC;
  logic [0:35] SCADA;
  logic [0:35] SCADB;
  logic SC_GE_36;
  logic SCADeq0;
  logic SCAD_SIGN;
  logic SC_SIGN;
  logic FE_SIGN;
  logic OV;
  logic CRY0;
  logic CRY1;
  logic FOV;
  logic FXU;
  logic FPD;
  logic PCP;
  logic DIV_CHK;
  logic TRAP_REQ1;
  logic TRAP_REQ2;
  logic TRAP_CYC1;
  logic TRAP_CYC2;
  logic USER;
  logic USER_IOT;
  logic PUBLIC;
  logic PRIVATE;
  logic ADR_BRK_PREVENT;
endinterface

`endif
