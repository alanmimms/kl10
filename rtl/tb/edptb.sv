`timescale 1ns/1ns
`include "cram-defs.svh"
`include "ebus-defs.svh"

module edptb;
  logic masterClk;
  
  /*AUTOWIRE*/
  // Beginning of automatic wires (for undeclared instantiated-module outputs)
  logic [-2:35]         EDP.AD;                 // From edp0 of edp.v
  logic [0:35]          EDP.ADX;                // From edp0 of edp.v
  logic [0:36]          EDP.ADX_CRY;           // From edp0 of edp.v
  logic [-2:35]         EDP.AD_EX;              // From edp0 of edp.v
  logic [-2:36]         EDP.AD_CRY;            // From edp0 of edp.v
  logic [0:35]          EDP.AD_OV;         // From edp0 of edp.v
  logic [0:35]          EDP.AR;                 // From edp0 of edp.v
  logic [0:35]          EDP.ARX;                // From edp0 of edp.v
  logic [0:35]          EDP.BR;                 // From edp0 of edp.v
  logic [0:35]          EDP.BRX;                // From edp0 of edp.v
  logic [0:35]          EDP.MQ;                 // From edp0 of edp.v
  logic                 EDP_GEN_CRY_36;         // From edp0 of edp.v
  logic [0:35]          FM;                     // From edp0 of edp.v
  logic [0:35]          cacheDataWrite;         // From edp0 of edp.v
  wire                  fmParity;               // From edp0 of edp.v
  // End of automatics
  /*AUTOREG*/

  tCRADR CRADR;

  logic CTL.AR00to08_LOAD;
  logic CTL.AR09to17_LOAD;
  logic CTL.ARR_LOAD;

  logic CTL.AR00to11_CLR;
  logic CTL.AR12to17_CLR;
  logic CTL.ARR_CLR;

  logic [0:2] CTL.ARL_SEL;
  logic [0:2] CTL.ARR_SEL;
  logic [0:2] CTL.ARXL_SEL;
  logic [0:2] CTL.ARXR_SEL;
  logic CTL.ARX_LOAD;

  logic [0:1] CTL.MQ_SEL;
  logic [0:1] CTL.MQM_SEL;
  logic CTL.MQM_EN;
  logic CTL.INH_CRY_18;
  logic CTL.SPEC_GEN_CRY_18;

  logic CTL.AD_TO_EBUS_L;
  logic CTL.AD_TO_EBUS_R;

  logic CTL_SPEC_AD_LONG;

  logic [0:2] APR.FMblk;
  logic [0:3] APR.FMadr;
  logic CON.FM_WRITE00_17;
  logic CON.FM_WRITE18_35;
  logic diagReadFunc12X;
  logic [0:35] VMA.VMA_HELD_OR_PC;

  logic [0:35] cacheDataRead;
  logic [0:35] SHM.SH;
  logic [0:8] SCD.ARMM_UPPER;
  logic [13:17] SCD.ARMM_LOWER;

  iEBUS EBUS();
  tEBUSdriver EDP_EBUS;

`include "cram-aliases.svh"

  iCRAM CRAM();
  edp edp0(.*, EBUSdriver(EDP_EBUS));
//  crm crm0(.*);

  // 50MHz
  always #10 masterClk = ~masterClk;

  initial begin
    $monitor($time, " CLK.EBOX_RESET=%b AD=%09x AR=%09x BR=%09x CRAM.AD=%06b",
             CLK.EBOX_RESET, EDP.AD, EDP.AR, EDP.BR, CRAM.AD);

    $display("Start EDP test bench; reset EBOX>");

    masterClk = 0;

    CRADR = 0;
    cacheDataRead = 0;

    CTL.AD_CRY_36 = 0;
    CTL.ADX_CRY_36 = 0;
    CTL_SPEC_AD_LONG = 0;

    CTL.ARL_SEL = 0;
    CTL.ARR_SEL = 0;

    CTL.AR00to08_LOAD = 0;
    CTL.AR09to17_LOAD = 0;
    CTL.ARR_LOAD = 0;

    CTL.AR00to11_CLR = 0;
    CTL.AR12to17_CLR = 0;
    CTL.ARR_CLR = 0;

    CTL.ARXL_SEL = 0;
    CTL.ARXR_SEL = 0;
    CTL.ARX_LOAD = 0;

    CTL.MQ_SEL = 0;
    CTL.MQM_SEL = 0;
    CTL.MQM_EN = 0;

    CTL_INH_CRY_18 = 0;
    CTL.SPEC_GEN_CRY_18 = 0;

    CTL.AD_TO_EBUS_L = 0;
    CTL.AD_TO_EBUS_R = 0;

    EBUS.data = 0;

    SHM.SH = 0;

//    CRAM = '{default: 0};

    CRAM.FMADR = fmadrAC0;
    APR.FMblk = 0;              // Select a good block number
    APR.FMadr = 7;              // And a good FM AC #

    CON.FM_WRITE00_17 = 0;       // No writing to FM
    CON.FM_WRITE18_35 = 0;

    SCD.ARMM_UPPER = 0;
    SCD.ARMM_LOWER = 0;

    diagReadFunc12X = 0;
    VMA.VMA_HELD_OR_PC = 0;        // Reset PC for now


    #75 $display($time, "<<<<<<<<<<<<<<<<<< Release EBOX reset >>");
    CLK.EBOX_RESET = 0;

    // Load AR with 123456789
    @(negedge masterClk)
    $display($time, "<<<<<<<<<<<<<<<<<< AD/A, ADA/AR, AR/CACHE=555555555, BR/AR >>");
    cacheDataRead = 36'h555555555;
    CRAM.AD = adA;
    CRAM.ADA = adaAR;
    CRAM.ADB = adbBR;          // Not used yet
    CRAM.AR = arCACHE;
    CTL.ARL_SEL = 4'b0001; // CACHE
    CTL.ARR_SEL = 4'b0001; // CACHE
    CTL.AR00to08_LOAD = 1;  // Load ARL pieces
    CTL.AR09to17_LOAD = 1;
    CTL.ARR_LOAD = 1;       // Load ARR
    CRAM.BR = brAR;
    CRAM.ARX = arxARX;


    // Try AD/A first
    @(negedge masterClk)
    $display($time, "<<<<<<<<<<<<<<<<<< AD/A, ADA/AR, AR/CACHE=555555555, BR/AR >>");
    cacheDataRead = 36'h555555555;
    CRAM.AD = adA;
    CRAM.ADA = adaAR;
    CRAM.ADB = adbBR;          // Not used yet
    CRAM.AR = arCACHE;
    CTL.ARL_SEL = 4'b0001; // CACHE
    CTL.ARR_SEL = 4'b0001; // CACHE
    CTL.AR00to08_LOAD = 1;  // Load ARL pieces
    CTL.AR09to17_LOAD = 1;
    CTL.ARR_LOAD = 1;       // Load ARR
    CRAM.BR = brAR;
    CRAM.ARX = arxARX;


    // Try AD/B
    @(negedge masterClk)
    $display($time, "<<<<<<<<<<<<<<<<<< AD/B, ADA/AR, ADB/BR, AR/CACHE=987654321 >>");
    cacheDataRead = 36'h987654321;
    CRAM.AD = adA;
    CRAM.ADA = adaAR;
    CRAM.ADB = adbBR;
    CRAM.AR = arCACHE;
    CTL.ARL_SEL = 4'b0001; // CACHE
    CTL.ARR_SEL = 4'b0001; // CACHE
    CTL.AR00to08_LOAD = 1;  // Load ARL pieces
    CTL.AR09to17_LOAD = 1;
    CTL.ARR_LOAD = 1;       // Load ARR
    CRAM.BR = brAR;
    CRAM.ARX = arxARX;

    // Try AD/0S
    @(negedge masterClk)
    $display($time, "<<<<<<<<<<<<<<<<<< AD/0S, ADA/AR, ADB/BR, AR/CACHE=987654321 >>");
    cacheDataRead = 36'h987654321;
    CRAM.AD = adZEROS;          // AD/0S
    CRAM.ADA = adaAR;
    CRAM.ADB = adbBR;
    CRAM.AR = arCACHE;
    CTL.ARL_SEL = 4'b0001; // CACHE
    CTL.ARR_SEL = 4'b0001; // CACHE
    CTL.AR00to08_LOAD = 1;  // Load ARL pieces
    CTL.AR09to17_LOAD = 1;
    CTL.ARR_LOAD = 1;       // Load ARR
    CRAM.BR = brAR;
    CRAM.ARX = arxARX;

    // Now add 987654321 and 123456789
    @(negedge masterClk)
    $display($time, "<<<<<<<<<<<<<<<<<< AD/A+B, ADA/AR, ADB/BR, AR/CACHE=987654321 >>");
    cacheDataRead = 36'h987654321;
    CRAM.AD = adAplusB;         // AD/A+B
    CRAM.ADA = adaAR;
    CRAM.ADB = adbBR;
    CRAM.AR = arCACHE;
    CTL.ARL_SEL = 4'b0001; // CACHE
    CTL.ARR_SEL = 4'b0001; // CACHE
    CTL.AR00to08_LOAD = 1;  // Load ARL pieces
    CTL.AR09to17_LOAD = 1;
    CTL.ARR_LOAD = 1;       // Load ARR
    CRAM.BR = brAR;
    CRAM.ARX = arxARX;

    @(negedge masterClk);

    @(negedge masterClk);

    @(negedge masterClk);

    $display($time, "DONE");
//    $stop;
  end
endmodule
