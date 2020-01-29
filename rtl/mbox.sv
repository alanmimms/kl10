`timescale 1ns/1ns
module mbox(input mboxClk,
            input [13:35] EBOX_VMA,
            input vmaACRef,
            input [27:35] mboxGateVMA,
            input [0:35] cacheDataWrite,
            output logic [0:35] cacheDataRead,
            output logic [0:10] pfDisp,
            input req,
            input read,
            input PSE,
            input write);

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

endmodule // mbox
// Local Variables:
// verilog-library-files:("../ip/fake_mem/fake_mem_stub.v")
// End:
