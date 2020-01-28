`timescale 1ns/1ns
`include "cram-defs.svh"
`include "ebus-defs.svh"

// M8543 CTL
module ctl(input eboxClk,
           input [0:35] EDP_AR,
           input PCplus1inh,

           iEBUS EBUS,
           tEBUSdriver EBUSdriver,

           output logic CTL_AR00to08load,
           output logic CTL_AR09to17load,
           output logic CTL_ARRload,

           output logic CTL_AR00to11clr,
           output logic CTL_AR12to17clr,
           output logic CTL_ARRclr,

           output logic [0:2] CTL_ARL_SEL,
           output logic [0:2] CTL_ARR_SEL,
           output logic [0:2] CTL_ARXL_SEL,
           output logic [0:2] CTL_ARXR_SEL,
           output logic CTL_ARX_LOAD,

           output logic [0:1] CTL_MQ_SEL,
           output logic [0:1] CTL_MQM_SEL,
           output logic CTL_MQM_EN,
           output CTL_inhibitCarry18,
           output CTL_SPEC_genCarry18,

           output logic CTL_adToEBUS_L,
           output logic CTL_adToEBUS_R,

           output logic CTL_DISP_NICOND,
           output logic CTL_SPEC_SCM_ALT,
           output logic CTL_SPEC_CLR_FPD,
           output logic CTL_SPEC_FLAG_CTL,
           output logic CTL_SPEC_SP_MEM_CYCLE,
           output logic CTL_SPEC_SAVE_FLAGS,

           output logic CTL_ADcarry36,
           output logic CTL_ADXcarry36);

  logic spec_XCRY_AR0;
  logic PIcycleSaveFlags;

  logic CTL_DISP_AREAD;
  logic CTL_DISP_RETURN;
  logic CTL_DISP_MUL;
  logic CTL_DISP_DIV;
  logic CTL_DISP_NORM;
  logic CTL_DISP_EA_MOD;
  
  logic CTL_SPEC_INC_CRY_18;
  logic CTL_SPEC_MQ_SHIFT;
  logic CTL_SPEC_LOAD_PC;
  logic CTL_SPEC_XCRY_AR0;
  logic CTL_SPEC_GEN_CRY_18;
  logic CTL_SPEC_STACK_UPDATE;
  logic CTL_SPEC_ARL_IND;
  logic CTL_SPEC_AD_LONG;
  logic CTL_SPEC_MTR_CTL;

`include "cram-aliases.svh"

  assign PIcycleSaveFlags = PCplus1inh & spec_XCRY_AR0;
  assign CTL_ADXcarry36 = ~PIcycleSaveFlags & ((EDP_AR[0] & spec_XCRY_AR0) ^ CRAM.AD[0]);

  assign CTL_ADcarry36 = 0;         // XXX not right

  assign CTL_SPEC_genCarry18 = 0;   // XXX not right
  assign CTL_inhibitCarry18 = 0;    // XXX not right


  // p.364: Decode all the things.
  // Dispatches
  assign CTL_DISP_AREAD = CRAM.DISP === dispDRAM_A_RD;
  assign CTL_DISP_RETURN = CRAM.DISP === dispRETURN;
  assign CTL_DISP_NICOND = CRAM.DISP === dispNICOND;
  assign CTL_DISP_MUL = CRAM.DISP === dispMUL;
  assign CTL_DISP_DIV = CRAM.DISP === dispDIV;
  assign CTL_DISP_NORM = CRAM.DISP === dispNORM;
  assign CTL_DISP_EA_MOD = CRAM.DISP === dispEA_MOD;
  
  // Special functions
  assign CTL_SPEC_INC_CRY_18 = SPEC === specINH_CRY18;
  assign CTL_SPEC_MQ_SHIFT = SPEC === specMQ_SHIFT;
  assign CTL_SPEC_SCM_ALT = SPEC === specSCM_ALT;
  assign CTL_SPEC_CLR_FPD = SPEC === specCLR_FPD;
  assign CTL_SPEC_LOAD_PC = SPEC === specLOAD_PC;
  assign CTL_SPEC_XCRY_AR0 = SPEC === specXCRY_AR0;
  assign CTL_SPEC_GEN_CRY_18 = SPEC === specGEN_CRY18;
  assign CTL_SPEC_STACK_UPDATE = SPEC === specSTACK_UPDATE;
  assign CTL_SPEC_ARL_IND = SPEC === specARL_IND;
  assign CTL_SPEC_FLAG_CTL = SPEC === specFLAG_CTL;
  assign CTL_SPEC_SAVE_FLAGS = SPEC === specSAVE_FLAGS;
  assign CTL_SPEC_SP_MEM_CYCLE = SPEC === specSP_MEM_CYCLE;
  assign CTL_SPEC_AD_LONG = SPEC === specAD_LONG;
  assign CTL_SPEC_MTR_CTL = SPEC === specMTR_CTL;

  // Diagnostic functions
  logic CTL_DIAG_STROBE;
  assign CTL_DIAG_STROBE = EBUS.diagStrobe;
/*
  assign CTL_DIAG_CTL_FUNC_00x = ;

  assign CTLdrivingEBUS = DIAG_READ_FUNC_10x;
*/

endmodule // ctl
