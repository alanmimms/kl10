`timescale 1ns/1ns
`include "ebox.svh"

// M8532 PIC
module pi(iAPR APR,
          iCLK CLK,
          iCON CON,
          iCTL CTL,
          iEBUS.mod EBUS,
          iEDP EDP,
          iMTR MTR,
          iPI PIC               // Note we use PIC internally here bc of collision
          );

  bit clk, RESET, MR_RESET;
  bit [1:7] ON, GEN, PIR_EN, PIH, PIREN, PI_CLR, PI_REQ_SET, IO_REQ;
  bit [0:7] PIR, PI_ON;
  bit SYS_CLR, OFF, ACTIVE, APR_REQUESTING, DK20_REQUESTING, HONOR_INTERNAL;
  bit GEN_INT, TIM_5comma6, TIM1, TIM2, TIM3, TIM4, TIM5, TIM6, TIM7, COMP;
  bit _ON, PHY_FORCE, ON_SET, ON_CLR, GEN_ON, GEN_SET, GEN_CLR, REQ;
  bit [0:3] SEL_PHY;
  bit [0:15] PHY_NO;
  bit [11:17] IOB;
  bit [0:2] PIC2_PI;
  bit [0:7] PIC3_PI;
  bit [1:7] TIM;
  bit PI_REQ, APR_PHY_NO, DK20_PHY_NO, XFER_FORCE, INHIBIT_REQ, CYC_START;
  bit TRAN_REC, EBUS_RETURN, STATE_HOLD, TIMER_DONE;
  bit OK_ON_HALT, DISABLE_RDY_ON_HALT, READY, CONO_DLY;
  bit TIM1_L;           // PIC2 TIM1 L is different from PIC2 TIM1 H!
  bit [0:7] e88Q;
  bit [5:6] DIAG;

  bit DIAG_10, LOAD, WAIT1, WAIT2, TEST, CP_BUS_EN, EBUS_CP_GRANT, EBUS_PI_GRANT;
  bit EBUS_REQ, PI_DISABLE;
  bit BUS_EN;                   // BUS_EN is "PIC4 BUS EN" sheesh!
  bit BUS_EN_5;                 // BUS_EN_5 is "PIC5 BUS EN"
  bit [0:2] PIC5_GEN;           // This is the most fucked up naming in all of KL10

  // PIC1 p.209
  genvar n;
  generate

    for (n = 1; n <= 7; ++n) begin: pic1
      assign ON[n] = ON_SET & IOB[n+10] |
                     ON_CLR & IOB[n+10] & SYS_CLR & ON[n];
      assign GEN[n] = GEN_SET & IOB[n+10] |
                      GEN_CLR & IOB[n+10] & SYS_CLR & GEN[n];
      assign PIR_EN[n] = GEN[n] & ACTIVE |
                         ON[n] & IO_REQ[n] & ACTIVE;
      assign PI_REQ_SET[n] = PIH[n] & ~PI_CLR[n] | e88Q[n];

      always_ff @(posedge clk) if (SYS_CLR) PIH[n] <= '0;
                               else PIH[n] <= PI_REQ_SET[n];
    end
  endgenerate

  assign ACTIVE = _ON | ~SYS_CLR & OFF & ~ACTIVE;

  USR4 e79(.S0(1'b0),
           .D(PIR_EN[1:4]),
           .S3(1'b0),
           .SEL('0),
           .CLK(LOAD),
           .Q(PIR[1:4]));
  
  USR4 e76(.S0(1'b0),
           .D({PIR_EN[5:7], EBUS.pi[0]}), // EBUS PI00 E H (should be a PIC enable?)
           .S3(1'b0),
           .SEL('0),
           .CLK(LOAD),
           .Q({PIR[5:7], PIR[0]}));


  // PIC2 p.210
  bit [0:2] e77Q, e78Q, e35Q, e40Q;
  bit e35ANY;
  bit [0:3] e2Q, e12Q, e15Q;
  assign clk = CLK.PIC;
  assign PI_ON[0] = ~MR_RESET & ~PIC2_PI[0] & ~PIC2_PI[1] & ~PIC2_PI[2];
  assign PIC2_PI[1] = e78Q[0] | e77Q[0];
  assign PIC2_PI[2] = e78Q[1] | e77Q[1];
  assign REQ = e78Q[2] | e77Q[2];

  assign PHY_FORCE = PHY_NO[0] | e35ANY;
  assign SEL_PHY[0] = e35ANY & ~APR.EBOX_DISABLE_CS;
  assign SEL_PHY[1:3] = e35Q | e40Q;

  assign TIM1_L = MR_RESET | TIM[1];
  assign READY = DISABLE_RDY_ON_HALT & e12Q[1];
  assign PIC.EXT_TRAN_REC = TRAN_REC;

  assign EBUS_RETURN = APR.EBUS_RETURN | CTL.CONSOLE_CONTROL;
  assign STATE_HOLD = EBUS_RETURN |
                      ~TIMER_DONE & ~CYC_START |
                      TIM[6] & DISABLE_RDY_ON_HALT & ~CON.PI_CYCLE;
  assign DISABLE_RDY_ON_HALT = PI_DISABLE & ~OK_ON_HALT;

  assign TIM_5comma6 = TIM[5] | TIM[6];
  assign EBUS.demand = (~HONOR_INTERNAL | TIM[2]) & (TIM_5comma6 | TIM[2] | TIM[6]) |
                       APR.EBUS_DEMAND;
  assign HONOR_INTERNAL = APR_REQUESTING | DK20_REQUESTING | GEN_INT;
  assign TIMER_DONE = TIM[6] | e15Q[2];

  priority_encoder8 e78(.d({APR.EBOX_DISABLE_CS, PIR[0], PIH[1], PIR[1],
                            PIH[2], PIR[2], PIH[3], PIR[3]}),
                        .any(PIC2_PI[0]),
                        .q(e78Q));
  
  priority_encoder8 e77(.d({PIH[4] | PIC2_PI[0], PIR[4], PIH[5], PIR[5],
                            PIH[6], PIR[6], PIH[7], PIR[7]}),
                        .any(),
                        .q(e77Q));
  
  priority_encoder8 e35(.d({PHY_NO[0] | APR.EBOX_DISABLE_CS, PHY_NO[1:7]}),
                        .any(e35ANY),
                        .q(e35Q));
  
  priority_encoder8 e40(
                        .d({PHY_FORCE, PHY_NO[9:15]}),
                        .any(),
                        .q(e40Q));

  priority_encoder8 e82(.d({1'b0, PIH[1:7]}),
                        .any(),
                        .q(PIC.HOLD));

  bit ignoredE81;
  decoder e81(.sel(PIC.HOLD),
              .en(CON.PI_DISMISS),
              .q({ignoredE81, PI_CLR}));

  decoder e88(.sel(PIC2_PI),
              .en(CON.SET_PIH),
              .q(e88Q));

  USR4  e2(.S0(CYC_START),
           .D(4'b0000),
           .S3(1'b0),
           .SEL({STATE_HOLD, ~MR_RESET}),
           .CLK(clk),
           .Q(TIM[1:4]));

  USR4 e12(.S0(TIM[4]),
           .D(4'b0000),
           .S3(1'b0),
           .SEL({STATE_HOLD, ~MR_RESET}),
           .CLK(clk),
           .Q({TIM[5:7], COMP}));

  // e31, e44, e34
  always_ff @(posedge TIM[3]) PHY_NO <= EBUS.data[0:15];
  always_ff @(posedge TIM[3]) DK20_REQUESTING <= DK20_PHY_NO;
  always_ff @(posedge TIM[3]) APR_REQUESTING <= APR_PHY_NO;

  bit [1:3] ignoredE3;
  USR4  e3(.S0(1'b0),
           .D('0),
           .S3(EBUS.xfer | XFER_FORCE),
           .CLK(clk),
           .SEL({~EBUS_RETURN, 1'b0}),
           .Q({TRAN_REC, ignoredE3}));

  bit e10COUT;
  UCR4 e10(.CIN(~(TIM[5] & ~TRAN_REC)),
           .SEL({~(TIMER_DONE | EBUS_RETURN | CYC_START), 1'b0}),
           .D({TIM[1] | TIM[2] | TIM[6],
               TIM[2] | TIM[6] | CYC_START | TIM[3],
               TIM[5],
               ~(TIM[2] | TIM[6])}),
           .CLK(clk),
           .COUT(e10COUT),
           .Q());

  UCR4 e15(.CIN(e10COUT),
           .SEL({~(TIMER_DONE | EBUS_RETURN | CYC_START), 1'b0}),
           .D({2'b00, TIM[7], ~TIM[1]}),
           .CLK(clk),
           .COUT(),
           .Q(e15Q));


  // PIC3 p.211
  bit [0:7] e53Q, e52Q;
  assign DK20_PHY_NO = ~e53Q[0] | ~((PIC.MTR_PIA == PIC2_PI) & MTR.VECTOR_INTERRUPT);
  assign APR_PHY_NO = ~e52Q[0] | ~(PIC.APR_PIA == PIC2_PI) & APR.APR_INTERRUPT;
  assign PIC3_PI[1:7] = e53Q[1:7] | e52Q[1:7];
  assign PIC.MTR_HONOR = DK20_REQUESTING & TIM[6];

  decoder e53(.en(MTR.VECTOR_INTERRUPT),
              .sel(PIC.MTR_PIA),
              .q(e53Q));

  decoder e52(.en(APR.APR_INTERRUPT),
              .sel(PIC.APR_PIA),
              .q(e52Q));    

  bit ignoredE51, ignoredE56;
  USR4 e56(.S0(1'b0),
           .D({IOB[15:17], 1'b0}),
           .S3(1'b0),
           .SEL({~CON.CONO_APR, ~CON.CONO_APR & ~MR_RESET}),
           .CLK(clk),
           .Q({PIC.APR_PIA, ignoredE56}));

  USR4 e51(.S0(1'b0),
           .D({IOB[15:17], 1'b0}),
           .S3(1'b0),
           .SEL({~MTR.CONO_MTR, ~MTR.CONO_MTR & ~MR_RESET}),
           .CLK(clk),
           .Q({PIC.MTR_PIA, ignoredE51}));


  // PIC4 p.212
  bit e4q3;
  bit [0:7] e29Q;
  assign e4q3 = CONO_DLY & ~CTL.CONSOLE_CONTROL;
  assign GEN_CLR = EBUS.data[4] & e4q3;
  assign GEN_SET = EBUS.data[6] & e4q3;
  assign ON_SET = EBUS.data[7] & e4q3;
  assign ON_CLR = EBUS.data[8] & e4q3;
  assign OFF = EBUS.data[9] & e4q3;
  assign _ON = EBUS.data[10] & e4q3;

  assign SYS_CLR = EBUS.data[5] & ~CTL.CONSOLE_CONTROL & CON.CONO_PI | MR_RESET;
  assign PIC.EBUSdriver.data[3:9] = PIH[1:7];
  assign PIC.EBUSdriver.data[10] = ACTIVE;
  assign PIC.EBUSdriver.driving = BUS_EN;
  assign BUS_EN = EDP.DIAG_READ_FUNC_10x & ~CTL.DIAG[4];
  assign DIAG = CTL.DIAG[5:6];
  assign PIC.XOR_ON_BUS = BUS_EN | BUS_EN_5;
  assign EBUS.func[2] = ~MR_RESET & ~COMP | TIM[4] | APR.EBOX_SEND_F02;
  assign PIC.SEND_2H = e29Q[0] | e29Q[1] | e29Q[7];
  assign OK_ON_HALT = |e29Q[3:6];

  assign IOB = EBUS.data[11:17];
  assign IO_REQ = EBUS.pi[1:7] | PIC3_PI[1:7];

  // PIC2 NOTE 3: RESET is wire ORed to clear PI5 CYC START.
  // But I cannot find any evidence of this....

  assign MR_RESET = CLK.MR_RESET;

  always_ff @(posedge clk) CONO_DLY <= CON.CONO_PI;

  mux2x4 e32(.EN(BUS_EN),
             .SEL(DIAG),
             .D0({BUS_EN, 3'b000}),
             .D1({ON[1], GEN[1], EBUS.cs[5], TIMER_DONE}),
             .B0(DIAG_10),
             .B1(PIC.EBUSdriver.data[11]));

  mux2x4 e27(.EN(BUS_EN),
             .SEL(DIAG),
             .D0({ON[2], GEN[2], EBUS.cs[6], EBUS_PI_GRANT}),
             .D1({ON[3], GEN[3], EBUS.demand, STATE_HOLD}),
             .B0(PIC.EBUSdriver.data[12]),
             .B1(PIC.EBUSdriver.data[13]));

  mux2x4 e33(.EN(BUS_EN),
             .SEL(DIAG),
             .D0({ON[4], GEN[4], EBUS.cs[0], EBUS.cs[4]}),
             .D1({ON[5], GEN[5], EBUS.cs[1], HONOR_INTERNAL}),
             .B0(PIC.EBUSdriver.data[14]),
             .B1(PIC.EBUSdriver.data[16]));

  mux2x4 e28(.EN(BUS_EN),
             .SEL(DIAG),
             .D0({ON[6], GEN[6], EBUS.cs[2], PIC.READY}),
             .D1({ON[7], GEN[7], EBUS.cs[3], EBUS_REQ}),
             .B0(PIC.EBUSdriver.data[16]),
             .B1(PIC.EBUSdriver.data[17]));

  decoder e29(.en(~EBUS_RETURN & TIM[6]),
              .sel(EBUS.data[3:5]),
              .q(e29Q));


  // PIC5 p.213
  bit e6q14, e6SET;
  bit [0:3] e1Q;
  assign INHIBIT_REQ = EBUS_PI_GRANT | CON.PI_CYCLE;
  assign CP_BUS_EN = ~CON.EBUS_REL & EBUS_CP_GRANT |
                     ~EBUS_PI_GRANT & APR.EBUS_REQ;
  assign EBUS_REQ = (PI_ON[0] | ~PI_DISABLE & ACTIVE) &
                    TEST & REQ & ~CONO_DLY;
  assign XFER_FORCE = ~e6q14 | HONOR_INTERNAL & EBUS_PI_GRANT;
  assign e6SET = ~EBUS_CP_GRANT & ~TIM_5comma6;

  // e25
  always_comb if (~EBUS_RETURN & TIM[6]) PIC.EBUSdriver.data[7:10] = SEL_PHY;
              else PIC.EBUSdriver.data[7:10] = '0;

  assign GEN_INT = {PIC5_GEN ^ PIC2_PI, ~GEN_ON} != 4'b0000;
  assign PIC.GATE_TTL_TO_ECL = EBUS_PI_GRANT & ~EBUS_RETURN;

  // Modeling a SR DFF with D=0, async set, no clear
  always_ff @(posedge e1Q[0] or posedge e6SET) if (e6SET) e6q14 <= 1;
                                               else e6q14 <= 0;

  UCR4  e1(.CIN(~TIM[2]),
           .SEL({EBUS.demand & ~TRAN_REC, 1'b0}),
           .D(4'b0000),
           .CLK(~MTR._1_MHZ),
           .COUT(),
           .Q(e1Q));

  always_ff @(posedge clk) if (RESET) begin
      EBUS_CP_GRANT <= 0;
      EBUS_PI_GRANT <= 0;
    end else begin
      EBUS_CP_GRANT <= CP_BUS_EN;
      EBUS_PI_GRANT <= ~COMP & EBUS_PI_GRANT |
                       ~CP_BUS_EN & ~EBUS_PI_GRANT & EBUS_REQ;
    end

  always_ff @(posedge clk) PI_DISABLE <= CON.PI_DISABLE;

  always_ff @(posedge EBUS_PI_GRANT or posedge TIM[1]) if (TIM[1]) CYC_START <= 1;
                                                       else CYC_START <= 0;

  USR4 e30(.S0(~LOAD & ~WAIT1 & ~WAIT2),
           .D(4'b0000),
           .S3(1'b0),
           .SEL({EBUS_REQ, ~INHIBIT_REQ & ~CONO_DLY}),
           .CLK(clk),
           .Q({LOAD, WAIT1, WAIT2, TEST}));
  
  priority_encoder8 e62(.d({1'b0, GEN}),
                        .any(GEN_ON),
                        .q(PIC5_GEN));
endmodule
