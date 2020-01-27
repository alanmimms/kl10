module top;
  timeunit 1ns;
  timeprecision 1ps;

  /*AUTOWIRE*/
  // Beginning of automatic wires (for undeclared instantiated-module outputs)
  logic                  eboxCCA;                // From ebox0 of ebox.v
  logic                  eboxCache;              // From ebox0 of ebox.v
  logic                  eboxClk;                // From clk0 of clk.v
  logic                  eboxERA;                // From ebox0 of ebox.v
  logic                  eboxEnRefillRAMWr;      // From ebox0 of ebox.v
  logic                  eboxLoadReg;            // From ebox0 of ebox.v
  logic                  eboxLookEn;             // From ebox0 of ebox.v
  logic                  eboxMap;                // From ebox0 of ebox.v
  logic                  eboxMayBePaged;         // From ebox0 of ebox.v
  logic                  eboxPSE;                // From ebox0 of ebox.v
  logic                  eboxRead;               // From ebox0 of ebox.v
  logic                  eboxReadReg;            // From ebox0 of ebox.v
  logic                  eboxReq;                // From ebox0 of ebox.v
  logic                  eboxSBUSDiag;           // From ebox0 of ebox.v
  logic                  eboxUBR;                // From ebox0 of ebox.v
  logic                  eboxUser;               // From ebox0 of ebox.v
  logic                  eboxWrite;              // From ebox0 of ebox.v
  logic                  ept;                    // From ebox0 of ebox.v
  logic                  fastMemClk;             // From clk0 of clk.v
  logic                  ki10PagingMode;         // From ebox0 of ebox.v
  logic                  mbXfer;                 // From clk0 of clk.v
  logic                  mboxCtl03;              // From ebox0 of ebox.v
  logic                  mboxCtl06;              // From ebox0 of ebox.v
  logic                  pageAdrCond;            // From ebox0 of ebox.v
  logic                  pageIllEntry;           // From ebox0 of ebox.v
  logic                  pageTestPriv;           // From ebox0 of ebox.v
  logic [0:10]           pfDisp;                 // From mbox0 of mbox.v
  logic                  ptDirWrite;             // From ebox0 of ebox.v
  logic                  ptWr;                   // From ebox0 of ebox.v
  logic                  upt;                    // From ebox0 of ebox.v
  logic                  userRef;                // From ebox0 of ebox.v
  logic                  wrPtSel0;               // From ebox0 of ebox.v
  logic                  wrPtSel1;               // From ebox0 of ebox.v
  // End of automatics

  /*AUTOREG*/

  logic mboxClk;
  logic eboxSync;
  logic vmaACRef;
  logic [37:35] mboxGateVMA;
  logic [0:35] cacheDataRead;
  logic [0:35] cacheDataWrite;
  logic [10:12] cacheClearer;
  logic [13:35] eboxVMA;

  logic anyEboxError;


  // TEMPORARY
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


  // This is the multiplexed current EBUS multiplexed by the
  // EBUS.driving.XXX signal coming from each module to determine who
  // gets to provide EBUS its content.
  //
  // While it might appear with an EBOX-centric viewpoint that EBUS is
  // entirely contained within the EBOX and should therefore be muxed
  // in ebox.v, note that control of RH20 and DTE20 devices relies on
  // EBUS as well. (See KL10_BlockDiagrams_May76.pdf p.3.) Therefore
  // top.v is where the EBUS mux belongs.
  tEBUS EBUS;

  always_comb begin

    unique case (1'b1)
    EBUS.drivers.EDP: EBUS.data = EDP_EBUS;
    EBUS.drivers.IR: EBUS.data = IR_EBUS;
    EBUS.data.SCD: EBUS.data = SCD_EBUS;
    default: EBUS.data = 'z;
    endcase
  end

  clk clk0(.*);
  ebox ebox0(.*);
  mbox mbox0(.*);
endmodule
