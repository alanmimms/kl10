`timescale 1ns/1ns
`include "ebox.svh"

// M8532 PI
module pi(iEBUS EBUS
);

  iPI PI();
  assign PI.EBUSdriver.driving = '0; // XXX temporary
endmodule
