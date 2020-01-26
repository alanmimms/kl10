`timescale 1ns / 1ps
// M8543 CTL
module ctl(input eboxClk,
           input CRAM_ADcarry,
           input [0:35] EDP_AR,
           input PCplus1inh,

           output reg CTL_AR00to08load,
           output reg CTL_AR09to17load,
           output reg CTL_ARRload,

           output reg CTL_AR00to11clr,
           output reg CTL_AR12to17clr,
           output reg CTL_ARRclr,

           output reg [0:2] CTL_ARL_SEL,
           output reg [0:2] CTL_ARR_SEL,
           output reg [2:0] CTL_ARXL_SEL,
           output reg [2:0] CTL_ARXR_SEL,
           output reg CTL_ARX_LOAD,

           output reg [0:1] CTL_MQ_SEL,
           output reg [0:1] CTL_MQM_SEL,
           output reg CTL_MQM_EN,
           output CTL_inhibitCarry18,
           output CTL_SPEC_genCarry18,

           output reg CTL_adToEBUS_L,
           output reg CTL_adToEBUS_R,

           output CTL_ADcarry36,
           output CTL_ADXcarry36,
           output CTL_ADlong
           /*AUTOARG*/);

  /*AUTOWIRE*/
  /*AUTOREG*/
  
  wire spec_XCRY_AR0;
  wire PIcycleSaveFlags;

  assign PIcycleSaveFlags = PCplus1inh & spec_XCRY_AR0;
  assign CTL_ADXcarry36 = ~PIcycleSaveFlags & ((EDP_AR[0] & spec_XCRY_AR0) ^ CRAM_AD[0]);

  assign CTL_ADcarry36 = 0;         // XXX not right

  assign CTL_ADlong = 0;            // XXX not right
  assign CTL_SPEC_genCarry18 = 0;   // XXX not right
  assign CTL_inhibitCarry18 = 0;    // XXX not right

  // XXX this not nearly complete.
endmodule // ctl
