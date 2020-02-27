`timescale 1ns/1ns
`include "mbox.svh"
module mbox(input mboxClk,
            input [13:35] EBOX_VMA,
            input vmaACRef,
            input [0:35] cacheDataWrite,
            input req,
            input read,
            input PSE,
            input write,

            output bit [0:35] cacheDataRead,

            iCSH CSH,
            iMBZ MBZ,
            iPAG PAG,
            iMBOX MBOX
);

  // XXX temporary
  initial begin
    MBOX.MBOX_GATE_VMA = '0;
    MBOX.pfDisp = '0;
    MBOX.CSH_ADR_PAR_ERR = '0;
    MBOX.MB_PAR_ERR = '0;
    MBOX.ADR_PAR_ERR = '0;
    MBOX.NXM_ERR = '0;
    MBOX.SBUS_ERR = '0;
  end
  

`ifdef KL10PV_TB
  sim_mem
    #(.SIZE(4096), .WIDTH(36), .NBYTES(1))
  fake_mem
  (.clk(mboxClk),
   .din(cacheDataWrite),
   .dout(cacheDataRead),
   .addr(EBOX_VMA[24:35]),
   .wea(write));
`else
  fake_mem mem0(.clka(mboxClk),
                .addra(EBOX_VMA[24:35]), // XXX remove slice when using real memory
                .dina(cacheDataWrite),
                .douta(cacheDataRead),
                .ena(1'b1),
                .wea(write));
`endif

  ccl ccl0(.*);
  ccw ccw0(.*);
  cha cha0(.*);
  chc chc0(.*);
  chd chd0(.*);
  chx chx0(.*);
  crc crc0(.*);
  mbc mbc0(.*);
  mbz mbz0(.*);
  pag pag0(.*);
  pma pma0(.*);

endmodule // mbox
// Local Variables:
// verilog-library-files:("../ip/fake_mem/fake_mem_stub.v")
// End:
