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

            output logic pageTestPriv,
            output logic pageIllEntry,
            output logic eboxUser,

            output logic eboxMayBePaged,
            output logic eboxCache,
            output logic eboxLookEn,
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

            output logic ANY_EBOX_ERR_FLG,

            output logic [13:35] EBOX_VMA,
            output logic [10:12] CACHE_CLEARER,
            output logic EBOX_REQ,
            output logic mboxClk,

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
