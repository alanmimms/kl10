`timescale 1ns/1ns
`include "ebox.svh"

module edptb;
  bit masterClk;
  bit [0:35] cacheDataRead;
  
  bit [18:35] hwOptions = {1'b0,      // [18] 50Hz
                           1'b0,      // [19] Cache (XXX note this is ZERO for now)
                           1'b1,      // [20] Internal channels
                           1'b1,      // [21] Extended KL
                           1'b0,      // [22] Has master oscillator (not needed here)
                           13'd4001}; // [23:35] Serial number

  iAPR APR();
  iCLK CLK();
  iCON CON();
  iCRAM CRAM();
  iCTL CTL();
  iEDP EDP();
  iIR  IR();
  iPI  PIC();
  iSCD SCD();
  iSHM SHM();
  iVMA VMA();

  iEBUS EBUS();
  iMBOX MBOX();

  edp edp0(.*);

  // 50MHz
  always #10 masterClk = ~masterClk;

  initial begin
    $monitor($time, " AD=%09x AR=%09x BR=%09x CRAM.AD=%06b",
             EDP.AD, EDP.AR, EDP.BR, CRAM.AD);

    $display("Start EDP test bench; reset EBOX>");

    masterClk = 0;

    cacheDataRead = 0;

    CTL.AD_CRY_36 = 0;
    CTL.ADX_CRY_36 = 0;

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

    CTL.INH_CRY_18 = 0;
    CTL.SPEC_GEN_CRY_18 = 0;

    CTL.AD_TO_EBUS_L = 0;
    CTL.AD_TO_EBUS_R = 0;

    EBUS.data = 0;

    SHM.SH = 0;

//    CRAM = '{default: 0};

    CRAM.FMADR = fmadrAC0;
    APR.FM_BLOCK = 0;              // Select a good block number
    APR.FM_ADR = 7;              // And a good FM AC #

    CON.FM_WRITE00_17 = 0;       // No writing to FM
    CON.FM_WRITE18_35 = 0;

    EDP.ARMM_SCD = 0;
    EDP.ARMM_VMA = 0;

    VMA.HELD_OR_PC = 0;         // Reset PC for now

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
