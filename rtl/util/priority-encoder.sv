`timescale 1ns/1ns

module priority_encoder
#(parameter N = 8)
  (input [0:N-1] d,
   output logic any,
   output logic [0:$clog2(N)-1] q);


  logic found = '0;

  always_comb begin
    any = |d;

    if (any) begin

      for (int n = 0; ~found && n < N; ++n) begin

        if (d[n]) begin
          q = n;
          found = '1;
        end
      end
    end
  end
endmodule
