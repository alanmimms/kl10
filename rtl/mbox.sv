`timescale 1ns/1ns
`include "ebox.svh"
module mbox(input bit mboxClk,
            input bit CROBAR,
            iAPR APR,
            iCCL CCL,
            iCCW CCW,
            iCHA CHA,
            iCHC CHC,
            iCRC CRC,
            iCLK CLK,
            iCON CON,
            iCSH CSH,
            iCTL CTL,
            iEDP EDP,
            iIR IR,
            iMBC MBC,
            iMBX MBX,
            iMBZ MBZ,
            iMCL MCL,
            iMTR MTR,
            iPAG PAG,
            iPMA PMA,
            iSHM SHM,
            iVMA VMA,
            iEBUS.mod EBUS,
            iMBOX MBOX,
            iSBUS SBUS
);

  ccl ccl0(.*);
  ccw ccw0(.*);
  cha cha0(.*);
  chc chc0(.*);
  chd chd0(.*);
  chx chx0(.*);
  crc crc0(.*);
  mb0 mb00(.*);
  mbc mbc0(.*);
  mbx mbx0(.*);
  mbz mbz0(.*);
  mt0 mt00(.*);
  pag pag0(.*);
  pma pma0(.*);
endmodule // mbox
// Local Variables:
// verilog-library-files:("../ip/fake_mem/fake_mem_stub.v")
// End:
