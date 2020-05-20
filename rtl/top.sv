`timescale 1ns/1ns
`include "ebox.svh"

module top(input clk,
           input CROBAR,
           input EXTERNAL_CLK,
           input clk30,
           input clk31
);

  bit [27:35] MBOX_GATE_VMA;
  bit [10:12] CACHE_CLEARER;

  bit mboxClk;

  // TEMPORARY?
  bit PWR_WARN;

  // While it might appear with an EBOX-centric viewpoint that EBUS is
  // entirely contained within the EBOX and should therefore be muxed
  // in ebox.v, note that control of RH20 and DTE20 devices relies on
  // EBUS as well. (See KL10_BlockDiagrams_May76.pdf p.3.) Therefore
  // top.v is where the EBUS mux belongs.

  // This is the multiplexed EBUS, enabled by the tEBUSdriver from
  // each module to determine who gets to provide EBUS its content.
  iEBUS EBUS();

  iAPR APR();
  iCCL CCL();
  iCCW CCW();
  iCHA CHA();
  iCHC CHC();
  iCLK CLK();
  iCON CON();
  iCRA CRA();
  iCRAM CRAM();
  iCRC CRC();
  iCRM CRM();
  iCSH CSH();
  iCTL CTL();
  iEDP EDP();
  iIR IR();
  iMBC MBC();
  iMBX MBX();
  iMBZ MBZ();
  iMCL MCL();
  iMTR MTR();
  iPAG PAG();
  iPI PIC();
  iPMA PMA();
  iSCD SCD();
  iSHM SHM();
  iVMA VMA();

  iMBOX MBOX();
  iSBUS SBUS();

  bit [0:35] hwOptions = {18'b0,     // Domain of the Microcode
                          1'b0,      // [18] 50Hz
                          1'b1,      // [19] Cache
                          1'b1,      // [20] Internal channels
                          1'b1,      // [21] Extended KL
                          1'b1,      // [22] Has master oscillator
                          13'd4001}; // [23:35] Serial number

  ebox ebox0(.*);
  mbox mbox0(.SBUS(SBUS.mbox), .*);
  memory memory0(.SBUS(SBUS.memory), .*);

`ifdef KL10PV_TB
  kl10pv_tb kl10pv_tb0(.*);
`endif

  always_comb begin
    if (APR.EBUSdriver.driving)       EBUS.data = APR.EBUSdriver.data;
    else if (CON.EBUSdriver.driving)  EBUS.data = CON.EBUSdriver.data;
    else if (CRA.EBUSdriver.driving)  EBUS.data = CRA.EBUSdriver.data;
    else if (CTL.EBUSdriver.driving)  EBUS.data = CTL.EBUSdriver.data;
    else if (EDP.EBUSdriver.driving)  EBUS.data = EDP.EBUSdriver.data;
    else if (IR.EBUSdriver.driving)   EBUS.data = IR.EBUSdriver.data;
    else if (MTR.EBUSdriver.driving)  EBUS.data = MTR.EBUSdriver.data;
    else if (PIC.EBUSdriver.driving)   EBUS.data = PIC.EBUSdriver.data;
    else if (SCD.EBUSdriver.driving)  EBUS.data = SCD.EBUSdriver.data;
    else if (SHM.EBUSdriver.driving)  EBUS.data = SHM.EBUSdriver.data;
    else if (VMA.EBUSdriver.driving)  EBUS.data = VMA.EBUSdriver.data;
    else EBUS.data = '0;
  end
endmodule
