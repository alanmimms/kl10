`ifndef _EBUS_DEFS_
 `define _EBUS_DEFS_ 1

typedef logic enum {
                    ebusfCONO = 3'b000,
                    ebusfCONI = 3'b001,
                    ebusfDATAO = 3'b010,
                    ebusfDATAI = 3'b011,
                    ebusfPIserved = 3'b100,
                    ebusfPIaddrIn = 3'b101
                    } tEBUSfunction;

typedef struct packed {
  logic [0:35] data;            // Driven by EBUS mux
  logic dataParity;             // Parity for what exactly? XXX
  logic [0:6] cs;               // EBOX -> dev Controller select
  logic [0:2] func;             // EBOX -> dev Function
  logic demand;                 // EBOX -> dev
  logic [0:7] pi;               // Dev -> EBOX Priority Interrupt
  logic ack;                    // Dev -> EBOX acknowledge
  logic xfer;                   // Dev -> EBOX transfer done
  logic reset;                  // EBOX -> dev
  logic [0:7] ds;               // Dev -> EBOX??? Diagnostic Select
  logic diagStrobe;             // Dev -> EBOX Diagnostic strobe
  logic dfunc;                  // Dev -> EBOX Diagnostic function

  // One-hot indicators for each module to get ownership of EBUS.data mux
  struct packed {
    logic APR;
    logic CRA;
    logic CTL;
    logic EDP;
    logic IR;
    logic SCD;
  } drivers;
} tEBUS;

`endif
