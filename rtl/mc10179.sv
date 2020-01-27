module mc10179(input [3:0] G,
               input [3:0] P,
               input CIN,

               output GG,
               output PG,
               output C8OUT,
               output C2OUT
               );

  timeunit 1ns;
  timeprecision 1ps;

  assign C8OUT = ~|{~G[3],
                    ~|{P[3], G[2]},
                    ~|{P[3], P[2], G[1]},
                    ~|{P[3], P[2], P[1], G[0]},
                    ~|{P[3], P[2], P[1], P[0], CIN}};
  assign C2OUT = ~|{~G[1],
                    ~|{P[1], G[0]},
                    ~|{P[1], P[0], CIN}};
  assign GG = ~|{~G[3],
                 ~|{P[3], G[2]},
                 ~|{P[3], P[2], G[1]},
                 ~|{P[3], P[2], P[1], G[0]}};
  assign PG = P[3] | P[2] | P[1] | P[0];
endmodule // mc10179
