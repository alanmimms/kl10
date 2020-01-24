`timescale 1ns / 100ps
`include "cram-defs.svh"
module edptb;
  reg eboxClk;
  reg fastMemClk;
  
  /*AUTOWIRE*/
  // Beginning of automatic wires (for undeclared instantiated-module outputs)
  wire [-2:35]          EDP_AD;                 // From edp0 of edp.v
  wire [0:35]           EDP_ADX;                // From edp0 of edp.v
  wire [0:36]           EDP_ADXcarry;           // From edp0 of edp.v
  wire [-2:35]          EDP_AD_EX;              // From edp0 of edp.v
  wire [-2:36]          EDP_ADcarry;            // From edp0 of edp.v
  wire [0:35]           EDP_ADoverflow;         // From edp0 of edp.v
  wire [0:35]           EDP_AR;                 // From edp0 of edp.v
  wire [0:35]           EDP_ARX;                // From edp0 of edp.v
  wire [0:35]           EDP_BR;                 // From edp0 of edp.v
  wire [0:35]           EDP_BRX;                // From edp0 of edp.v
  wire [0:35]           EDP_EBUS;               // From edp0 of edp.v
  wire [0:35]           EDP_MQ;                 // From edp0 of edp.v
  wire                  EDP_genCarry36;         // From edp0 of edp.v
  wire                  EDPdrivingEBUS;         // From edp0 of edp.v
  wire [0:35]           FM;                     // From edp0 of edp.v
  wire [0:35]           cacheDataWrite;         // From edp0 of edp.v
  wire                  fmParity;               // From edp0 of edp.v
  // End of automatics
  /*AUTOREG*/

  reg [0:11] CRAM_J;
  tCRAM_AD CRAM_AD;
  reg [0:3] CRAM_ADA;
  reg [0:1] CRAM_ADA_EN;
  reg [0:1] CRAM_ADB;
  reg [0:3] CRAM_AR;
  reg [0:3] CRAM_ARX;
  reg [0:1] CRAM_BR;
  reg [0:1] CRAM_BRX;
  reg [0:1] CRAM_MQ;
  reg [0:3] CRAM_FMADR;
  reg [0:3] CRAM_SCAD;
  reg [0:3] CRAM_SCADA;
  reg [0:1] CRAM_SCADA_EN;
  reg [0:2] CRAM_SCADB;
  reg [0:1] CRAM_SC;
  reg [0:1] CRAM_FE;
  reg [0:2] CRAM_SH;
  reg [0:2] CRAM_ARMM;
  reg [0:2] CRAM_VMAX;
  reg [0:2] CRAM_VMA;
  reg [0:2] CRAM_TIME;
  reg [0:4] CRAM_MEM;
  reg [0:6] CRAM_SKIP;
  reg [0:6] CRAM_COND;
  reg [0:1] CRAM_CALL;
  reg [0:5] CRAM_DISP;
  reg [0:5] CRAM_SPEC;
  reg [0:1] CRAM_MARK;
  reg [0:8] CRAM_MAGIC;
  reg [0:6] CRAM_MAJVER;
  reg [0:3] CRAM_MINVER;
  reg [0:1] CRAM_KLPAGE;
  reg [0:1] CRAM_LONGPC;
  reg [0:1] CRAM_NONSTD;
  reg [0:1] CRAM_PV;
  reg [0:1] CRAM_PMOVE;
  reg [0:1] CRAM_ISTAT;
  reg [0:3] CRAM_PXCT;
  reg [0:3] CRAM_ACB;
  reg [0:4] CRAM_ACmagic;
  reg [0:5] CRAM_AC_OP;
  reg [0:1] CRAM_AR0_8;
  reg [0:4] CRAM_CLR;
  reg [0:3] CRAM_ARL;
  reg [0:3] CRAM_AR_CTL;
  reg [0:1] CRAM_EXP_TST;
  reg [0:2] CRAM_MQ_CTL;
  reg [0:8] CRAM_PC_FLAGS;
  reg [0:8] CRAM_FLAG_CTL;
  reg [0:8] CRAM_SPEC_INSTR;
  reg [0:8] CRAM_FETCH;
  reg [0:8] CRAM_EA_CALC;
  reg [0:8] CRAM_SP_MEM;
  reg [0:8] CRAM_MREG_FNC;
  reg [0:8] CRAM_MBOX_CTL;
  reg [0:3] CRAM_MTR_CTL;
  reg [0:8] CRAM_EBUS_CTL;
  reg [0:8] CRAM_DIAG_FUNC;

  reg CTL_AR00to08load;
  reg CTL_AR09to17load;
  reg CTL_ARRload;

  reg CTL_AR00to11clr;
  reg CTL_AR12to17clr;
  reg CTL_ARRclr;

  reg [0:2] CTL_ARL_SEL;
  reg [0:2] CTL_ARR_SEL;
  reg [0:2] CTL_ARXL_SEL;
  reg [0:2] CTL_ARXR_SEL;
  reg CTL_ARX_LOAD;

  reg [0:1] CTL_MQ_SEL;
  reg [0:1] CTL_MQM_SEL;
  reg CTL_MQM_EN;
  reg CTL_inhibitCarry18;
  reg CTL_SPEC_genCarry18;

  reg CTL_adToEBUS_L;
  reg CTL_adToEBUS_R;

  reg CTL_ADcarry36;
  reg CTL_ADXcarry36;
  reg CTL_ADlong;

  reg [0:2] APR_FMblk;
  reg [0:3] APR_FMadr;
  reg CON_fmWrite00_17;
  reg CON_fmWrite18_35;
  reg diagReadFunc12X;
  reg [0:35] VMA_VMAheldOrPC;

  reg [0:35] cacheDataRead;
  reg [0:35] EBUS;
  reg [0:35] SHM_SH;
  reg [0:8] SCD_ARMMupper;
  reg [13:17] SCD_ARMMlower;

  reg CRAM_BRload;
  reg CRAM_BRXload;

  edp edp0(.*);

  always #20 eboxClk = ~eboxClk;

  // fastMemClk is same frequency as eboxClk, but is delayed from
  // eboxClk posedge and has shorter positive duty cycle.
  always @(posedge eboxClk) begin
    #2 fastMemClk = 1;
    #4 fastMemClk = 0;
  end
  

  initial begin
    $display($time, "<< Start EDP test bench >>");
    $monitor($time, " AD=%09x AR=%09x", EDP_AD, EDP_AR);
    eboxClk = 0;
    fastMemClk = 0;

    cacheDataRead = 0;

    CTL_ADcarry36 = 0;
    CTL_ADXcarry36 = 0;
    CTL_ADlong = 0;

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

    EBUS = 0;

    SHM_SH = 0;

    CRAM_AD = adAplus1;
    CRAM_ADA = 0;
    CRAM_ADA_EN = 0;
    CRAM_ADB = 0;
    CRAM_AR = 0;
    CRAM_ARX = 0;
    CRAM_BR = 0;
    CRAM_BRX = 0;
    CRAM_BRload = 0;
    CRAM_BRXload = 0;
    CRAM_MQ = 0;
    CRAM_ARMM = 0;

    // Initialize all CRAM fields we do not use but may someday
    CRAM_J = 0;
    CRAM_SCAD = 0;
    CRAM_SCADA = 0;
    CRAM_SCADA_EN = 0;
    CRAM_SCADB = 0;
    CRAM_SC = 0;
    CRAM_FE = 0;
    CRAM_SH = 0;
    CRAM_ARMM = 0;
    CRAM_VMAX = 0;
    CRAM_VMA = 0;
    CRAM_TIME = 0;
    CRAM_MEM = 0;
    CRAM_SKIP = 0;
    CRAM_COND = 0;
    CRAM_CALL = 0;
    CRAM_DISP = 0;
    CRAM_SPEC = 0;
    CRAM_MARK = 0;
    CRAM_MAJVER = 0;
    CRAM_MINVER = 0;
    CRAM_KLPAGE = 0;
    CRAM_LONGPC = 0;
    CRAM_NONSTD = 0;
    CRAM_PV = 0;
    CRAM_PMOVE = 0;
    CRAM_ISTAT = 0;
    CRAM_PXCT = 0;
    CRAM_ACB = 0;
    CRAM_ACmagic = 0;
    CRAM_AC_OP = 0;
    CRAM_AR0_8 = 0;
    CRAM_CLR = 0;
    CRAM_ARL = 0;
    CRAM_AR_CTL = 0;
    CRAM_EXP_TST = 0;
    CRAM_MQ_CTL = 0;
    CRAM_PC_FLAGS = 0;
    CRAM_FLAG_CTL = 0;
    CRAM_SPEC_INSTR = 0;
    CRAM_FETCH = 0;
    CRAM_EA_CALC = 0;
    CRAM_SP_MEM = 0;
    CRAM_MREG_FNC = 0;
    CRAM_MBOX_CTL = 0;
    CRAM_MTR_CTL = 0;
    CRAM_EBUS_CTL = 0;

    CRAM_FMADR = 0;             // XXX this should select an FM address source
    APR_FMblk = 0;              // Select a good block number
    APR_FMadr = 7;              // And a good FM AC #

    CON_fmWrite00_17 = 0;       // No writing to FM
    CON_fmWrite18_35 = 0;

    SCD_ARMMupper = 0;
    SCD_ARMMlower = 0;

    CRAM_MAGIC = 0;
    CRAM_DIAG_FUNC = 0;         // No diagnostic function
    diagReadFunc12X = 0;
    VMA_VMAheldOrPC = 0;        // Reset PC for now

    // Load AR with 123456789
    @(negedge eboxClk)
    $display($time, "<< AD/A, ADA/AR, AR/CACHE=36'h123456789, BR/AR >>");
    cacheDataRead = 36'h123456789;
    CRAM_AD = adA;         // AD/A
    CRAM_ADA = 3'b000;     // ADA/AR
    CRAM_ADA_EN = 1'b0;    // Enabled
    CRAM_ADB = 0;          // Not used yet
    CRAM_AR = 4'b0001;     // CACHE
    CTL_ARL_SEL = 4'b0001; // CACHE
    CTL_ARR_SEL = 4'b0001; // CACHE
    CTL_AR00to08load = 1;  // Load ARL pieces
    CTL_AR09to17load = 1;
    CTL_ARRload = 1;       // Load ARR
    CRAM_BR = 1'b1;        // BR/AR
    CRAM_BRload = 1;
    CRAM_ARX = 4'b0000;    // ARX (recirculate)


    // Try AD/A first
    @(negedge eboxClk)
    $display($time, "<< AD/A, ADA/AR, AR/CACHE=36'h123456789, BR/AR >>");
    cacheDataRead = 36'h123456789;
    CRAM_AD = adA;         // AD/A
    CRAM_ADA = 3'b000;     // ADA/AR
    CRAM_ADA_EN = 1'b0;    // Enabled
    CRAM_ADB = 0;          // Not used yet
    CRAM_AR = 4'b0001;     // CACHE
    CTL_ARL_SEL = 4'b0001; // CACHE
    CTL_ARR_SEL = 4'b0001; // CACHE
    CTL_AR00to08load = 1;  // Load ARL pieces
    CTL_AR09to17load = 1;
    CTL_ARRload = 1;       // Load ARR
    CRAM_BR = 1'b1;        // BR/AR
    CRAM_BRload = 1;
    CRAM_ARX = 4'b0000;    // ARX (recirculate)


    // Try AD/B
    @(posedge eboxClk) ;
    @(negedge eboxClk)
    $display($time, "<< AD/B, ADA/AR, ADB/BR, AR/CACHE=36'h987654321 >>");
    cacheDataRead = 36'h987654321;
    CRAM_AD = adB;              // AD/B
    CRAM_ADA = 3'b000;          // ADA/AR
    CRAM_ADA_EN = 1'b0;         // Enabled
    CRAM_ADB = 2'b10;           // ADB/BR
    CRAM_AR = 4'b0001;          // CACHE
    CTL_ARL_SEL = 4'b0001;      // CACHE
    CTL_ARR_SEL = 4'b0001;      // CACHE
    CTL_AR00to08load = 1;       // Load ARL pieces
    CTL_AR09to17load = 1;
    CTL_ARRload = 1;            // Load ARR
    CRAM_BR = 1'b1;             // BR/AR
    CRAM_BRload = 1;
    CRAM_ARX = 4'b0000;         // ARX (recirculate)

    // Try AD/0S
    @(posedge eboxClk) ;
    @(negedge eboxClk)
    $display($time, "<< AD/0S, ADA/AR, ADB/BR, AR/CACHE=36'h987654321 >>");
    cacheDataRead = 36'h987654321;
    CRAM_AD = adZEROS;          // AD/0S
    CRAM_ADA = 3'b000;          // ADA/AR
    CRAM_ADA_EN = 1'b0;         // Enabled
    CRAM_ADB = 2'b10;           // ADB/BR
    CRAM_AR = 4'b0001;          // CACHE
    CTL_ARL_SEL = 4'b0001;      // CACHE
    CTL_ARR_SEL = 4'b0001;      // CACHE
    CTL_AR00to08load = 1;       // Load ARL pieces
    CTL_AR09to17load = 1;
    CTL_ARRload = 1;            // Load ARR
    CRAM_BR = 1'b1;             // BR/AR
    CRAM_BRload = 1;
    CRAM_ARX = 4'b0000;         // ARX (recirculate)

    // Now add 987654321 and 123456789
    @(posedge eboxClk) ;
    @(negedge eboxClk)
    $display($time, "<< AD/A+B, ADA/AR, ADB/BR, AR/CACHE=36'h987654321 >>");
    cacheDataRead = 36'h987654321;
    CRAM_AD = adAplusB;         // AD/A+B
    CRAM_ADA = 3'b000;          // ADA/AR
    CRAM_ADA_EN = 1'b0;         // Enabled
    CRAM_ADB = 2'b10;           // ADB/BR
    CRAM_AR = 4'b0001;          // CACHE
    CTL_ARL_SEL = 4'b0001;      // CACHE
    CTL_ARR_SEL = 4'b0001;      // CACHE
    CTL_AR00to08load = 1;       // Load ARL pieces
    CTL_AR09to17load = 1;
    CTL_ARRload = 1;            // Load ARR
    CRAM_BR = 1'b1;             // BR/AR
    CRAM_BRload = 1;
    CRAM_ARX = 4'b0000;         // ARX (recirculate)

    @(posedge eboxClk);
    @(negedge eboxClk);

    @(posedge eboxClk);
    @(negedge eboxClk);

    @(posedge eboxClk);
    @(negedge eboxClk);

    $display($time, "<<< DONE >>>");
    $stop;
  end
endmodule
