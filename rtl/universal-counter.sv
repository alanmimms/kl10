`timescale 1ns/1ns
// This is like MC10136 ECL universal up-down counter but all positive logic
module UCR4(input bit RESET = 0,
            input bit [0:3] D,
            input bit CIN,
            input bit [0:1] SEL,
            input bit CLK,
            // NOTE these outputs are BIT, not LOGIC, so counting happens at power-on
            output bit [0:3] Q,
            output bit COUT);

  // Not LOAD or HOLD
  bit incOrDec = SEL[0] ^ SEL[1];

  // CIN overrides CLK when in INC or DEC mode. This signal is the
  // real clock we have to pay attention to as a result.
  bit carryClk;
  assign carryClk = incOrDec ? CIN : CLK;

  always_comb unique case (SEL)
              2'b00: COUT = 1;            // LOAD
              2'b01: COUT = Q == '0;      // DEC
              2'b10: COUT = Q == 4'b1111; // INC
              2'b11: COUT = 0;            // HOLD
              endcase
  
  always_ff @(posedge carryClk or posedge RESET) if (RESET) begin
    Q <= '0;
  end else unique case (SEL)
           2'b00: Q <= D;                    // LOAD
           2'b01: if (CIN) Q <= Q - 4'b0001; // DEC
           2'b10: if (CIN) Q <= Q + 4'b0001; // INC
           2'b11: ;                  // HOLD
           endcase
endmodule
