`timescale 1ns/1ns
`include "ebox.svh"

module top;
  bit clk, CROBAR, EXTERNAL_CLK, clk30, clk31;

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

  bit [18:35] hwOptions = {1'b0,      // [18] 50Hz
                           1'b0,      // [19] Cache (XXX note this is ZERO for now)
                           1'b1,      // [20] Internal channels
                           1'b1,      // [21] Extended KL
                           1'b0,      // [22] Has master oscillator (not needed here)
                           13'd4001}; // [23:35] Serial number

  ebox ebox0(.*);
  mbox mbox0(.SBUS(SBUS.mbox), .*);
  memory memory0(.SBUS(SBUS.memory), .*);

`ifdef KL10PV_TB
  kl10pv_tb kl10pv_tb0(.*);
`endif

  // Mux for EBUS data lines
  always_comb unique case (1)
              default: EBUS.data = '0;
              APR.EBUSdriver.driving:        EBUS.data = APR.EBUSdriver.data;
              CON.EBUSdriver.driving:        EBUS.data = CON.EBUSdriver.data;
              CRA.EBUSdriver.driving:        EBUS.data = CRA.EBUSdriver.data;
              CTL.EBUSdriver.driving:        EBUS.data = CTL.EBUSdriver.data;
              EDP.EBUSdriver.driving:        EBUS.data = EDP.EBUSdriver.data;
              IR.EBUSdriver.driving:         EBUS.data =  IR.EBUSdriver.data;
              MBZ.EBUSdriver.driving:        EBUS.data = MBZ.EBUSdriver.data;
              MTR.EBUSdriver.driving:        EBUS.data = MTR.EBUSdriver.data;
              PIC.EBUSdriver.driving:        EBUS.data = PIC.EBUSdriver.data;
              SCD.EBUSdriver.driving:        EBUS.data = SCD.EBUSdriver.data;
              SHM.EBUSdriver.driving:        EBUS.data = SHM.EBUSdriver.data;
              VMA.EBUSdriver.driving:        EBUS.data = VMA.EBUSdriver.data;
`ifdef KL10PV_TB
              kl10pv_tb0.EBUSdriver.driving: EBUS.data = kl10pv_tb0.EBUSdriver.data;
`endif
              endcase
endmodule
