`timescale 1ns/1ns
module top;
`include "ebus-defs.svh"

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

  /*AUTOREG*/

  reg mboxClk;
  reg eboxSync;
  reg vmaACRef;
  reg [37:35] mboxGateVMA;
  reg [0:35] cacheDataRead;
  reg [0:35] cacheDataWrite;
  reg [10:12] cacheClearer;
  reg [13:35] eboxVMA;

  reg anyEboxError;


  // TEMPORARY
  reg cshEBOXRetry = 0;
  reg mboxRespIn = 0;

  reg pfHold = 0;
  reg pfEBOXHandle = 0;
  reg pfPublic = 0;

  reg cshAdrParErr = 0;
  reg mbParErr = 0;
  reg sbusErr = 0;
  reg nxmErr = 0;
  reg mboxCDirParErr = 0;


  // This is the multiplexed EBUS, enabled by the EBUS.driving.XXX
  // signal coming from each module to determine who gets to provide
  // EBUS its content.
  //
  // While it might appear with an EBOX-centric viewpoint that EBUS is
  // entirely contained within the EBOX and should therefore be muxed
  // in ebox.v, note that control of RH20 and DTE20 devices relies on
  // EBUS as well. (See KL10_BlockDiagrams_May76.pdf p.3.) Therefore
  // top.v is where the EBUS mux belongs.
  tEBUS EBUS;

  clk clk0(.*);
  ebox ebox0(.*);
  mbox mbox0(.*);

  always_comb begin
    if (EBUS.drivers.EDP) EBUS.data = EDP_EBUS;
    else if (EBUS.drivers.IR) EBUS.data = IR_EBUS;
    else if (EBUS.drivers.SCD) EBUS.data = SCD_EBUS;
    else EBUS.data = '0;
  end
endmodule
