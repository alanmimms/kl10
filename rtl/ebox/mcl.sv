`timescale 1ns/1ns
`include "ebox.svh"

// M8544 MCL
module mcl(iEBUS EBUS,
           iCRAM CRAM,
           iMCL MCL
);

  assign MCL.EBUSdriver.driving = '0; // XXX temporary
  assign MCL.ADR_ERR = '0;            // XXX temporary

  // MCL1 p.371
  logic [4:6] DIAG;
  logic DIAG_READ;
  logic ignoredE70;
  logic [0:3] ignoredE64;
  logic MEM_AREAD, MEM_WR_CYCLE, MEM_RPW_CYCLE, MEM_COND_FETCH;

  assign DIAG = CTL.DIAG[4:6];
  assign DIAG_READ = CTL.DIAG_READ_FUNC_10x;
  decoder e70(.en(~CRAM.MEM[0]),
              .sel(CRAM.MEM[1:3]),
              .q({ignoredE70, MCL.MEM_ARL_IND, MCL.MEM_MB_WAIT,
                  MCL.MEM_RESTORE_VMA, MEM_AREAD, MCL.MEM_B_WRITE,
                  MEM_COND_FETCH, MCL.MEM_REG_FUNC}));

  // E64 is redundant acive low drive of mostly the same signals.
  // It is elided.

  decoder e72(.en(~CRAM.MEM[0]),
              .sel(CRAM.MEM[1:3]),
              .q({MCL.MEM_AD_FUNC, MCM.MEM_EA_CALC, MCL.MEM_LOAD_AR,
                  MCL.MEM_LOAD_ARX, MCL.MEM_RW_CYCLE, MCL.MEM_RPW_CYCLE,
                  MCL.MEM_WRITE, MCL.MEM_UNCOND_FETCH}));

  logic AREAD_EA;
  assign AREAD_EA = MEM_AREAD & ~Aeq001;
endmodule // mcl
