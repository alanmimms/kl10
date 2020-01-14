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

  EDP edp(.clk(clk),
          .AD(AD),
          .ADX(ADX),
          .FM(FM),
          .ADcarry36(ADcarry36),
          .ADXcarry36(ADXcarry36),
          .ADlong(ADlong),
          .ARLsel(ARLsel),
          .ARRsel(ARRsel),
          .AR00to08load(AR00to08load),
          .AR09to17load(AR09to17load),
          .ARRload(ARRload),
          .BRload(BRload),
          .BRXload(BRXload),
          .ARXLsel(ARXLsel),
          .ARXRsel(ARXRsel),
          .ARXload(ARXload),
          .MQsel(MQsel),
          .MQMsel(MQMsel),
          .MQMen(MQMen),
          .AR00to11clr(AR00to11clr),
          .AR12to17clr(AR12to17clr),
          .ARRclr(ARRclr),
          .ARMM(ARMM),
          .cacheData(cacheData),
          .ebusD(ebusD),
          .SH(SH),
          .MQ(MQ),
          .adToEBUS_L(adToEBUS_L),
          .adToEBUS_R(adToEBUS_R),
          .ad6bEQ0(ad6bEQ0),
          .ADoverflow00(ADoverflow00),
          .ADbool(ADbool),
          .ADsel(ADsel),
          .ADAsel(ADAsel),
          .ADBsel(ADBsel),
          .ADAen(ADAen),
          .fmBlk(fmBlk),
          .fmAdr(fmAdr),
          .fmWrite00_17(fmWrite00_17),
          .fmWrite18_35(fmWrite18_35),
          .fmWrite(fmWrite),
          .fmParity(fmParity),
          .diag(diag),
          .diagReadFunc12X(diagReadFunc12X),
          .VMAheldOrPC(VMAheldOrPC),
          .magic(magic));

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
