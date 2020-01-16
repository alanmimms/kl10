`timescale 1ns / 1ps
// M8543 CTL
module ctl(input clk,
           input CRAM_ADcarry,
           input [0:35] EDP_AR,
           input PCplus1inh,

           output reg CTL_ARL_SEL,
           output reg CTL_ARR_SEL,
           output reg CTL_AR00to08load,
           output reg CTL_AR09to17load,
           output reg CTL_ARRload,

           output reg CTL_AR00to11clr,
           output reg CTL_AR12to17clr,
           output reg CTL_ARRclr,

           output reg ADXcarry36,
           output reg ADlong
           /*AUTOARG*/);

  /*AUTOWIRE*/
  /*AUTOREG*/
  
  wire spec_XCRY_AR0;
  wire PIcycleSaveFlags;

  assign PIcycleSaveFlags = PCplus1inh & spec_XCRY_AR0;
  assign ADXcarry36 = ~PIcycleSaveFlags & ((ar[0] & spec_XCRY_AR0) ^ CRAM_ADcarry);

  // XXX this not nearly complete.
endmodule // ctl
