`timescale 1ns/1ns
// This is like MC10136 ECL universal up-down counter
module UniversalCounter4(input [0:3] D,
                         input CIN,
                         input [0:1] SEL,
                         input CLK,
                         output logic [0:3] Q,
                         output logic COUT);

  always_ff @(posedge CLK) begin

    case (SEL)
    2'b00: begin                // LOAD
      Q <= D;
      COUT <= '1;
    end
    
    2'b01: begin                // DEC
      if (CIN) begin
        Q <= Q - 4'b0001;
        COUT <= Q == 4'b0000;
      end
    end

    2'b10: begin                // INC
      if (CIN) begin
        Q <= Q + 4'b0001;
        COUT <= Q == 4'b1111;
      end
    end

    2'b11: COUT <= '0;          // HOLD
    endcase
  end
endmodule