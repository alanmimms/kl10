`timescale 1ns/1ns
// M8520 PAG
module pag(iPAG PAG);

  // XXX temporary
  initial begin
    PAG.PT_PUBLIC = '0;
    PAG.PF_EBOX_HANDLE = '0;
  end
endmodule // pag
