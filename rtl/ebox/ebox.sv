`timescale 1ns/1ns
`include "cram-defs.svh"
`include "ebus-defs.svh"

module ebox(input eboxClk,
            input fastMemClk,

            input eboxReset,

            iAPR APR,

            input CSH_PAR_BIT_A,
            input CSH_PAR_BIT_B,
            input cshEBOXT0,
            input cshEBOXRetry,
            input mboxRespIn,

            input MCL_SHORT_STACK,
            input MCL_18_BIT_EA,
            input MCL_23_BIT_EA,
            input MCL_MEM_ARL_IND,
            input MCL_VMA_SECTION_0,
            input MCL_MBOX_CYC_REQ,
            input MCL_VMA_FETCH,
            input MCL_LOAD_AR,
            input MCL_LOAD_ARX,
            input MCL_LOAD_VMA,
            input MCL_STORE_AR,
            input MCL_SKIP_SATISFIED,

            input pfHold,
            input pfEBOXHandle,
            input pfPublic,

            input [0:10] pfDisp,
            input cshAdrParErr,
            input mbParErr,
            input sbusErr,
            input nxmErr,
            input mboxCDirParErr,

            input [27:35] MBOX_GATE_VMA,
            input [0:35] cacheDataRead,

            tEBUSdriver APR_EBUS,
            tEBUSdriver CON_EBUS,
            tEBUSdriver CRA_EBUS,
            tEBUSdriver CTL_EBUS,
            tEBUSdriver EDP_EBUS,
            tEBUSdriver IR_EBUS,
            tEBUSdriver PI_EBUS,

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

            output logic anyEboxError,

            output logic [13:35] EBOX_VMA,
            output logic [10:12] CACHE_CLEARER,
            output logic EBOX_REQ,
            output logic CLK_EBOX_SYNC,
            output logic mboxClk,

            iEBUS EBUS);

  logic EBUS_PARITY_E;
  logic EBUS_PARITY_ACTIVE_E;

  logic [8:10] norm;
  logic [0:12] IR;
  logic [9:12] IRAC;
  logic [0:2] DRAM_A;
  logic [0:2] DRAM_B;
  logic [0:10] DRAM_J;
  logic DRAM_ODD_PARITY;

  logic [0:10] NICOND;

  logic [0:3] SR;

  logic DIAG_CHANNEL_CLK_STOP;
  logic [4:6] DIAG;

  logic [0:35] FM;
  logic fmParity;

  logic pcSection0;
  logic localACAddress;
  logic indexed;
  logic FEsign;
  logic SCsign;
  logic SCADsign;
  logic SCADeq0;
  logic FPD;
  logic ARparityOdd;

  logic [10:1] AREAD;
  logic dispParity;

  tCRADR CRADR;

  iCRAM CRAM();

  // TEMPORARY
  logic force1777;
  logic CONDAdr10;
  logic MULdone;

  // TEMPORARY
  assign force1777 = 0;
  assign CONDAdr10 = 0;
  assign MULdone = 0;

  apr apr0(.*, .EBUSdriver(APR_EBUS));
  clk clk0(.*);
  con con0(.*, .EBUSdriver(CON_EBUS));
  cra cra0(.*, .EBUSdriver(CRA_EBUS));
  crm crm0(.*);
  ctl ctl0(.*, .EBUSdriver(CTL_EBUS));
  edp edp0(.*, .EBUSdriver(EDP_EBUS));
  ir  ir0 (.*, .EBUSdriver(IR_EBUS));
  mcl mcl0(.*);
  mtr mtr0(.*);
  pi  pi0(.*, .EBUSdriver(PI_EBUS));
  scd scd0(.*);
  shm shm0(.*);
  vma vma0(.*);
endmodule // ebox
