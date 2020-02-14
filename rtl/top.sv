`timescale 1ns/1ns
`include "ebox.svh"

module top(input clk,
           input CROBAR,
           input FPGA_RESET
);

  logic eboxCCA;
  logic eboxCache;
  logic eboxERA;
  logic eboxEnRefillRAMWr;
  logic eboxLoadReg;
  logic eboxLookEn;
  logic eboxMap;
  logic eboxMayBePaged;
  logic eboxPSE;
  logic eboxRead;
  logic eboxReadReg;
  logic EBOX_REQ;
  logic eboxSBUSDiag;
  logic eboxUBR;
  logic eboxUser;
  logic eboxWrite;
  logic ept;
  logic mboxCtl03;
  logic mboxCtl06;
  logic pageAdrCond;
  logic pageIllEntry;
  logic pageTestPriv;
  logic [0:10] pfDisp;
  logic ptDirWrite;
  logic ptWr;
  logic upt;
  logic userRef;
  logic wrPtSel0;
  logic wrPtSel1;

  logic mboxClk;

  logic vmaACRef;
  logic [27:35] MBOX_GATE_VMA;
  logic [0:35] cacheDataRead;
  logic [0:35] cacheDataWrite;
  logic [10:12] CACHE_CLEARER;
  logic [13:35] eboxVMA;

  logic ANY_EBOX_ERR_FLG;

  logic [13:35] EBOX_VMA;
  logic req;
  logic PSE;
  logic read;
  logic write;

  logic CSH_PAR_BIT_A;
  logic CSH_PAR_BIT_B;

  logic EXTERNAL_CLK;
  assign EXTERNAL_CLK = clk;
  logic clk30;
  assign clk30 = clk;
  logic clk31;                  // XXX

  // TEMPORARY
  logic PWR_WARN = 0;
  logic cshEBOXT0 = 0;
  logic cshEBOXRetry = 0;
  logic mboxRespIn = 0;

  logic pfHold = 0;
  logic pfEBOXHandle = 0;
  logic pfPublic = 0;

  logic cshAdrParErr = 0;
  logic mbParErr = 0;
  logic sbusErr = 0;
  logic nxmErr = 0;
  logic mboxCDirParErr = 0;

  // While it might appear with an EBOX-centric viewpoint that EBUS is
  // entirely contained within the EBOX and should therefore be muxed
  // in ebox.v, note that control of RH20 and DTE20 devices relies on
  // EBUS as well. (See KL10_BlockDiagrams_May76.pdf p.3.) Therefore
  // top.v is where the EBUS mux belongs.

  // This is the multiplexed EBUS, enabled by the tEBUSdriver from
  // each module to determine who gets to provide EBUS its content.
  iEBUS EBUS();

  iAPR APR();
  iCLK CLK();
  iCON CON();
  iCRA CRA();
  iCRAM CRAM();
  iCRM CRM();
  iCSH CSH();
  iCTL CTL();
  iEDP EDP();
  iIR IR();
  iMCL MCL();
  iMTR MTR();
  iPAG PAG();
  iPI PI();
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
    else if (PI.EBUSdriver.driving)   EBUS.data = PI.EBUSdriver.data;
    else if (SCD.EBUSdriver.driving)  EBUS.data = SCD.EBUSdriver.data;
    else if (SHM.EBUSdriver.driving)  EBUS.data = SHM.EBUSdriver.data;
    else if (VMA.EBUSdriver.driving)  EBUS.data = VMA.EBUSdriver.data;
    else EBUS.data = '0;
  end
endmodule
