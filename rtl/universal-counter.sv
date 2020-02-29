`timescale 1ns/1ns
// This is like MC10136 ECL universal up-down counter but all positive logic
module UCR4(input RESET,
            input [0:3] D,
            input CIN,
            input [0:1] SEL,
            input CLK,
            // NOTE these outputs are BIT, not LOGIC, so counting happens at power-on
            output bit [0:3] Q,
            output bit COUT);

  always_ff @(posedge CLK or posedge RESET) begin

    if (RESET) begin
      Q <= '0;
      COUT <= '0;
    end else begin

      case (SEL)
      2'b00: begin              // LOAD
        Q <= D;
        COUT <= '1;
      end
      
      2'b01: begin              // DEC

        if (CIN) begin
          Q <= Q - 4'b0001;
          COUT <= Q == 4'b0000;
        end else
          COUT <= '0;
      end

      2'b10: begin              // INC

        if (CIN) begin
          Q <= Q + 4'b0001;
          COUT <= Q == 4'b1111;
        end else
          COUT <= '0;
      end

      2'b11: ;                  // HOLD
      endcase
    end
  end
endmodule
