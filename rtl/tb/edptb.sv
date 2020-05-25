`timescale 1ns/1ns
`include "ebox.svh"

module edptb(iAPR APR,
           iCLK CLK,
           iCON CON,
           iCRAM CRAM,
           iCTL CTL,
           iEDP EDP,
           iIR IR,
           iPI PIC,
           iSCD SCD,
           iSHM SHM,
           iVMA VMA,
           iEBUS.mod EBUS,
           iMBOX MBOX);
  bit clk;
  
  assign CLK.EDP = clk;

  initial begin
    $display($time, " [Start EDP test bench]");

    clk = 0;

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

    CRAM.FMADR = fmadrAC0;
    APR.FM_BLOCK = 0;           // Select a good block number
    APR.FM_ADR = 7;             // And a good FM AC #

    CON.FM_WRITE00_17 = 0;      // No writing to FM
    CON.FM_WRITE18_35 = 0;

    EDP.ARMM_SCD = 0;
    EDP.ARMM_VMA = 0;

    VMA.HELD_OR_PC = 0;         // Reset PC for now

    // Load AR with 123456789
    #10 clk = 0;
    $display($time, " set AR=h555555555");
    edp0.EDP.AR[0:35] = 36'h555555555;
    CRAM.AR <= arAR;
    CRAM.BR <= 0;
    CRAM.ARX <= arxARX;
    CRAM.BRX <= 0;
    #10 clk <= 1;
    #10 clk <= 0;
    $display($time, " AR=h%09X SB h555555555", EDP.AR[0:35]);

    // Try AD/A first
    #10 clk <= 0;
    MBOX.CACHE_DATA[0:35] <= 36'h123456789;
    CRAM.AD <= adA;
    CRAM.AR <= arAR;
    CRAM.ADA <= adaAR;
    CRAM.AR <= arAR;
    CRAM.BR <= 0;
    CRAM.ARX <= arxARX;
    CRAM.BRX <= 0;
    #10 clk <= 1;
    #10 clk <= 0;
    $display($time, " result: AD/A, ADA/AR, AR/AR AD=h%09x SB h555555555", EDP.AD[-2:35]);

    // Load BR with 987654321
    #10 clk <= 0;
    $display($time, " set BR=h987654321");
    edp0.EDP.BR[0:35] <= 36'h987654321;
    CRAM.AR <= arAR;
    CRAM.BR <= 0;
    CRAM.ARX <= arxARX;
    CRAM.BRX <= 0;
    #10 clk <= 1;
    #10 clk <= 0;
    $display($time, " BR=h%09X SB h987654321", EDP.BR[0:35]);

    // Try AD/B
    #10 clk <= 0;
    CRAM.AD <= adB;
    CRAM.ADA <= adaAR;
    CRAM.ADB <= adbBR;
    CRAM.AR <= arAR;
    CRAM.BR <= 0;
    CRAM.ARX <= arxARX;
    CRAM.BRX <= 0;
    #10 clk <= 1;
    #10 clk <= 0;
    $display($time, " result: AD/B, ADA/AR, ADB/BR AD=h%09x SB h987654321", EDP.AD[-2:35]);
  end
endmodule


module EDPtb_top();
  iAPR APR();
  iCLK CLK();
  iCON CON();
  iCTL CTL();
  iEDP EDP();
  iIR  IR();
  iPI  PIC();
  iSCD SCD();
  iSHM SHM();
  iVMA VMA();

  iEBUS EBUS();
  iMBOX MBOX();

  iCRAM cram0();

  bit [18:35] hwOptions = {1'b0,      // [18] 50Hz
                           1'b0,      // [19] Cache (XXX note this is ZERO for now)
                           1'b1,      // [20] Internal channels
                           1'b1,      // [21] Extended KL
                           1'b0,      // [22] Has master oscillator (not needed here)
                           13'd4001}; // [23:35] Serial number

  edptb edptb0(.CRAM(cram0.crm), .*);
  edp edp0(.CRAM(cram0.mod), .*);
endmodule
