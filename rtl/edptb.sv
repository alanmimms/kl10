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

  logic [0:10] CRAM_J;
  tCRAM_AD CRAM_AD;
  tCRAM_ADA CRAM_ADA;
  tCRAM_ADA_EN CRAM_ADA_EN;
  tCRAM_ADB CRAM_ADB;
  tCRAM_AR CRAM_AR;
  tCRAM_ARX CRAM_ARX;
  tCRAM_BR CRAM_BR;
  tCRAM_BRX CRAM_BRX;
  tCRAM_MQ CRAM_MQ;
  tCRAM_FMADR CRAM_FMADR;
  tCRAM_SCAD CRAM_SCAD;
  tCRAM_SCADA CRAM_SCADA;
  tCRAM_SCADA_EN CRAM_SCADA_EN;
  tCRAM_SCADB CRAM_SCADB;
  tCRAM_SC CRAM_SC;
  tCRAM_FE CRAM_FE;
  tCRAM_SH CRAM_SH;
  tCRAM_ARMM CRAM_ARMM;
  tCRAM_VMAX CRAM_VMAX;
  tCRAM_VMA CRAM_VMA;
  tCRAM_TIME CRAM_TIME;
  tCRAM_MEM CRAM_MEM;
  tCRAM_SKIP CRAM_SKIP;
  tCRAM_COND CRAM_COND;
  logic CRAM_CALL;
  tCRAM_DISP CRAM_DISP;
  tCRAM_SPEC CRAM_SPEC;
  logic CRAM_MARK;
  logic [0:8] CRAM_MAGIC;
  logic [0:5] CRAM_MAJVER;
  logic [0:2] CRAM_MINVER;
  logic CRAM_KLPAGE;
  logic CRAM_LONGPC;
  logic CRAM_NONSTD;
  logic CRAM_PV;
  logic CRAM_PMOVE;
  logic  CRAM_ISTAT;
  logic [0:2] CRAM_PXCT;
  tCRAM_ACB CRAM_ACB;
  logic [0:3] CRAM_ACmagic;
  tCRAM_AC_OP CRAM_AC_OP;
  logic CRAM_AR0_8;
  tCRAM_CLR CRAM_CLR;
  tCRAM_ARL CRAM_ARL;
  tCRAM_AR_CTL CRAM_AR_CTL;
  logic CRAM_EXP_TST;
  tCRAM_MQ_CTL CRAM_MQ_CTL;
  tCRAM_PC_FLAGS CRAM_PC_FLAGS;
  tCRAM_FLAG_CTL CRAM_FLAG_CTL;
  tCRAM_SPEC_INSTR CRAM_SPEC_INSTR;
  tCRAM_FETCH CRAM_FETCH;
  tCRAM_EA_CALC CRAM_EA_CALC;
  tCRAM_SP_MEM CRAM_SP_MEM;
  tCRAM_MREG_FNC CRAM_MREG_FNC;
  tCRAM_MBOX_CTL CRAM_MBOX_CTL;
  tCRAM_MTR_CTL CRAM_MTR_CTL;
  tCRAM_EBUS_CTL CRAM_EBUS_CTL;
  tCRAM_DIAG_FUNC CRAM_DIAG_FUNC;

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
    CRAM_ADA = adaAR;
    CRAM_ADA_EN = adaEnable;
    CRAM_ADB = adbFM;
    CRAM_AR = arAR;
    CRAM_ARX = arxARX;
    CRAM_BR = brRECIRC;
    CRAM_BRX = brxRECIRC;
    CRAM_BRload = 0;
    CRAM_BRXload = 0;
    CRAM_MQ = mqRECIRC;

    // Initialize all CRAM fields we do not use but may someday
    CRAM_J = 0;
    CRAM_SCAD = scadA;
    CRAM_SCADA = scadaFE;
    CRAM_SCADA_EN = scadaEnable;
    CRAM_SCADB = scadbSC;
    CRAM_SC = scRECIRC;
    CRAM_FE = feRECIRC;
    CRAM_SH = shAR;
    CRAM_ARMM = armmMAGIC;
    CRAM_VMAX = vmaxVMAX;
    CRAM_VMA = vmaVMA;
    CRAM_TIME = time2T;
    CRAM_MEM = memNOP;
    CRAM_SKIP = skipNOP;
    CRAM_COND = condNOP;
    CRAM_CALL = 0;
    CRAM_DISP = dispDIAG;
    CRAM_SPEC = specNOP;
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
    CRAM_ACB = acbMICROB;
    CRAM_ACmagic = 0;
    CRAM_CLR = clrNOP;
    CRAM_MAGIC = 0;

    CRAM_FMADR = fmadrAC0;
    APR_FMblk = 0;              // Select a good block number
    APR_FMadr = 7;              // And a good FM AC #

    CON_fmWrite00_17 = 0;       // No writing to FM
    CON_fmWrite18_35 = 0;

    SCD_ARMMupper = 0;
    SCD_ARMMlower = 0;

    diagReadFunc12X = 0;
    VMA_VMAheldOrPC = 0;        // Reset PC for now

    // Load AR with 123456789
    @(negedge eboxClk)
    $display($time, "<< AD/A, ADA/AR, AR/CACHE=36'h123456789, BR/AR >>");
    cacheDataRead = 36'h123456789;
    CRAM_AD = adA;
    CRAM_ADA = adaAR;
    CRAM_ADA_EN = adaEnable;
    CRAM_ADB = adbBR;          // Not used yet
    CRAM_AR = arCACHE;
    CTL_ARL_SEL = 4'b0001; // CACHE
    CTL_ARR_SEL = 4'b0001; // CACHE
    CTL_AR00to08load = 1;  // Load ARL pieces
    CTL_AR09to17load = 1;
    CTL_ARRload = 1;       // Load ARR
    CRAM_BR = brAR;
    CRAM_BRload = 1;
    CRAM_ARX = arxARX;


    // Try AD/A first
    @(negedge eboxClk)
    $display($time, "<< AD/A, ADA/AR, AR/CACHE=36'h123456789, BR/AR >>");
    cacheDataRead = 36'h123456789;
    CRAM_AD = adA;
    CRAM_ADA = adaAR;
    CRAM_ADA_EN = adaEnable;
    CRAM_ADB = adbBR;          // Not used yet
    CRAM_AR = arCACHE;
    CTL_ARL_SEL = 4'b0001; // CACHE
    CTL_ARR_SEL = 4'b0001; // CACHE
    CTL_AR00to08load = 1;  // Load ARL pieces
    CTL_AR09to17load = 1;
    CTL_ARRload = 1;       // Load ARR
    CRAM_BR = brAR;
    CRAM_BRload = 1;
    CRAM_ARX = arxARX;


    // Try AD/B
    @(posedge eboxClk) ;
    @(negedge eboxClk)
    $display($time, "<< AD/B, ADA/AR, ADB/BR, AR/CACHE=36'h987654321 >>");
    cacheDataRead = 36'h987654321;
    CRAM_AD = adA;
    CRAM_ADA = adaAR;
    CRAM_ADA_EN = adaEnable;
    CRAM_ADB = adbBR;
    CRAM_AR = arCACHE;
    CTL_ARL_SEL = 4'b0001; // CACHE
    CTL_ARR_SEL = 4'b0001; // CACHE
    CTL_AR00to08load = 1;  // Load ARL pieces
    CTL_AR09to17load = 1;
    CTL_ARRload = 1;       // Load ARR
    CRAM_BR = brAR;
    CRAM_BRload = 1;
    CRAM_ARX = arxARX;

    // Try AD/0S
    @(posedge eboxClk) ;
    @(negedge eboxClk)
    $display($time, "<< AD/0S, ADA/AR, ADB/BR, AR/CACHE=36'h987654321 >>");
    cacheDataRead = 36'h987654321;
    CRAM_AD = adZEROS;          // AD/0S
    CRAM_ADA = adaAR;
    CRAM_ADA_EN = adaEnable;
    CRAM_ADB = adbBR;
    CRAM_AR = arCACHE;
    CTL_ARL_SEL = 4'b0001; // CACHE
    CTL_ARR_SEL = 4'b0001; // CACHE
    CTL_AR00to08load = 1;  // Load ARL pieces
    CTL_AR09to17load = 1;
    CTL_ARRload = 1;       // Load ARR
    CRAM_BR = brAR;
    CRAM_BRload = 1;
    CRAM_ARX = arxARX;

    // Now add 987654321 and 123456789
    @(posedge eboxClk) ;
    @(negedge eboxClk)
    $display($time, "<< AD/A+B, ADA/AR, ADB/BR, AR/CACHE=36'h987654321 >>");
    cacheDataRead = 36'h987654321;
    CRAM_AD = adAplusB;         // AD/A+B
    CRAM_ADA = adaAR;
    CRAM_ADA_EN = adaEnable;
    CRAM_ADB = adbBR;
    CRAM_AR = arCACHE;
    CTL_ARL_SEL = 4'b0001; // CACHE
    CTL_ARR_SEL = 4'b0001; // CACHE
    CTL_AR00to08load = 1;  // Load ARL pieces
    CTL_AR09to17load = 1;
    CTL_ARRload = 1;       // Load ARR
    CRAM_BR = brAR;
    CRAM_BRload = 1;
    CRAM_ARX = arxARX;

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
