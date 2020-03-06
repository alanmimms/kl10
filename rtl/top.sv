`timescale 1ns/1ns
`include "ebox.svh"

module top(input clk,
           input CROBAR
);

  bit [27:35] MBOX_GATE_VMA;
  bit [0:35] cacheDataRead;
  bit [0:35] cacheDataWrite;
  bit [10:12] CACHE_CLEARER;

  bit ANY_EBOX_ERR_FLG;
  bit req;
  bit read;
  bit write;

  bit mboxClk;
  bit EXTERNAL_CLK;
  assign EXTERNAL_CLK = clk;
  bit clk30;
  assign clk30 = clk;
  bit clk31;                  // XXX

  // TEMPORARY?
  bit PWR_WARN = 0;

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
  iMCL MCL();
  iMTR MTR();
  iPAG PAG();
  iPI PIC();
  iPMA PMA();
  iSCD SCD();
  iSHM SHM();
  iVMA VMA();

  iMBOX MBOX();
  iMBZ MBZ();

  ebox ebox0(.*);
  mbox mbox0(.*);

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
