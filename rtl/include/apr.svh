`ifndef _APR_INTERFACE_
`define _APR_INTERFACE_ 1

interface iAPR;
  logic CLK;
  logic CONO_OR_DATAO;
  logic CONI_OR_DATAI;
  logic EBUS_RETURN;
  logic [0:2] FMblk;
  logic [0:3] FMadr;
endinterface

`endif
