`timescale 1ns/1ns
`include "ebus-defs.svh"

module top(input clk
`ifdef KL10PV_TB
           ,
           input eboxClk,
           input fastMemClk,
           input eboxReset
`endif
);

`ifndef KL10PV_TB
  logic eboxClk;
  logic fastMemClk;
`endif
    
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
  logic MR_RESET;
  logic CLK_EBOX_SYNC;
  logic CLK_SBR_CALL;
  logic CLK_RESP_MBOX;
  logic CLK_RESP_SIM;
  logic CLK_PAGE_ERROR;

  logic vmaACRef;
  logic [27:35] MBOX_GATE_VMA;
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

  logic CON_MB_XFER;

  logic MCL_VMA_SECTION_0;
  logic MCL_MBOX_CYC_REQ;
  logic MCL_VMA_FETCH;
  logic MCL_LOAD_AR;
  logic MCL_LOAD_ARX;
  logic MCL_LOAD_VMA;
  logic MCL_STORE_AR;
  logic MCL_SKIP_SATISFIED;
  logic MCL_SHORT_STACK;
  logic MCL_18_BIT_EA;
  logic MCL_23_BIT_EA;
  logic MCL_MEM_ARL_IND;

  logic CSH_PAR_BIT_A;
  logic CSH_PAR_BIT_B;

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
  tEBUSdriver MTR_EBUS;
  tEBUSdriver PI_EBUS;
  tEBUSdriver SCD_EBUS;
  tEBUSdriver SHM_EBUS;
  tEBUSdriver VMA_EBUS;

  ebox ebox0(.*);
  mbox mbox0(.*);

  always_comb begin
    if (APR_EBUS.driving)       EBUS.data = APR_EBUS.data;
    else if (CON_EBUS.driving)  EBUS.data = CON_EBUS.data;
    else if (CRA_EBUS.driving)  EBUS.data = CRA_EBUS.data;
    else if (CTL_EBUS.driving)  EBUS.data = CTL_EBUS.data;
    else if (EDP_EBUS.driving)  EBUS.data = EDP_EBUS.data;
    else if (IR_EBUS.driving)   EBUS.data = IR_EBUS.data;
    else if (MTR_EBUS.driving)  EBUS.data = MTR_EBUS.data;
    else if (PI_EBUS.driving)   EBUS.data = PI_EBUS.data;
    else if (SCD_EBUS.driving)  EBUS.data = SCD_EBUS.data;
    else if (SHM_EBUS.driving)  EBUS.data = SHM_EBUS.data;
    else if (VMA_EBUS.driving)  EBUS.data = VMA_EBUS.data;
    else EBUS.data = '0;
  end
endmodule
