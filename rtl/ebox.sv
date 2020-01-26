`timescale 1ns / 1ps
`include "cram-defs.svh"
module ebox(input eboxClk,
            input fastMemClk,

            output reg [13:35] EBOX_VMA,
            output reg [10:12] cacheClearer,

            output reg eboxReq,
            input cshEBOXT0,
            input  cshEBOXRetry,
            input mboxRespIn,

            output reg eboxSync,
            output reg mboxClk,

            input pfHold,
            input pfEBOXHandle,
            input pfPublic,

            output reg vmaACRef,

            input [27:35] mboxGateVMA,
            input [0:35] cacheDataRead,
            output [0:35] cacheDataWrite,

            output reg pageTestPriv,
            output reg pageIllEntry,
            output reg eboxUser,

            output reg eboxMayBePaged,
            output reg eboxCache,
            output reg eboxLookEn,
            output reg ki10PagingMode,
            output reg pageAdrCond,

            output reg eboxMap,

            output reg eboxRead,
            output reg eboxPSE,
            output reg eboxWrite,

            output reg upt,
            output reg ept,
            output reg userRef,

            output reg eboxCCA,
            output reg eboxUBR,
            output reg eboxERA,
            output reg eboxEnRefillRAMWr,
            output reg eboxSBUSDiag,
            output reg eboxLoadReg,
            output reg eboxReadReg,

            output reg ptDirWrite,
            output reg ptWr,
            output reg mboxCtl03,
            output reg mboxCtl06,
            output reg wrPtSel0,
            output reg wrPtSel1,

            input [0:10] pfDisp,
            input cshAdrParErr,
            input mbParErr,
            input sbusErr,
            input nxmErr,
            input mboxCDirParErr,
            output reg anyEboxError,

            input [0:35] EBUS,
            input [0:7] EBUS_DS,
            output reg APRdrivingEBUS,
            output reg [0:35] APR_EBUS,

            output reg CRAdrivingEBUS,
            output reg [0:35] CRA_EBUS,

            output reg EDPdrivingEBUS,
            output reg [0:35] EDP_EBUS,

            output reg IRdrivingEBUS,
            output reg [0:35] IR_EBUS,

            output reg SCDdrivingEBUS,
            output reg [0:35] SCD_EBUS

            /*AUTOARG*/);

  // TEMPORARY
  wire force1777;
  wire CONDAdr10;
  wire MULdone;

  // TEMPORARY
  assign FORCE1777 = 0;
  assign CONDAdr10 = 0;
  assign MULdone = 0;

  con con0(.*);
  cra cra0(.*);
  crm crm0(.*);
  edp edp0(.*);
  ir ir0(.*);
  vma vma0(.*);
  apr apr0(.*);
  mcl mcl0(.*);
  ctl ctl0(.*);
  scd scd0(.*);
  shm shm0(.*);
  csh csh0(.*);
  cha cha0(.*);
  chx chx0(.*);
  pma pma0(.*);
  pag pag0(.*);
  chd chd0(.*);
  mbc mbc0(.*);
  mbz mbz0(.*);
  pic pic0(.*);
  chc chc0(.*);
  ccw ccw0(.*);
  crc crc0(.*);
  ccl ccl0(.*);
  mtr mtr0(.*);
  dps dps0(.*);
endmodule // ebox
