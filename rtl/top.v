`timescale 1ns / 1ps
module top(
           input clk,

           input STARTbutton,
           input CONTINUEbutton,

           output LED0R,
           output LED0G,
           output LED0B,

           output LED1R,
           output LED1G,
           output LED1B
           /*AUTOARG*/);

  /*AUTOWIRE*/
  // Beginning of automatic wires (for undeclared instantiated-module outputs)
  wire [0:35]           APR_EBUS;               // From ebox0 of ebox.v
  wire                  APRdrivingEBUS;         // From ebox0 of ebox.v
  wire [0:35]           CRA_EBUS;               // From ebox0 of ebox.v
  wire                  CRAdrivingEBUS;         // From ebox0 of ebox.v
  wire [0:35]           EDP_EBUS;               // From ebox0 of ebox.v
  wire                  EDPdrivingEBUS;         // From ebox0 of ebox.v
  wire [0:35]           IR_EBUS;                // From ebox0 of ebox.v
  wire                  IRdrivingEBUS;          // From ebox0 of ebox.v
  wire [0:35]           SCD_EBUS;               // From ebox0 of ebox.v
  wire                  SCDdrivingEBUS;         // From ebox0 of ebox.v
  wire [0:35]           cacheData;              // From mbox0 of mbox.v
  wire                  eboxCCA;                // From ebox0 of ebox.v
  wire                  eboxCache;              // From ebox0 of ebox.v
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
  wire                  ki10PagingMode;         // From ebox0 of ebox.v
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
  // Beginning of automatic regs (for this module's undeclared outputs)
  reg                   LED0B;
  reg                   LED0G;
  reg                   LED0R;
  reg                   LED1B;
  reg                   LED1G;
  reg                   LED1R;
  // End of automatics

  wire mboxClk;
  wire eboxSync;
  wire vmaACRef;
  wire [37:35] mboxGateVMA;
  wire [0:35] cacheDataRead;
  wire [0:35] cacheDataWrite;
  wire [10:12] cacheClearer;
  wire [13:35] eboxVMA;

  wire anyEboxError;


  // TEMPORARY
  wire cshEBOXRetry = 0;
  wire mboxRespIn = 0;

  wire pfHold = 0;
  wire pfEBOXHandle = 0;
  wire pfPublic = 0;

  wire cshAdrParErr = 0;
  wire mbParErr = 0;
  wire sbusErr = 0;
  wire nxmErr = 0;
  wire mboxCDirParErr = 0;


  // This is the multiplexed current EBUS multiplexed by each the
  // XXXdrivingEBUS signal coming from each module to determine who
  // gets to provide EBUS its content.
  //
  // While it might appear with an EBOX-centric viewpoint that EBUS is
  // entirely contained within the EBOX and should therefore be muxed
  // in ebox.v, note that control of RH20 and DTE20 devices relies on
  // EBUS as well. (See KL10_BlockDiagrams_May76.pdf p.3.) Therefore
  // top.v is where the EBUS mux belongs.
  reg [0:35] EBUS;

  // EBUS is muxed in this design based on each module output
  // XXXdrivingEBUS.
  always @(posedge clk) begin

    if (EDPdrivingEBUS)
      EBUS <= EDP_EBUS;
    else if (IRdrivingEBUS)
      EBUS <= IR_EBUS;
         else if (SCDdrivingEBUS)
           EBUS <= SCD_EBUS;
  end

  ebox ebox0(/*AUTOINST*/
             // Outputs
             .eboxVMA                   (eboxVMA[13:35]),
             .cacheClearer              (cacheClearer[10:12]),
             .eboxReq                   (eboxReq),
             .eboxSync                  (eboxSync),
             .mboxClk                   (mboxClk),
             .vmaACRef                  (vmaACRef),
             .pageTestPriv              (pageTestPriv),
             .pageIllEntry              (pageIllEntry),
             .eboxUser                  (eboxUser),
             .eboxMayBePaged            (eboxMayBePaged),
             .eboxCache                 (eboxCache),
             .eboxLookEn                (eboxLookEn),
             .ki10PagingMode            (ki10PagingMode),
             .pageAdrCond               (pageAdrCond),
             .eboxMap                   (eboxMap),
             .eboxRead                  (eboxRead),
             .eboxPSE                   (eboxPSE),
             .eboxWrite                 (eboxWrite),
             .upt                       (upt),
             .ept                       (ept),
             .userRef                   (userRef),
             .eboxCCA                   (eboxCCA),
             .eboxUBR                   (eboxUBR),
             .eboxERA                   (eboxERA),
             .eboxEnRefillRAMWr         (eboxEnRefillRAMWr),
             .eboxSBUSDiag              (eboxSBUSDiag),
             .eboxLoadReg               (eboxLoadReg),
             .eboxReadReg               (eboxReadReg),
             .ptDirWrite                (ptDirWrite),
             .ptWr                      (ptWr),
             .mboxCtl03                 (mboxCtl03),
             .mboxCtl06                 (mboxCtl06),
             .wrPtSel0                  (wrPtSel0),
             .wrPtSel1                  (wrPtSel1),
             .anyEboxError              (anyEboxError),
             .APRdrivingEBUS            (APRdrivingEBUS),
             .APR_EBUS                  (APR_EBUS[0:35]),
             .CRAdrivingEBUS            (CRAdrivingEBUS),
             .CRA_EBUS                  (CRA_EBUS[0:35]),
             .EDPdrivingEBUS            (EDPdrivingEBUS),
             .EDP_EBUS                  (EDP_EBUS[0:35]),
             .IRdrivingEBUS             (IRdrivingEBUS),
             .IR_EBUS                   (IR_EBUS[0:35]),
             .SCDdrivingEBUS            (SCDdrivingEBUS),
             .SCD_EBUS                  (SCD_EBUS[0:35]),
             // Inputs
             .clk                       (clk),
             .cshEBOXT0                 (cshEBOXT0),
             .cshEBOXRetry              (cshEBOXRetry),
             .mboxRespIn                (mboxRespIn),
             .pfHold                    (pfHold),
             .pfEBOXHandle              (pfEBOXHandle),
             .pfPublic                  (pfPublic),
             .mboxGateVMA               (mboxGateVMA[27:35]),
             .cacheData                 (cacheData[0:35]),
             .pfDisp                    (pfDisp[0:10]),
             .cshAdrParErr              (cshAdrParErr),
             .mbParErr                  (mbParErr),
             .sbusErr                   (sbusErr),
             .nxmErr                    (nxmErr),
             .mboxCDirParErr            (mboxCDirParErr),
             .EBUS                      (EBUS[0:35]));

  mbox mbox0(.clk(mboxClk),
             /*AUTOINST*/
             // Outputs
             .cacheData                 (cacheData[0:35]),
             .pfDisp                    (pfDisp[0:10]),
             // Inputs
             .vma                       (vma[13:35]),
             .vmaACRef                  (vmaACRef),
             .mboxGateVMA               (mboxGateVMA[37:35]),
             .writeData                 (writeData[0:35]),
             .req                       (req),
             .read                      (read),
             .PSE                       (PSE),
             .write                     (write));
endmodule
