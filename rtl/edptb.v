`timescale 1ns / 1ps
`ifdef TESTBENCH
module edptb;
  reg clk;
  
  reg [0:35] AD;
  reg [0:36] ADX;
  reg [0:35] FM;
  reg ADcarry36, ADXcarry36, ADlong;

  reg [0:2] ARXLsel;
  reg [0:2] ARXRsel;
  reg AR00to08load, AR09to17load, ARRload, ARXload;
  reg AR00to11clr, AR12to17clr, ARRclr;

  reg BRload, BRXload;
  reg [0:1] MQsel, MQMsel;
  reg MQMen;
  
  reg [0:35] ARMM, cacheData, ebusD, SH, MQ;
  
  reg adToEBUS_L, adToEBUS_R;
  
  reg [0:5] ad6bEQ0;
  reg ADoverflow00;
  
  reg ADbool;
  reg [0:3] ADsel;
  reg [0:1] ADAsel, ADBsel;
  reg [0:35] ADAen;
  
  reg [0:2] fmBlk;
  reg [0:3] fmAdr;
  reg fmWrite00_17, fmWrite18_35, fmWrite, fmParity;
  reg [0:8] diag;
  reg diagReadFunc12X;
  
  reg [0:35] VMAheldOrPC;
  reg [0:8] magic;

  edp edp0(/*AUTOINST*/
           // Outputs
           .cacheDataWrite              (cacheDataWrite[0:35]),
           .EDP_AD                      (EDP_AD[0:35]),
           .EDP_ADX                     (EDP_ADX[0:36]),
           .EDP_BR                      (EDP_BR[0:36]),
           .EDP_BRX                     (EDP_BRX[0:36]),
           .EDP_MQ                      (EDP_MQ[0:35]),
           .ADoverflow00                (ADoverflow00),
           .EDP_AR                      (EDP_AR[0:35]),
           .EDP_ARX                     (EDP_ARX[0:35]),
           .FM                          (FM[0:35]),
           .fmWrite                     (fmWrite),
           .fmParity                    (fmParity),
           .ADcarry36                   (ADcarry36),
           .EDPdrivingEBUS              (EDPdrivingEBUS),
           .EDP_EBUS                    (EDP_EBUS[0:35]),
           // Inputs
           .eboxClk                     (eboxClk),
           .fastMemClk                  (fastMemClk),
           .ADXcarry36                  (ADXcarry36),
           .ADlong                      (ADlong),
           .CRAM_AD                     (CRAM_AD[0:6]),
           .CRAM_ADA                    (CRAM_ADA[0:3]),
           .CRAM_ADA_EN                 (CRAM_ADA_EN[0:1]),
           .CRAM_ADB                    (CRAM_ADB[0:2]),
           .CRAM_AR                     (CRAM_AR[0:3]),
           .CRAM_ARX                    (CRAM_ARX[0:3]),
           .CRAM_MAGIC                  (CRAM_MAGIC[0:8]),
           .CTL_ARL_SEL                 (CTL_ARL_SEL[0:2]),
           .CTL_ARR_SEL                 (CTL_ARR_SEL[0:2]),
           .CTL_AR00to08load            (CTL_AR00to08load),
           .CTL_AR09to17load            (CTL_AR09to17load),
           .CTL_ARRload                 (CTL_ARRload),
           .CTL_AR00to11clr             (CTL_AR00to11clr),
           .CTL_AR12to17clr             (CTL_AR12to17clr),
           .CTL_ARRclr                  (CTL_ARRclr),
           .CTL_ARXL_SEL                (CTL_ARXL_SEL[2:0]),
           .CTL_ARXR_SEL                (CTL_ARXR_SEL[2:0]),
           .CTL_ARX_LOAD                (CTL_ARX_LOAD),
           .BRload                      (BRload),
           .BRXload                     (BRXload),
           .CTL_MQ_SEL                  (CTL_MQ_SEL[0:1]),
           .CTL_MQM_SEL                 (CTL_MQM_SEL[0:1]),
           .CTL_MQM_EN                  (CTL_MQM_EN),
           .cacheDataRead               (cacheDataRead[0:35]),
           .EBUS                        (EBUS[0:35]),
           .SHM_SH                      (SHM_SH[0:35]),
           .SCD_ARMM                    (SCD_ARMM[0:8]),
           .adToEBUS_L                  (adToEBUS_L),
           .adToEBUS_R                  (adToEBUS_R),
           .APR_FMblk                   (APR_FMblk[0:2]),
           .APR_FMadr                   (APR_FMadr[0:3]),
           .fmWrite00_17                (fmWrite00_17),
           .fmWrite18_35                (fmWrite18_35),
           .CRAM_DIAG_FUNC              (CRAM_DIAG_FUNC[0:8]),
           .diagReadFunc12X             (diagReadFunc12X),
           .VMA_VMAheldOrPC             (VMA_VMAheldOrPC[0:35]));

  always #20 clk = ~clk;

  initial begin
    ADXcarry36 = 0;
    ADlong = 0;
    
    ARLsel = 0;
    ARRsel = 0;
    AR00to08load = 0;
    AR09to17load = 0;
    ARRload = 0;

    BRload = 0;
    BRXload = 0;

    ARXLsel = 0;
    ARXRsel = 0;
    ARXload = 0;

    MQsel = 0;
    MQMsel = 0;
    MQMen = 0;

    AR00to11clr = 0;
    AR12to17clr = 0;
    ARRclr = 0;

    ARMM = 0;
    cacheData = 0;
    SH = 0;
    MQ = 0;

    adToEBUS_L = 0;
    adToEBUS_R = 0;

    ADbool = 0;
    ADSel = 0;
    ADBsel = 0;
    ADAen = 0;

    fmBlk = 0;
    fmAdr = 0;

    fmWrite00_17 = 0;
    fmWrite18_35 = 0;

    diag = 0;
    diagReadFunc12X = 0;

    VMAheldOrPC = 0;
    magic = 0;
  end


  always @(posedge clk) begin
/*
           output wire [0:35] AD,
           output wire [0:36] ADX,
           output wire [0:35] FM,
           output wire ADcarry36,
           output reg [0:35] MQ,
           output wire [0:5] ad6bEQ0, // AD 00-05=0, ...
           output wire ADoverflow00,
           output wire fmWrite,
           output wire fmParity,
*/
    end // always @ (posedge clk)

endmodule
`endif
