`timescale 1ns / 1ps
// M8543 CTL
module ctl(input clk,
           input CRAM_ADcarry,
           input [0:35] ar,
           input PCplus1inh,

           output ADXcarry36,
           output ADlong
           /*AUTOARG*/);

  wire spec_XCRY_AR0;
  wire PIcycleSaveFlags;

  assign PIcycleSaveFlags = PCplus1inh & spec_XCRY_AR0;
  assign ADXcarry36 = ~PIcycleSaveFlags & ((ar[0] & spec_XCRY_AR0) ^ CRAM_ADcarry);
endmodule // ctl
