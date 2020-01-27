module mbox(input mboxClk,
            input [13:35] EBOX_VMA,
            input vmaACRef,
            input [37:35] mboxGateVMA,
            input [0:35] cacheDataWrite,
            output logic [0:35] cacheDataRead,
            output logic [0:10] pfDisp,
            input req,
            input read,
            input PSE,
            input write
            /*AUTOARG*/);
  timeunit 1ns;
  timeprecision 1ps;

  fake_mem mem0(.clka(mboxClk),
                .addra(EBOX_VMA),
                .dina(cacheDataWrite),
                .douta(cacheDataRead),
                .ena(1),
                .wea(write)
                /*AUTOINST*/);
endmodule // mbox
// Local Variables:
// verilog-library-files:("../ip/fake_mem/fake_mem_stub.v")
// End:
