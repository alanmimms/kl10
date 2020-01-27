`timescale 1ns/1ns
`include "cram-defs.svh"
`include "ebus-defs.svh"

module edptb;
  logic eboxClk;
  logic fastMemClk;
  
  /*AUTOWIRE*/
  // Beginning of automatic wires (for undeclared instantiated-module outputs)
  logic [-2:35]         EDP_AD;                 // From edp0 of edp.v
  logic [0:35]          EDP_ADX;                // From edp0 of edp.v
  logic [0:36]          EDP_ADXcarry;           // From edp0 of edp.v
  logic [-2:35]         EDP_AD_EX;              // From edp0 of edp.v
  logic [-2:36]         EDP_ADcarry;            // From edp0 of edp.v
  logic [0:35]          EDP_ADoverflow;         // From edp0 of edp.v
  logic [0:35]          EDP_AR;                 // From edp0 of edp.v
  logic [0:35]          EDP_ARX;                // From edp0 of edp.v
  logic [0:35]          EDP_BR;                 // From edp0 of edp.v
  logic [0:35]          EDP_BRX;                // From edp0 of edp.v
  wire [0:35]           EDP_EBUS;               // From edp0 of edp.v
  logic [0:35]          EDP_MQ;                 // From edp0 of edp.v
  logic                 EDP_genCarry36;         // From edp0 of edp.v
  logic [0:35]          FM;                     // From edp0 of edp.v
  logic [0:35]          cacheDataWrite;         // From edp0 of edp.v
  wire                  fmParity;               // From edp0 of edp.v
  // End of automatics
  /*AUTOREG*/

  tuCRAM CRAM;
  tCRADR CRADR;

  logic eboxReset;
  logic CTL_AR00to08load;
  logic CTL_AR09to17load;
  logic CTL_ARRload;

  logic CTL_AR00to11clr;
  logic CTL_AR12to17clr;
  logic CTL_ARRclr;

  logic [0:2] CTL_ARL_SEL;
  logic [0:2] CTL_ARR_SEL;
  logic [0:2] CTL_ARXL_SEL;
  logic [0:2] CTL_ARXR_SEL;
  logic CTL_ARX_LOAD;

  logic [0:1] CTL_MQ_SEL;
  logic [0:1] CTL_MQM_SEL;
  logic CTL_MQM_EN;
  logic CTL_inhibitCarry18;
  logic CTL_SPEC_genCarry18;

  logic CTL_adToEBUS_L;
  logic CTL_adToEBUS_R;

  logic CTL_ADcarry36;
  logic CTL_ADXcarry36;
  logic CTL_SPEC_AD_LONG;

  logic [0:2] APR_FMblk;
  logic [0:3] APR_FMadr;
  logic CON_fmWrite00_17;
  logic CON_fmWrite18_35;
  logic diagReadFunc12X;
  logic [0:35] VMA_VMAheldOrPC;

  logic [0:35] cacheDataRead;
  logic [0:35] SHM_SH;
  logic [0:8] SCD_ARMMupper;
  logic [13:17] SCD_ARMMlower;

  tEBUS EBUS;

`include "cram-aliases.svh"

  edp edp0(.*);
  crm crm0(.*);

  always #20 eboxClk = ~eboxClk;

  // fastMemClk is same frequency as eboxClk, but is delayed from
  // eboxClk posedge and has shorter positive duty cycle.
  always @(posedge eboxClk) begin
    #2 fastMemClk = 1;
    #4 fastMemClk = 0;
  end
  

  initial begin
    $display($time, "<<<<<<<<<<<<<<<<<< Start EDP test bench >>");
    $monitor($time, " AD=%09x AR=%09x BR=%09x", EDP_AD, EDP_AR, EDP_BR);
    eboxClk = 0;
    fastMemClk = 0;
    eboxReset = 1;

    cacheDataRead = 0;

    CTL_ADcarry36 = 0;
    CTL_ADXcarry36 = 0;
    CTL_SPEC_AD_LONG = 0;

    CTL_ARL_SEL = 0;
    CTL_ARR_SEL = 0;

    CTL_AR00to08load = 0;
    CTL_AR09to17load = 0;
    CTL_ARRload = 0;

    CTL_AR00to11clr = 0;
    CTL_AR12to17clr = 0;
    CTL_ARRclr = 0;

    CTL_ARXL_SEL = 0;
    CTL_ARXR_SEL = 0;
    CTL_ARX_LOAD = 0;

    CTL_MQ_SEL = 0;
    CTL_MQM_SEL = 0;
    CTL_MQM_EN = 0;

    CTL_inhibitCarry18 = 0;
    CTL_SPEC_genCarry18 = 0;

    CTL_adToEBUS_L = 0;
    CTL_adToEBUS_R = 0;

    EBUS.data = 0;

    SHM_SH = 0;

    CRAM.all = 84'd0;

    CRAM.f.FMADR = fmadrAC0;
    APR_FMblk = 0;              // Select a good block number
    APR_FMadr = 7;              // And a good FM AC #

    CON_fmWrite00_17 = 0;       // No writing to FM
    CON_fmWrite18_35 = 0;

    SCD_ARMMupper = 0;
    SCD_ARMMlower = 0;

    diagReadFunc12X = 0;
    VMA_VMAheldOrPC = 0;        // Reset PC for now


    #75 $display($time, "<<<<<<<<<<<<<<<<<< Release EBOX reset >>");
    eboxReset = 0;

    // Load AR with 123456789
    @(negedge eboxClk)
    $display($time, "<<<<<<<<<<<<<<<<<< AD/A, ADA/AR, AR/CACHE=36'h123456789, BR/AR >>");
    cacheDataRead = 36'h123456789;
    CRAM.f.AD = adA;
    CRAM.f.ADA = adaAR;
    CRAM.f.ADB = adbBR;          // Not used yet
    CRAM.f.AR = arCACHE;
    CTL_ARL_SEL = 4'b0001; // CACHE
    CTL_ARR_SEL = 4'b0001; // CACHE
    CTL_AR00to08load = 1;  // Load ARL pieces
    CTL_AR09to17load = 1;
    CTL_ARRload = 1;       // Load ARR
    CRAM.f.BR = brAR;
    CRAM.f.ARX = arxARX;


    // Try AD/A first
    @(negedge eboxClk)
    $display($time, "<<<<<<<<<<<<<<<<<< AD/A, ADA/AR, AR/CACHE=36'h123456789, BR/AR >>");
    cacheDataRead = 36'h123456789;
    CRAM.f.AD = adA;
    CRAM.f.ADA = adaAR;
    CRAM.f.ADB = adbBR;          // Not used yet
    CRAM.f.AR = arCACHE;
    CTL_ARL_SEL = 4'b0001; // CACHE
    CTL_ARR_SEL = 4'b0001; // CACHE
    CTL_AR00to08load = 1;  // Load ARL pieces
    CTL_AR09to17load = 1;
    CTL_ARRload = 1;       // Load ARR
    CRAM.f.BR = brAR;
    CRAM.f.ARX = arxARX;


    // Try AD/B
    @(posedge eboxClk) ;
    @(negedge eboxClk)
    $display($time, "<<<<<<<<<<<<<<<<<< AD/B, ADA/AR, ADB/BR, AR/CACHE=36'h987654321 >>");
    cacheDataRead = 36'h987654321;
    CRAM.f.AD = adA;
    CRAM.f.ADA = adaAR;
    CRAM.f.ADB = adbBR;
    CRAM.f.AR = arCACHE;
    CTL_ARL_SEL = 4'b0001; // CACHE
    CTL_ARR_SEL = 4'b0001; // CACHE
    CTL_AR00to08load = 1;  // Load ARL pieces
    CTL_AR09to17load = 1;
    CTL_ARRload = 1;       // Load ARR
    CRAM.f.BR = brAR;
    CRAM.f.ARX = arxARX;

    // Try AD/0S
    @(posedge eboxClk) ;
    @(negedge eboxClk)
    $display($time, "<<<<<<<<<<<<<<<<<< AD/0S, ADA/AR, ADB/BR, AR/CACHE=36'h987654321 >>");
    cacheDataRead = 36'h987654321;
    CRAM.f.AD = adZEROS;          // AD/0S
    CRAM.f.ADA = adaAR;
    CRAM.f.ADB = adbBR;
    CRAM.f.AR = arCACHE;
    CTL_ARL_SEL = 4'b0001; // CACHE
    CTL_ARR_SEL = 4'b0001; // CACHE
    CTL_AR00to08load = 1;  // Load ARL pieces
    CTL_AR09to17load = 1;
    CTL_ARRload = 1;       // Load ARR
    CRAM.f.BR = brAR;
    CRAM.f.ARX = arxARX;

    // Now add 987654321 and 123456789
    @(posedge eboxClk) ;
    @(negedge eboxClk)
    $display($time, "<<<<<<<<<<<<<<<<<< AD/A+B, ADA/AR, ADB/BR, AR/CACHE=36'h987654321 >>");
    cacheDataRead = 36'h987654321;
    CRAM.f.AD = adAplusB;         // AD/A+B
    CRAM.f.ADA = adaAR;
    CRAM.f.ADB = adbBR;
    CRAM.f.AR = arCACHE;
    CTL_ARL_SEL = 4'b0001; // CACHE
    CTL_ARR_SEL = 4'b0001; // CACHE
    CTL_AR00to08load = 1;  // Load ARL pieces
    CTL_AR09to17load = 1;
    CTL_ARRload = 1;       // Load ARR
    CRAM.f.BR = brAR;
    CRAM.f.ARX = arxARX;

    @(posedge eboxClk);
    @(negedge eboxClk);

    @(posedge eboxClk);
    @(negedge eboxClk);

    @(posedge eboxClk);
    @(negedge eboxClk);

    $display($time, "<<<<<<<<<<<<<<<<<< DONE >>");
    $stop;
  end
endmodule
