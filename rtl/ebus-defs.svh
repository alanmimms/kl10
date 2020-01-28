`ifndef _EBUS_DEFS_
 `define _EBUS_DEFS_ 1

typedef enum logic [0:2] {
                          ebusfCONO = 3'b000,
                          ebusfCONI = 3'b001,
                          ebusfDATAO = 3'b010,
                          ebusfDATAI = 3'b011,
                          ebusfPIserved = 3'b100,
                          ebusfPIaddrIn = 3'b101
                          } tEBUSfunction;


// Each driver of EBUS gets its own instance of this. These are all
// muxed onto the iEBUS.data member based on the one-hot
// tEBUSdriver.driving indicator.
typedef struct packed{
  logic [0:35] data;
  logic driving;
} tEBUSdriver;

interface iEBUS;
  logic [0:35] data;            // Driven by EBUS mux
  logic dataParity;             // Parity for what exactly? XXX
  logic [0:6] cs;               // EBOX -> dev Controller select
  tEBUSfunction func;           // EBOX -> dev Function
  logic demand;                 // EBOX -> dev
  logic [0:7] pi;               // Dev -> EBOX Priority Interrupt
  logic ack;                    // Dev -> EBOX acknowledge
  logic xfer;                   // Dev -> EBOX transfer done
  logic reset;                  // EBOX -> dev
  logic [0:7] ds;               // Dev -> EBOX??? Diagnostic Select
  logic diagStrobe;             // Dev -> EBOX Diagnostic strobe
  logic dfunc;                  // Dev -> EBOX Diagnostic function
endinterface

`endif
