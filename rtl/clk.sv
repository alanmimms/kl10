`timescale 1ns/100ps
`include "ebox.svh"

// M8526 CLK
//
// HUGE thanks to Rich Alderson of Living Computers Museum for a
// gorgeous 600 DPI scan of the MP00301 p. 170 in which original scan
// was obscured in a few places.
module clk(input bit clk,
           input bit CROBAR,
           input bit EXTERNAL_CLK,
           input bit clk30,
           input bit clk31,

           iAPR APR,
           iCLK CLK,
           iCON CON,
           iCRAM CRAM,
           iCRM CRM,
           iCSH CSH,
           iCTL CTL,
           iEDP EDP,
           iIR IR,
           iMCL MCL,
           iPAG PAG,
           iSCD SCD,
           iSHM SHM,
           iVMA VMA,

           iEBUS.mod EBUS
           );

  bit DESKEW_CLK = 0;
  bit SYNCHRONIZE_CLK;
  assign SYNCHRONIZE_CLK = 0;
  bit MBOX_RESP_SIM;
  bit AR_ARX_PAR_CHECK;
  bit DIAG_CHANNEL_CLK_STOP = 0; // XXX used on CLK1. ??? where is this driven?

  bit CRAM_PAR_CHECK, FM_PAR_CHECK, DRAM_PAR_CHECK, FS_CHECK;
  bit FS_EN_A, FS_EN_B, FS_EN_C, FS_EN_D, FS_EN_E, FS_EN_F, FS_EN_G;
  bit EBOX_SOURCE, EBOX_SRC_EN, MBOX, EBOX_SS;
  bit RATE_SELECTED, EBUS_CLK_SOURCE, SOURCE_DELAYED, CLK_OUT, EBOX_CLK;
  bit EBOX_CLK_EN, EBOX_CLK_ERROR, EBOX_EDP_DIS, EBOX_CRM_DIS, EBOX_CTL_DIS;
  bit BURST, CLK_DELAYED, MBOX_CLK, MAIN_SOURCE, GATED, GATED_EN, ODD, CLK_ON;
  bit [0:7] burstCounter;
  bit BURST_CNTeq0;

`ifndef KL10PV_TB
  ebox_clocks ebox_clocks0(.clk_in1(clk));
`endif

  // XXX this is for sim but probably won't work in hardware.
  bit fastMemClk;
  assign fastMemClk = CLK.EDP;

  bit delaysLocked;           // Watch for our clock delay mechanism to achieve lock
  assign CLK.CROBAR = CROBAR & ~delaysLocked;

  // This is WEIRD. This assign here seems to not work all the time?
  // Later on in this module near e39 I display DIAG and it is zero
  // while EBUS.ds is 7'b0000001 and EBUS.ds[4:6] is 3'b001. WHY WOULD
  // THAT BE?
  //
  // To try to find out why I changed several sites from DIAG to
  //EBUS.ds[4:6] and NOW the module WORKS.
/*
  bit [4:6] DIAG;
  assign DIAG[4:6] = EBUS.ds[4:6];
*/
  
  bit DIAG_READ;
  assign DIAG_READ = EDP.DIAG_READ_FUNC_10x;

  // CLK1 p.168
  mux e67(.en(1'b1),
          .sel({CROBAR, CLK.SOURCE_SEL}),
          .d({clk30, clk31, EXTERNAL_CLK, {5{clk30}}}),
          .q(MAIN_SOURCE));

  assign CLK.ERROR_STOP = ~CLK_ON & CLK.ERR_STOP_EN & CLK.FS_ERROR |
                          EBOX_CLK_ERROR & EBOX_SOURCE & ~CLK_ON & CLK.ERR_STOP_EN;

  // XXX ignoring the delay lines
  bit e56q2;
  always_ff @(posedge MAIN_SOURCE) e56q2 <= GATED_EN;

`ifdef KL10PV_TB
  assign delaysLocked = 1;
  
  /*
   Motorola 10k ECL gate delay (25C):
   * 10101: ~2.6ns
   * 10117: ~3ns
   * 10131: ~4.5ns (clock to output)
   * 10210: ~2.25ns

   (DL == Delay Line or PCB trace delay)
   (GD == Gate Delay)

   MAIN_SOURCE
     | [PCB-DL 5ns]
     +--- GATED
            | [DL1 2ns..20ns] - assume 50% = 10ns
            +===+===+--- EBUS_CLK_SOURCE = GATED + 20ns
                | [10101 E73q3 2.6ns]
                | [DL2 10ns..50ns] - assume 50% = 25ns
                | [10101 E73q15 2.6ns]  XXX NOTE INVERTING GATE
                | [DL3 50ns]
                | [10101 E73q5 2.6ns]
                | [PCB-DL 2.5ns]
                +--- SOURCE_DELAYED (~GATED+10+2.6+25+2.6+50+2.6+2.5ns)
                       | [10117 E63q15 3ns]
                       +--- CLK_ON
                              | [10210 E59q2 ~2.25ns]
                              +--- ODD
                              | [PCB-DL 2.65ns]
                              | [10210 E49q14 ~2.25ns]
                              +--- MBOX
                                     | [PCB-DL 3ns]
                                     | [GD ~2.25ns]
                                     +--- CCL, CRC, CHC
                                     | [PCB-DL 3ns]
                                     | [GD ~2.25ns]
                                     +--- MB 06, MB 12, CCW
                                     | [PCB-DL 3ns]
                                     | [GD ~2.25ns]
                                     +--- MBC, MBX, MBZ
                                     +--- MBOX 13, MBOX 14, MB 00
                                     | [PCB-DL 3ns]
                                     | [GD ~2.25ns]
                                     +--- MTR, CLK_OUT, PIC, PMA, CHX, CSH
   */

  always @(e56q2 & MAIN_SOURCE) GATED <= #5 (e56q2 & MAIN_SOURCE);
  always @(~GATED) EBUS_CLK_SOURCE <= #20 ~GATED;

  // Note inversion here
  always @(~GATED) SOURCE_DELAYED <= #93.7 ~GATED;

  always @((~CLK.ERROR_STOP | DESKEW_CLK) & (SOURCE_DELAYED | DESKEW_CLK))
    CLK_ON = #3 ((~CLK.ERROR_STOP | DESKEW_CLK) & (SOURCE_DELAYED | DESKEW_CLK));

  always @(CLK_ON) ODD <= #(2.25 + 7.75) CLK_ON;
  always @(~CLK_ON) MBOX <= #(2.65 + 2.25) CLK_ON;
  always @(MBOX) CLK_OUT <= #(3 + 2.25) MBOX;

  assign CLK.CCL = CLK_OUT | DIAG_CHANNEL_CLK_STOP;
  assign CLK.CRC = CLK_OUT | DIAG_CHANNEL_CLK_STOP;
  assign CLK.CHC = CLK_OUT | DIAG_CHANNEL_CLK_STOP;
  assign CLK.MB  = CLK_OUT | DIAG_CHANNEL_CLK_STOP;
  assign CLK.CCW = CLK_OUT | DIAG_CHANNEL_CLK_STOP;

  assign CLK.MBC = CLK_OUT;
  assign CLK.MBX = CLK_OUT;
  assign CLK.MBZ = CLK_OUT;

  assign CLK.MBOX_13 = CLK_OUT;
  assign CLK.MBOX_14 = CLK_OUT;

  assign CLK.MTR = CLK_OUT;
  assign CLK.PIC = CLK_OUT;
  assign CLK.PMA = CLK_OUT;
  assign CLK.CHX = CLK_OUT;
  assign CLK.CSH = CLK_OUT;

`else  ////////////////////////////////////////////////////////////////

  assign GATED = e56q2 & MAIN_SOURCE;
  kl_delays delays0(.clk_in1(GATED),
                    .locked(delaysLocked),
                    .ph5(ODD),
                    .ph10(MBOX),
                    .ph20(SOURCE_DELAYED),
                    .ph40(EBUS_CLK_SOURCE));
  assign CLK.CCL = MBOX | DIAG_CHANNEL_CLK_STOP;
  assign CLK.CRC = MBOX | DIAG_CHANNEL_CLK_STOP;
  assign CLK.CHC = MBOX | DIAG_CHANNEL_CLK_STOP;
  assign CLK.CCW = MBOX | DIAG_CHANNEL_CLK_STOP;
  assign CLK.MB  = MBOX | DIAG_CHANNEL_CLK_STOP;

  assign CLK.MBC = MBOX;
  assign CLK.MBX = MBOX;
  assign CLK.MBZ = MBOX;
  assign CLK.MBOX_13 = MBOX;
  assign CLK.MBOX_14 = MBOX;
  assign CLK.MTR = MBOX;
  assign CLK_OUT = MBOX;
  assign CLK.PIC = MBOX;
  assign CLK.PMA = MBOX;
  assign CLK.CHX = MBOX;
  assign CLK.CSH = MBOX;
`endif
  
  bit [0:3] rateSelSR;
  assign RATE_SELECTED = ~(rateSelSR[0] | rateSelSR[2]);
  
  USR4 e5(.S0(1'b0),
          .D({CLK.RATE_SEL[0], CLK.RATE_SEL[0], CLK.RATE_SEL[1], 1'b0}),
          .S3(1'b0),
          .SEL({~RATE_SELECTED, 1'b0}),
          .CLK(MAIN_SOURCE),
          .Q(rateSelSR));

  bit e70q15, e70q2;
  assign CLK.SBUS_CLK = e70q2;
  always @(posedge GATED, posedge CLK.FUNC_CLR_RESET) begin

    if (CLK.FUNC_CLR_RESET) begin
      CLK.SBUS_CLK <= 0;
      e70q15 <= 0;
      e70q2 <= 0;
    end else begin
      e70q15 <= ~e70q2; // XXX slashed wire in schematics
      e70q2 <= e70q15;
    end
  end

  bit e66q2;
  assign CLK.EBUS_CLK = e66q2;
  always @(posedge EBUS_CLK_SOURCE, posedge CLK.FUNC_CLR_RESET) begin

    if (CLK.FUNC_CLR_RESET) begin
      e66q2 <= 0;
    end else begin
      e66q2 <= e70q15;
    end
  end

  bit [0:3] e42SR;
  // NOTE: Active-low schematic symbol
  USR4 e42(.S0(1'b1),
           .D({CLK.FUNC_SINGLE_STEP,
               CLK.FUNC_EBOX_SS,
               CLK.FUNC_EBOX_SS & ~CLK.SYNC,
               CLK.FUNC_EBOX_SS}),
           .S3(CROBAR),
           .CLK(MAIN_SOURCE),
           .SEL(~{CLK.FUNC_GATE, CLK.FUNC_GATE | RATE_SELECTED}),
           .Q(e42SR));

  assign GATED_EN = CLK.GO & RATE_SELECTED |
                    ~BURST_CNTeq0 & BURST & RATE_SELECTED |
                    e42SR[0] & RATE_SELECTED |
                    CLK.FUNC_COND_SS & EBOX_CLK;

  // CLK2 p.169
  bit [0:3] e64SR;
  bit [0:3] e60FF;
  assign CLK.MHZ16_FREE = e64SR[3];

  USR4 e64(.S0(1'b0),
           .D({e64SR[0:1], ~(CTL.DIAG_CTL_FUNC_00x | CTL.DIAG_LD_FUNC_04x), 1'b1}),
           .S3(SYNCHRONIZE_CLK),
           .SEL({CLK.MHZ16_FREE, 1'b0}),
           .CLK(MAIN_SOURCE),
           .Q(e64SR));

  // XXX slashed wire
  assign CLK.FUNC_GATE = ~|e60FF[0:2];
  assign CLK.TENELEVEN_CLK = e60FF[3];
  always_ff @(posedge MAIN_SOURCE) begin
    // XXX slashed wire moves us from active-low to acitve-high
    // discipline.
    e60FF <= {~e64SR[0], e64SR[1:3]};
  end

  bit e66SRFF;
  always_ff @(posedge ~CLK.FUNC_SET_RESET,
              posedge CLK.FUNC_CLR_RESET,
              posedge CROBAR)
  begin

    // NOTE: Schematic symbol is active-low. To simplify this view the
    // output of e66SRFF as it would be on Q and /Q outputs (set makes
    // Q=1, clear makes Q=0) and then invert to drive MR_RESET which
    // is wired to /Q.
    if (CROBAR) begin                           // CLEAR
      e66SRFF <= 0;
    end else if (CLK.FUNC_CLR_RESET) begin      // SET
      e66SRFF <= 1;
    end else if (~CLK.FUNC_SET_RESET) begin     // LOAD
      e66SRFF <= 0;
    end
  end

  assign CLK.RESET = ~e66SRFF;
  assign CLK.MR_RESET = CLK.RESET;
  assign CLK.SYNC_HOLD = CLK.MR_RESET | CLK.SYNC;

  // In real KL, CLK_OUT is routed to far end of backplane and back as
  // CLK1 CLK DELAYED according to EBOX-UD Logical Delays and Skew,
  // Figure 3-25. In KL10B this signal is called CLK_OUT when it
  // leaves the CLK board (see CLK1 A1 E72 pin 3 <FR2>).
//  assign CLK_OUT = MBOX;

  // 125ns is a guess for round trip delay of clock signal across backplane.
  always @(CLK_OUT) CLK_DELAYED <= #125 CLK_OUT;

  assign MBOX_CLK = CLK_DELAYED;

  bit e32q2;
  always_ff @(posedge MBOX_CLK) e32q2 <= EBOX_CLK;
  assign CLK.PT_DIR_WR = e32q2 & APR.PT_DIR_WR;
  assign CLK.PT_WR = e32q2 & APR.PT_WR;

  // This counter's operation is described in EK-EBOX-UD-006 p. 231
  // (C-32) and in "3.2.3 EBus Reset" on p. 178. It counts down
  // to zero over and over again while CROBAR is asserted and then
  // stops after reaching zero after CROBAR's trailing edge.
  bit [0:3] e52Count;
  bit e52COUT;
  assign CLK.EBUS_RESET = e52Count[0];

  UCR4 e52(.CIN(1'b1),            // Always count
           .SEL({1'b0, ~e52COUT | CROBAR | CON.CONO_200000}),
           .CLK(CLK.MHZ16_FREE),
           .D('0),
           .COUT(e52COUT),
           .Q(e52Count));

  bit ncE37;
  // CLK.GO is derived from CLK.FUNC_START, which means "Start the KL clock".
  // NOTE: Active-low schematic symbol
  USR4 e37(.S0(1'b0),
           .D({CLK.FUNC_START, CLK.FUNC_BURST, CLK.FUNC_EBOX_SS, 1'b0}),
           .S3(1'b0),
           .SEL(~{2{CLK.FUNC_GATE | CROBAR}}),
           .CLK(MAIN_SOURCE),
           .Q({CLK.GO, BURST, EBOX_SS, ncE37}));
  
/*
  bit e47Ignore;
  decoder e47Decoder(.en(CLK.FUNC_GATE & CTL.DIAG_CTL_FUNC_00x),
                     .sel(DIAG),
                     .trace(1),
                     .traceName("clk.e47decoder"),
                     .q({e47Ignore, CLK.FUNC_START,
                         CLK.FUNC_SINGLE_STEP, CLK.FUNC_EBOX_SS,
                         CLK.FUNC_COND_SS, CLK.FUNC_BURST,
                         CLK.FUNC_CLR_RESET, CLK.FUNC_SET_RESET}));
*/
  always_comb begin

    if (CLK.FUNC_GATE & CTL.DIAG_CTL_FUNC_00x) begin
      case (EBUS.ds[4:6])
      default: {CLK.FUNC_START, CLK.FUNC_SINGLE_STEP, CLK.FUNC_EBOX_SS, CLK.FUNC_COND_SS,
                CLK.FUNC_BURST, CLK.FUNC_CLR_RESET, CLK.FUNC_SET_RESET} = '0;
      3'b001: CLK.FUNC_START = 1'b1;
      3'b010: CLK.FUNC_SINGLE_STEP = 1'b1;
      3'b011: CLK.FUNC_EBOX_SS = 1'b1;
      3'b100: CLK.FUNC_COND_SS = 1'b1;
      3'b101: CLK.FUNC_BURST = 1'b1;
      3'b110: CLK.FUNC_CLR_RESET = 1'b1;
      3'b111: CLK.FUNC_SET_RESET = 1'b1;
      endcase

      // This is WEIRD. I display DIAG here and it is zero while
      // EBUS.ds is 7'b0000001 and EBUS.ds[4:6] is 3'b001. WHY WOULD
      // THAT BE?
/*
      $display($time, " @@@@@@CLK FUNC DECODER TRACE@@@@@@ DIAG=%03b EBUS.ds=%07b EBUS.ds[4:6]=%03b new=%07b",
               DIAG, EBUS.ds, EBUS.ds[4:6],
               {CLK.FUNC_START, CLK.FUNC_SINGLE_STEP, CLK.FUNC_EBOX_SS, CLK.FUNC_COND_SS,
                CLK.FUNC_BURST, CLK.FUNC_CLR_RESET, CLK.FUNC_SET_RESET});
*/
    end else begin
      {CLK.FUNC_START, CLK.FUNC_SINGLE_STEP, CLK.FUNC_EBOX_SS, CLK.FUNC_COND_SS,
       CLK.FUNC_BURST, CLK.FUNC_CLR_RESET, CLK.FUNC_SET_RESET} = '0;
    end
  end

  bit [0:7] e50out;
  assign CLK.FUNC_042 = e50out[2];
  assign CLK.FUNC_043 = e50out[3];
  assign CLK.FUNC_044 = e50out[4] | CROBAR;
  assign CLK.FUNC_045 = e50out[5] | CROBAR;
  assign CLK.FUNC_046 = e50out[6] | CROBAR;
  assign CLK.FUNC_047 = e50out[7] | CROBAR;
  decoder e50Decoder(.en(CLK.FUNC_GATE & CTL.DIAG_LD_FUNC_04x),
                     .sel(EBUS.ds[4:6]),
                     .q(e50out));

  // CLK3 p.170
  bit [0:5] e58FF;
  bit e58Ignored;
  assign {CLK.DRAM_PAR_ERR, CLK.CRAM_PAR_ERR, CLK.FM_PAR_ERR,
          e58Ignored, CLK.FS_ERROR, EBOX_CLK_ERROR} = e58FF;

  bit e45FF4, e45FF13, e45FF14;
  assign CLK.ERROR_HOLD_A = ~IR.DRAM_ODD_PARITY & ~CON.LOAD_DRAM & DRAM_PAR_CHECK;
  // XXX these CLK.FS_EN_xxx are only initialized in kl10pv_tb
  assign CLK.ERROR_HOLD_B = (FS_EN_A | FS_EN_B | FS_EN_C | FS_EN_D) &
                            FS_EN_E & FS_EN_F & FS_EN_G & FS_CHECK;
  assign CLK.ERROR = e45FF4 | e45FF13;
  assign CLK.FS_ERROR = ~e45FF14;

  always_ff @(posedge ODD)
    e58FF <= {CLK.ERROR_HOLD_A,
              ~CRM.PAR_16 & CRAM_PAR_CHECK,
              ~APR.FM_ODD_PARITY & FM_PAR_CHECK,
              EBOX_SRC_EN,
              ~CLK.ERROR_HOLD_B,
              CLK.ERROR_HOLD_A};

  always_ff @(posedge ODD) e45FF4 <= CLK.ERROR_HOLD_B;
  always_ff @(posedge ODD) e45FF13 <= CLK.ERROR_HOLD_A;
  always_ff @(posedge ODD) e45FF14 <= ~CLK.ERROR_HOLD_B;

  // From EK-EBOX-UD-006-OCR.pdf on PDF p.233:
  //   The clock phase sync detector compares the MBox clock counter
  //   output with the CRAM time field (loaded at EBox clock time)
  //   whenever CLK3 EBOX CLOCK EN L is false. If the counter output
  //   compares with the bit combination in the time field (T00, T0i),
  //   CLK3 SYNC EN L is asserted and the next MBox clock sets CLK3 EBOX
  //   SYNC L.
  bit [0:3] e25Count;
  bit e25COUT;
  // NOTE: Active-low schematic symbol
  UCR4 e25(.CIN(1'b1),
           .SEL({~EBOX_CLK_EN, 1'b0}),
           .CLK(MBOX_CLK),
           .D('0),
           .COUT(e25COUT),
           .Q(e25Count));

  bit e31B;
  // Note CLK3 has active LOW symbol for E25 and E31. I am treating
  // the .D() inputs to E31 and Q output of E31 as active HIGH.
  mux e31(.en(~CLK.SYNC_HOLD),
          .sel({e25Count[0] | e25Count[1],
                e25Count[2:3]}),
          .d({~CRAM._TIME[0] & ~CRAM._TIME[1],
              ~CRAM._TIME[0],
              ~CRAM._TIME[1],
              ~CON.DELAY_REQ,
              {4{~e25COUT}}}),
          .q(e31B));

  assign CLK.SYNC_EN = EBOX_SS & ~EBOX_CLK_EN | e31B & ~EBOX_CLK_EN;

  bit e10FF;                    // Merged into single FF
  assign CLK.SYNC = e10FF;      // XXX slashed signals

  // Note CLK.EBOX_SYNC is described in EK-EBUS-UD-006 "3.2.4 EBox
  // Clock Control" p. 178. This signal is the "... MBOX Sync Point
  // (EBOX SYNC), which is always asserted one MBOX Clock prior to the
  // generation of the EBox clock (Figure 3-20)."
  //
  // Figure 3-20 Simplified Diagram, MBox Clock, Sync, EBox Clock
  //                  ___     ___
  // CLK MBOX CLK  __| 1 |__2|   |
  //                  _______
  // CLK EBOX SYNC __| 1     |____
  //                          ____
  // CLK EBOX CLK  __________|2
  //
  // NOTE: Actually EBOX CLOCK is clocked via CLK ODD which occurs
  // ~16ns earlier than MBOX CLK.
  assign CLK.EBOX_SYNC = e10FF;

  always_ff @(posedge MBOX_CLK) e10FF <= CLK.SYNC_EN;       // XXX slashed signals

  bit notHoldAB;
  bit [0:3] e12SR;
  bit e17q3;
  assign notHoldAB = ~CLK.ERROR_HOLD_A & ~CLK.ERROR_HOLD_B;
  assign e17q3 = ~CON.MBOX_WAIT | CLK.RESP_MBOX | VMA.AC_REF | EBOX_SS | CLK.RESET;

  USR4 e12(.S0(CLK.PF_DLYD_A),
           .D({CLK.SYNC & e17q3 & notHoldAB & ~EBOX_CRM_DIS,
               CLK.SYNC & e17q3 & notHoldAB & ~EBOX_EDP_DIS,
               CLK.SYNC & e17q3 & notHoldAB & ~EBOX_CTL_DIS,
               EBOX_SRC_EN}),
           .S3(1'b0),
           .SEL({CLK.PAGE_FAIL, CLK.PF_DLYD_A}),
           .CLK(ODD),
           .Q(e12SR));

  assign EBOX_SRC_EN = CLK.SYNC & e17q3;
  assign EBOX_CLK_EN = EBOX_SRC_EN | CLK._1777_EN;

  const real e12SRtoClockDLY = 1.75 + 2.25;

  always @(e12SR[0]) CLK.CRM <= #e12SRtoClockDLY e12SR[0];
  always @(e12SR[0]) CLK.CRA <= #e12SRtoClockDLY e12SR[0];
  always @(CTL.DIAG_CLK_EDP | e12SR[1]) CLK.EDP <= #e12SRtoClockDLY CTL.DIAG_CLK_EDP | e12SR[1];
  always @(e12SR[2]) CLK.APR <= #e12SRtoClockDLY e12SR[2];
  always @(e12SR[2]) CLK.CON <= #e12SRtoClockDLY e12SR[2];
  always @(e12SR[2]) CLK.VMA <= #e12SRtoClockDLY e12SR[2];
  always @(e12SR[2]) CLK.MCL <= #e12SRtoClockDLY e12SR[2];
  always @(e12SR[2]) CLK.IR  <= #e12SRtoClockDLY e12SR[2];
  always @(e12SR[2]) CLK.SCD <= #e12SRtoClockDLY e12SR[2];

  assign EBOX_SOURCE = e12SR[3];

  // CLK4 p.171
  bit e32Q3, e32Q13;
  assign CLK.MBOX_RESP = e32Q3 | e32Q13;
  assign CLK.MB_XFER = e32Q3 | e32Q13;
  assign CLK.RESP_SIM = CSH.MBOX_RESP_IN & CLK.SYNC_EN;
  assign CLK.RESP_MBOX = e32Q3 | e32Q13;

  // Negative logic Wire AND
  always_ff @(posedge MBOX_CLK)
    // NOTE: Wire AND
    CLK.EBOX_REQ <= ~(
                      ~(
                        CLK.EBOX_REQ & ~VMA.AC_REF |
                        CSH.EBOX_RETRY_REQ & ~VMA.AC_REF |
                        CLK.SYNC_EN & MCL.MBOX_CYC_REQ |
                        CLK.SYNC & MCL.MBOX_CYC_REQ) // E1q2
                      |
                      ~(~CLK.PAGE_FAIL_EN &
                        ~CSH.EBOX_T0_IN &
                        ~CLK.MBOX_CYCLE_DIS &
                        ~CLK.MR_RESET &
                        ~CLK.FORCE_1777) // E17q15
                      );

  always_ff @(posedge MBOX_CLK) e32Q3 <= CON.MBOX_WAIT & MBOX_RESP_SIM & ~EBOX_CLK_EN & ~VMA.AC_REF;
  always_ff @(posedge MBOX_CLK) e32Q13 <= CSH.MBOX_RESP_IN;
  always_ff @(posedge MBOX_CLK) EBOX_CLK <= EBOX_CLK_EN;

  // NOTE: Active-low schematic symbol
  USR4 e30(.S0(1'b0),
           .D({PAG.PF_EBOX_HANDLE,
               CON.AR_FROM_EBUS | CLK.PAGE_FAIL_EN,
               ~SHM.AR_PAR_ODD & CON.AR_LOADED,
               ~SHM.ARX_PAR_ODD & CON.ARX_LOADED}),
           .S3(1'b0),
           .SEL({2{~CLK.PAGE_FAIL}}),
           .CLK(ODD),
           .Q(CLK.PF_DISP[7:10]));

  always @(posedge ODD) CLK.PF_DLYD_A <= CLK.PAGE_FAIL;
  always @(posedge ODD) CLK.PF_DLYD_B <= CLK.PF_DLYD_A;

  assign CLK.PAGE_ERROR = CLK.PAGE_FAIL_EN | CLK.INSTR_1777;
  assign CLK._1777_EN = CLK.FORCE_1777 & CLK.SBR_CALL;
  always @(posedge MBOX_CLK)
    CLK.PAGE_FAIL_EN <= ~CLK.INSTR_1777 &
                        (CSH.PAGE_FAIL_HOLD | (CLK.PAGE_FAIL_EN & ~CLK.RESET));

  always @(posedge MBOX_CLK) CLK.INSTR_1777 <= CLK._1777_EN | (~EBOX_CLK_EN & CLK.INSTR_1777);
  always @(posedge MBOX_CLK) CLK.FORCE_1777 <= CLK.PF_DLYD_A;
  always @(posedge MBOX_CLK) CLK.SBR_CALL <= CLK.PF_DLYD_B;

  bit e7out7;                 // XXX slashed
  bit e38out7;                // XXX slashed
  assign e7out7 = EBOX_SOURCE | CLK.PF_DLYD_B | CLK.INSTR_1777;
  assign e38out7 = ~APR.APR_PAR_CHK_EN | ~AR_ARX_PAR_CHECK | e7out7;
  assign CLK.PAGE_FAIL = APR.SET_PAGE_FAIL & ~e7out7 |
                         ~SHM.AR_PAR_ODD & CON.AR_LOADED & ~e38out7 |
                         ~SHM.ARX_PAR_ODD & CON.ARX_LOADED & ~e38out7 |
                         CRAM.MEM[2] & CLK.PAGE_FAIL_EN & ~e7out7;
  assign CLK.EBOX_CYC_ABORT = CLK.PAGE_FAIL | CLK.PF_DLYD_B;

  // CLK5 p.172
  always_comb begin

    if (DIAG_READ) begin
      CLK.EBUSdriver.driving = 1;
      CLK.EBUSdriver.data = '0;

      case (EBUS.ds[4:6])
      3'b000: CLK.EBUSdriver.data = {CLK.EBUS_CLK,
                                     CLK.SBUS_CLK,
                                     CLK.INSTR_1777,
                                     burstCounter,
                                     burstCounter[0:1]};
      3'b001: CLK.EBUSdriver.data = burstCounter[2:7];
      3'b010: CLK.EBUSdriver.data = {CLK.ERROR_STOP,
                                     ~CLK.GO,
                                     CLK.EBOX_REQ,
                                     CLK.SYNC,
                                     CLK.PAGE_FAIL_EN,
                                     CLK.FORCE_1777};
      3'b011: CLK.EBUSdriver.data = {CLK.DRAM_PAR_ERR,
                                     ~BURST,
                                     CLK.MB_XFER,
                                     ~EBOX_CLK,
                                     CLK.PAGE_ERROR,
                                     CLK._1777_EN};
      3'b100: CLK.EBUSdriver.data = {CLK.CRAM_PAR_ERR,
                                     ~EBOX_SS,
                                     CLK.SOURCE_SEL[0],
                                     EBOX_SOURCE,
                                     ~FM_PAR_CHECK,
                                     CLK.MBOX_CYCLE_DIS};
      3'b101: CLK.EBUSdriver.data = {CLK.FM_PAR_ERR,
                                     SHM.AR_PAR_ODD,
                                     CLK.SOURCE_SEL[0],
                                     EBOX_CRM_DIS,
                                     ~CRAM_PAR_CHECK,
                                     ~MBOX_RESP_SIM};
      3'b110: CLK.EBUSdriver.data = {CLK.FS_ERROR,
                                     SHM.ARX_PAR_ODD,
                                     CLK.RATE_SEL[0],
                                     EBOX_EDP_DIS,
                                     ~DRAM_PAR_CHECK,
                                     ~AR_ARX_PAR_CHECK};
      3'b111: CLK.EBUSdriver.data = {~CLK.ERROR,
                                     CLK.PAGE_FAIL,
                                     CLK.RATE_SEL[1],
                                     EBOX_CTL_DIS,
                                     ~FS_CHECK,
                                     ~CLK.ERR_STOP_EN};
      endcase
    end else begin
      CLK.EBUSdriver.driving = 0;
      CLK.EBUSdriver.data[30:35] = 'z;
    end
  end

  bit [0:3] burstLSB;       // E21
  bit [0:3] burstMSB;       // E15
  bit burstLSBcarry;
  assign burstCounter = {burstMSB, burstLSB};
  assign BURST_CNTeq0 = burstCounter == '0;

  // NOTE: Active-low schematic symbol
  UCR4 e15(.CIN(burstLSBcarry),
           .SEL(~{BURST | CLK.FUNC_043, CLK.FUNC_043}),
           .D(EBUS.data[32:35]),
           .COUT(),
           .Q(burstMSB),
           .CLK(MAIN_SOURCE));

  // NOTE: Active-low schematic symbol
  UCR4 e21(.RESET(1'b0),
           .CIN(~BURST_CNTeq0),
           .SEL(~{CLK.FUNC_042 | RATE_SELECTED | BURST, CLK.FUNC_042}),
           .COUT(burstLSBcarry),
           .D(EBUS.data[32:35]),
           .Q(burstLSB),
           .CLK(MAIN_SOURCE));

  always_ff @(posedge MAIN_SOURCE) begin

    if (CLK.FUNC_044) begin
      CLK.SOURCE_SEL <= EBUS.data[32:33];
      CLK.RATE_SEL <= EBUS.data[34:35];
    end

    if (CLK.FUNC_045) begin
      EBOX_CRM_DIS <= EBUS.data[33];
      EBOX_EDP_DIS <= EBUS.data[34];
      EBOX_CTL_DIS <= EBUS.data[35];
    end

    if (CLK.FUNC_046) begin
      FM_PAR_CHECK <= EBUS.data[32];
      CRAM_PAR_CHECK <= EBUS.data[33];
      DRAM_PAR_CHECK <= EBUS.data[34];
      FS_CHECK <= EBUS.data[35];
    end

    if (CLK.FUNC_047) begin
      CLK.MBOX_CYCLE_DIS <= EBUS.data[32];
      MBOX_RESP_SIM <= EBUS.data[33];
      AR_ARX_PAR_CHECK <= EBUS.data[34];
      CLK.ERR_STOP_EN <= EBUS.data[35];
    end
  end
endmodule // clk
// Local Variables:
// verilog-library-files:("../ip/ebox_clocks/ebox_clocks_stub.v")
// End:
