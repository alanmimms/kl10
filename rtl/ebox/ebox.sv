`timescale 1ns/1ns
`include "ebox.svh"
`include "mbox.svh"

module ebox(input clk,
            input clk30,
            input clk31,
            input EXTERNAL_CLK,
            input CROBAR,

            iAPR APR,
            iCLK CLK,
            iCON CON,
            iCRA CRA,
            iCRAM CRAM,         // CR0 TODO
            iCRM CRM,
            iCSH CSH,           // TODO
            iCTL CTL,
            iEDP EDP,
            iIR IR,
            iMCL MCL,
            iMTR MTR,           // TODO
            iPAG PAG,           // TODO
            iPI PI,
            iSCD SCD,
            iSHM SHM,           // TODO
            iVMA VMA,

            iMBOX MBOX,         // TODO?
            iMBZ MBZ,           // TODO

            input CSH_PAR_BIT_A,
            input CSH_PAR_BIT_B,
            input cshEBOXT0,
            input cshEBOXRetry,
            input mboxRespIn,

            input pfHold,
            input pfEBOXHandle,
            input pfPublic,

            input [0:10] pfDisp,
            input cshAdrParErr,
            input mbParErr,
            input sbusErr,
            input nxmErr,
            input mboxCDirParErr,

            input PWR_WARN,

            input [27:35] MBOX_GATE_VMA,
            input [0:35] cacheDataRead,

            output [0:35] cacheDataWrite,

            output bit pageTestPriv,
            output bit pageIllEntry,
            output bit eboxUser,

            output bit eboxMayBePaged,
            output bit eboxCache,
            output bit eboxLookEn,
            output bit pageAdrCond,

            output bit eboxMap,

            output bit eboxRead,
            output bit eboxPSE,
            output bit eboxWrite,

            output bit upt,
            output bit ept,
            output bit userRef,

            output bit eboxCCA,
            output bit eboxUBR,
            output bit eboxERA,
            output bit eboxEnRefillRAMWr,
            output bit eboxSBUSDiag,
            output bit eboxLoadReg,
            output bit eboxReadReg,

            output bit ptDirWrite,
            output bit ptWr,
            output bit mboxCtl03,
            output bit mboxCtl06,
            output bit wrPtSel0,
            output bit wrPtSel1,

            output bit ANY_EBOX_ERR_FLG,

            output bit [13:35] EBOX_VMA,
            output bit [10:12] CACHE_CLEARER,
            output bit EBOX_REQ,
            output bit mboxClk,

            iEBUS EBUS);

  apr apr0(.*);
  clk clk0(.*);
  con con0(.*);
  cra cra0(.*);
  crm crm0(.*);
  ctl ctl0(.*);
  edp edp0(.*);
  ir  ir0 (.*);
  mcl mcl0(.*);
  mtr mtr0(.*);
  pi  pi0(.*);
  scd scd0(.*);
  shm shm0(.*);
  vma vma0(.*);
endmodule // ebox
