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

            iMBZ MBZ,

            output logic [27:35] MBOX_GATE_VMA,
            output logic [0:35] cacheDataRead,
            output logic [0:10] pfDisp);

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
  csh csh0(.*);
  mbc mbc0(.*);
  mbz mbz0(.*);
  pag pag0(.*);
  pma pma0(.*);

endmodule // mbox
// Local Variables:
// verilog-library-files:("../ip/fake_mem/fake_mem_stub.v")
// End:
