`timescale 1ns/1ns
`include "ebox.svh"

module ebox(input bit clk,
            input bit clk30,
            input bit clk31,
            input bit EXTERNAL_CLK,
            input bit CROBAR,
            input bit PWR_WARN,
            input bit [18:35] hwOptions,

            iAPR APR,
            iCCL CCL,
            iCHC CHC,
            iCLK CLK,
            iCON CON,
            iCRA CRA,
            iCRAM CRAM,
            iCRC CRC,
            iCRM CRM,
            iCSH CSH,
            iCTL CTL,
            iEDP EDP,
            iIR IR,
            iMBC MBC,
            iMBOX MBOX,
            iMBX MBX,
            iMBZ MBZ,
            iMCL MCL,
            iMTR MTR,
            iPAG PAG,
            iPI PIC,
            iPMA PMA,
            iSCD SCD,
            iSHM SHM,
            iVMA VMA,
            iEBUS.mod EBUS);

  bit mboxClk;

  apr apr0(.*);
  clk clk0(.*);
  con con0(.*);
  cra cra0(.*);
  crm crm0(.*);
  csh csh0(.*);
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
