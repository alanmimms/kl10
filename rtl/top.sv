`timescale 1ns/1ns
`include "ebus-defs.svh"

module top(input masterClk
`ifdef KL10PV_TB
           ,
           input eboxClk,
           input fastMemClk,
           input eboxReset
`endif
);
  /*AUTOWIRE*/
  // Beginning of automatic wires (for undeclared instantiated-module outputs)
  wire                  eboxCCA;                // From ebox0 of ebox.v
  wire                  eboxCache;              // From ebox0 of ebox.v
  wire                  eboxClk;                // From clk0 of clk.v
  wire                  eboxERA;                // From ebox0 of ebox.v
  wire                  eboxEnRefillRAMWr;      // From ebox0 of ebox.v
  wire                  eboxLoadReg;            // From ebox0 of ebox.v
  wire                  eboxLookEn;             // From ebox0 of ebox.v
  wire                  eboxMap;                // From ebox0 of ebox.v
  wire                  eboxMayBePaged;         // From ebox0 of ebox.v
  wire                  eboxPSE;                // From ebox0 of ebox.v
  wire                  eboxRead;               // From ebox0 of ebox.v
  wire                  eboxReadReg;            // From ebox0 of ebox.v
  wire                  eboxReq;                // From ebox0 of ebox.v
  wire                  eboxSBUSDiag;           // From ebox0 of ebox.v
  wire                  eboxUBR;                // From ebox0 of ebox.v
  wire                  eboxUser;               // From ebox0 of ebox.v
  wire                  eboxWrite;              // From ebox0 of ebox.v
  wire                  ept;                    // From ebox0 of ebox.v
  wire                  fastMemClk;             // From clk0 of clk.v
  wire                  ki10PagingMode;         // From ebox0 of ebox.v
  wire                  mbXfer;                 // From clk0 of clk.v
  wire                  mboxCtl03;              // From ebox0 of ebox.v
  wire                  mboxCtl06;              // From ebox0 of ebox.v
  wire                  pageAdrCond;            // From ebox0 of ebox.v
  wire                  pageIllEntry;           // From ebox0 of ebox.v
  wire                  pageTestPriv;           // From ebox0 of ebox.v
  wire [0:10]           pfDisp;                 // From mbox0 of mbox.v
  wire                  ptDirWrite;             // From ebox0 of ebox.v
  wire                  ptWr;                   // From ebox0 of ebox.v
  wire                  upt;                    // From ebox0 of ebox.v
  wire                  userRef;                // From ebox0 of ebox.v
  wire                  wrPtSel0;               // From ebox0 of ebox.v
  wire                  wrPtSel1;               // From ebox0 of ebox.v
  // End of automatics

  logic mboxClk;
  logic eboxSync;
  logic vmaACRef;
  logic [27:35] mboxGateVMA;
  logic [0:35] cacheDataRead;
  logic [0:35] cacheDataWrite;
  logic [10:12] cacheClearer;
  logic [13:35] eboxVMA;

  logic anyEboxError;

  logic eboxReset;
  logic [13:35] EBOX_VMA;
  logic req;
  logic PSE;
  logic read;
  logic write;


  // TEMPORARY
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

  // This is the multiplexed EBUS, enabled by the tEBUSdriver
  // interface coming from each module to determine who gets to
  // provide EBUS its content.
  iEBUS EBUS();

  tEBUSdriver APR_EBUS;
  tEBUSdriver CON_EBUS;
  tEBUSdriver CRA_EBUS;
  tEBUSdriver CTL_EBUS;
  tEBUSdriver EDP_EBUS;
  tEBUSdriver IR_EBUS;
  tEBUSdriver SCD_EBUS;
  tEBUSdriver SHM_EBUS;
  tEBUSdriver VMA_EBUS;

// Drive all of our clocks from the testbench if running that way.
`ifdef KL10PV_TB
  clk clk0(.masterClk, .eboxReset, .mbXfer);
`else
  clk clk0(.*);
`endif

  ebox ebox0(.*);
  mbox mbox0(.*);

  always_comb begin
    if (APR_EBUS.driving)       EBUS.data = APR_EBUS.data;
    else if (CON_EBUS.driving)  EBUS.data = CON_EBUS.data;
    else if (CRA_EBUS.driving)  EBUS.data = CRA_EBUS.data;
    else if (CTL_EBUS.driving)  EBUS.data = CTL_EBUS.data;
    else if (EDP_EBUS.driving)  EBUS.data = EDP_EBUS.data;
    else if (IR_EBUS.driving)   EBUS.data = IR_EBUS.data;
    else if (SCD_EBUS.driving)  EBUS.data = SCD_EBUS.data;
    else if (SHM_EBUS.driving)  EBUS.data = SHM_EBUS.data;
    else if (VMA_EBUS.driving)  EBUS.data = VMA_EBUS.data;
    else EBUS.data = '0;
  end
endmodule
