`include "cram-defs.svh"
module ebox(input eboxClk,
            input fastMemClk,

            output logic eboxReset,

            output logic [13:35] EBOX_VMA,
            output logic [10:12] cacheClearer,

            output logic eboxReq,
            input cshEBOXT0,
            input  cshEBOXRetry,
            input mboxRespIn,

            output logic eboxSync,
            output logic mboxClk,

            input pfHold,
            input pfEBOXHandle,
            input pfPublic,

            output logic vmaACRef,

            input [27:35] mboxGateVMA,
            input [0:35] cacheDataRead,
            output [0:35] cacheDataWrite,

            output logic pageTestPriv,
            output logic pageIllEntry,
            output logic eboxUser,

            output logic eboxMayBePaged,
            output logic eboxCache,
            output logic eboxLookEn,
            output logic ki10PagingMode,
            output logic pageAdrCond,

            output logic eboxMap,

            output logic eboxRead,
            output logic eboxPSE,
            output logic eboxWrite,

            output logic upt,
            output logic ept,
            output logic userRef,

            output logic eboxCCA,
            output logic eboxUBR,
            output logic eboxERA,
            output logic eboxEnRefillRAMWr,
            output logic eboxSBUSDiag,
            output logic eboxLoadReg,
            output logic eboxReadReg,

            output logic ptDirWrite,
            output logic ptWr,
            output logic mboxCtl03,
            output logic mboxCtl06,
            output logic wrPtSel0,
            output logic wrPtSel1,

            input [0:10] pfDisp,
            input cshAdrParErr,
            input mbParErr,
            input sbusErr,
            input nxmErr,
            input mboxCDirParErr,
            output logic anyEboxError,

            input tEBUS EBUS,

            /*AUTOARG*/);

  timeunit 1ns;
  timeprecision 1ps;

  // TEMPORARY
  logic force1777;
  logic CONDAdr10;
  logic MULdone;

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
