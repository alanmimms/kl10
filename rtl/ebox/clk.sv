// PROBLEM: EBUS_CLK never starts running.

// PROBLEM: CLK.CRM stays high rather than pulsing.
`timescale 1ns/1ns
`include "ebox.svh"

// M8526 CLK
//
// HUGE thanks to Rich Alderson of Living Computers Museum for a
// gorgeous 600 DPI scan of the MP00301 p. 170 in which original scan
// was obscured in a few places.
module clk(input clk,
           input CROBAR,
           input EXTERNAL_CLK,
           input clk30,
           input clk31,

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

           iEBUS EBUS
           );

  logic DESKEW_CLK = '0;
  logic SYNCHRONIZE_CLK;
  assign SYNCHRONIZE_CLK = '0;
  logic DIAG_READ;
  logic MBOX_RESP_SIM;
  logic AR_ARX_PAR_CHECK;
  logic DIAG_CHANNEL_CLK_STOP = '0; // XXX used on CLK1. ??? where is this driven?

  logic [0:7] burstCounter;
  logic burstCounterEQ0;

`ifndef KL10PV_TB
  ebox_clocks ebox_clocks0(.clk_in1(clk));
`endif

  // XXX this is for sim but probably won't work in hardware.
  logic fastMemClk;
  assign fastMemClk = CLK.EDP;

  assign CLK.CROBAR = CROBAR;

  logic [4:6] DIAG;
  assign DIAG[4:6] = EBUS.ds[4:6];

  logic CLK_DIAG_READ;
  assign CLK_DIAG_READ = EDP.DIAG_READ_FUNC_10x;

  // CLK1 p.168

  mux e67(.en('1),
          .sel({CROBAR, CLK.SOURCE_SEL}),
          .d({clk30, clk31, EXTERNAL_CLK, {5{clk30}}}),
          .q(CLK.MAIN_SOURCE));

  assign CLK.ERROR_STOP = ~CLK.CLK_ON & CLK.ERR_STOP_EN & CLK.FS_ERROR |
                          CLK.EBOX_CLK_ERROR & CLK.EBOX_SOURCE & ~CLK.CLK_ON & CLK.ERR_STOP_EN;

  // XXX ignoring the delay lines
  logic latchedGatedEn;
  always_ff @(posedge CLK.MAIN_SOURCE) begin
    latchedGatedEn <= CLK.GATED_EN;
  end

  assign CLK.GATED = latchedGatedEn & CLK.MAIN_SOURCE;
  assign CLK.EBUS_CLK_SOURCE = CLK.GATED;           // 20ns delayed in KL
  assign CLK.SOURCE_DELAYED = CLK.EBUS_CLK_SOURCE;  // 20+{10,20,30,40,50}+{10,20,30,40,50}+2.5ns
  assign CLK.CLK_ON = (~CLK.ERROR_STOP | DESKEW_CLK) &
                      (CLK.SOURCE_DELAYED | DESKEW_CLK | CLK.GATED);

  assign CLK.MBOX = CLK.CLK_ON;
  assign CLK.ODD = CLK.CLK_ON;

  assign CLK.CCL = CLK.MBOX | DIAG_CHANNEL_CLK_STOP;
  assign CLK.CRC = CLK.MBOX | DIAG_CHANNEL_CLK_STOP;
  assign CLK.CHC = CLK.MBOX | DIAG_CHANNEL_CLK_STOP;
  assign CLK.MB_06 = CLK.MBOX | DIAG_CHANNEL_CLK_STOP;
  assign CLK.MB_12 = CLK.MBOX | DIAG_CHANNEL_CLK_STOP;
  assign CLK.CCW = CLK.MBOX | DIAG_CHANNEL_CLK_STOP;

  assign CLK.MB_00 = CLK.MBOX;
  assign CLK.MBC = CLK.MBOX;
  assign CLK.MBX = CLK.MBOX;
  assign CLK.MBZ = CLK.MBOX;
  assign CLK.MBOX_13 = CLK.MBOX;
  assign CLK.MBOX_14 = CLK.MBOX;
  assign CLK.MTR = CLK.MBOX;
  assign CLK.CLK_OUT = CLK.MBOX;
  assign CLK.PI = CLK.MBOX;
  assign CLK.PMA = CLK.MBOX;
  assign CLK.CHX = CLK.MBOX;
  assign CLK.CSH = CLK.MBOX;

  logic [0:3] rateSelSR;
  assign CLK.RATE_SELECTED = ~(rateSelSR[0] | rateSelSR[2]);
  
  USR4 e5(.RESET('0),
          .S0('0),
          .D({CLK.RATE_SEL[0], CLK.RATE_SEL[0], CLK.RATE_SEL[1], 1'b0}),
          .S3('0),
          .SEL({~CLK.RATE_SELECTED, 1'b0}),
          .CLK(CLK.MAIN_SOURCE),
          .Q(rateSelSR));

  logic sbusClkFF1, sbusClkFF2;
  assign CLK.SBUS_CLK = sbusClkFF2;
  always @(posedge CLK.GATED, posedge CLK.FUNC_CLR_RESET) begin

    if (CLK.FUNC_CLR_RESET) begin
      CLK.SBUS_CLK <= '0;
      sbusClkFF1 <= '0;
      sbusClkFF2 <= '0;
    end else begin
      sbusClkFF1 <= ~sbusClkFF2; // XXX slashed wire in schematics
      sbusClkFF2 <= sbusClkFF1;
    end
  end

  logic ebusClkFF;
  assign CLK.EBUS_CLK = ebusClkFF;
  always @(posedge CLK.EBUS_CLK_SOURCE, posedge CLK.FUNC_CLR_RESET) begin

    if (CLK.FUNC_CLR_RESET) begin
      ebusClkFF <= '0;
    end else begin
      ebusClkFF <= sbusClkFF1;
    end
  end

  logic [0:3] gatedSR;
  USR4 e42(.S0('0),
           .D({CLK.FUNC_SINGLE_STEP,
               CLK.FUNC_EBOX_SS,
               CLK.FUNC_EBOX_SS & ~CLK.SYNC,
               CLK.FUNC_EBOX_SS}),
           .S3(CROBAR),
           .CLK(CLK.MAIN_SOURCE),
           .SEL({CLK.FUNC_GATE, CLK.FUNC_GATE | CLK.RATE_SELECTED}),
           .Q(gatedSR));

  assign CLK.GATED_EN = CLK.GO & CLK.RATE_SELECTED |
                        ~burstCounterEQ0 & CLK.BURST & CLK.RATE_SELECTED |
                        gatedSR[0] & CLK.RATE_SELECTED |
                        CLK.FUNC_COND_SS & CLK.EBOX_CLK;

  // CLK2 p.169
  logic [0:3] e64SR;
  logic [0:3] e60FF;
  assign CLK.MHZ16_FREE = e64SR[3];

  USR4 e64(.RESET('0),
           .S0('0),
           .D({e64SR[0:1], ~(CTL.DIAG_CTL_FUNC_00x | CTL.DIAG_LD_FUNC_04x), 1'b1}),
           .S3(1'b0),
           .SEL({CLK.MHZ16_FREE, 1'b0}),
           .CLK(CLK.MAIN_SOURCE),
           .Q(e64SR));

  // XXX slashed wire
  assign CLK.FUNC_GATE = ~|e60FF[0:2];
  assign CLK.TENELEVEN_CLK = e60FF[3];
  always_ff @(posedge CLK.MAIN_SOURCE) begin
    // XXX slashed wire
    e60FF <= {~e64SR[0], e64SR[1:3]};
  end

  logic e66SRFF;
  always @(posedge ~CLK.FUNC_SET_RESET,
           posedge CLK.FUNC_CLR_RESET,
           posedge CROBAR)
  begin

    if (CROBAR) begin                       // CLEAR
      e66SRFF <= '0;
    end else if (CLK.FUNC_CLR_RESET) begin  // PRESET
      e66SRFF <= '1;
    end else if (!CLK.FUNC_SET_RESET) begin // LOAD (0)
      e66SRFF <= '0;
    end
  end
  assign CLK.MR_RESET = CLK.RESET;
  assign CLK.RESET = e66SRFF;
  assign CLK.SYNC_HOLD = CLK.MR_RESET | CLK.SYNC;

  // In real KL, CLK.CLK is routed to far end of backplane and back as
  // CLK.DELAYED according to EBOX-UD Logical Delays and Skew, Figure
  // 3-25. In KL10B this signal is called CLK.CLK when it leaves the
  // CLK board (see CLK1 A1 E72 pin 3).
  assign CLK.CLK = CLK.MBOX;
  assign CLK.DELAYED = CLK.CLK;
  assign CLK.MBOX_CLK = CLK.DELAYED;

  logic eboxClkFF;
  always_ff @(posedge CLK.MBOX_CLK) begin
    eboxClkFF <= CLK.EBOX_CLK;
  end
  assign CLK.PT_DIR_WR = eboxClkFF & APR.PT_DIR_WR;
  assign CLK.PT_WR = eboxClkFF & APR.PT_WR;

  logic [0:3] e52Count;
  logic e52COUT;
  assign CLK.EBUS_RESET = e52Count[0];

  UCR4 e52(.RESET('0),
           .CIN('1),            // Always count
           .SEL({1'b0, ~e52COUT | CROBAR | CON.CONO_200000}),
           .CLK(CLK.MHZ16_FREE),
           .D('0),
           .COUT(e52COUT),
           .Q(e52Count));

  logic ignoredE37;
  USR4 e37(.RESET('0),
           .S0('0),
           .D({CLK.FUNC_START, CLK.FUNC_BURST, CLK.FUNC_EBOX_SS, 1'b0}),
           .S3('0),
           .SEL({2{CLK.FUNC_GATE | CROBAR}}),
           .CLK(CLK.MAIN_SOURCE),
           .Q({CLK.GO, CLK.BURST, CLK.EBOX_SS, ignoredE37}));
  
  logic e47Ignore;
  decoder e47Decoder(.en(CLK.FUNC_GATE & CTL.DIAG_CTL_FUNC_00x),
                     .sel(DIAG[4:6]),
                     .q({e47Ignore, CLK.FUNC_START,
                         CLK.FUNC_SINGLE_STEP, CLK.FUNC_EBOX_SS,
                         CLK.FUNC_COND_SS, CLK.FUNC_BURST,
                         CLK.FUNC_CLR_RESET, CLK.FUNC_SET_RESET}));
  logic [0:7] e50out;
  assign CLK.FUNC_042 = e50out[2];
  assign CLK.FUNC_043 = e50out[3];
  assign CLK.FUNC_044 = e50out[4] | CROBAR;
  assign CLK.FUNC_045 = e50out[5] | CROBAR;
  assign CLK.FUNC_046 = e50out[6] | CROBAR;
  assign CLK.FUNC_047 = e50out[7] | CROBAR;
  decoder e50Decoder(.en(CLK.FUNC_GATE & CTL.DIAG_LD_FUNC_04x),
                     .sel(DIAG[4:6]),
                     .q(e50out));

  // CLK3 p.170
  logic [0:5] e58FF;
  assign {CLK.DRAM_PAR_ERR, CLK.CRAM_PAR_ERR, CLK.FM_PAR_ERR,
          CLK.EBOX_SOURCE, CLK.FS_ERROR, CLK.EBOX_CLK_ERROR} = e58FF;

  logic e45FF4, e45FF13, e45FF14;
  assign CLK.ERROR_HOLD_A = ~IR.DRAM_ODD_PARITY & ~CON.LOAD_DRAM & CLK.DRAM_PAR_CHECK;
  // XXX these CLK.FS_EN_xxx are only initialized in kl10pv_tb
  assign CLK.ERROR_HOLD_B = (CLK.FS_EN_A | CLK.FS_EN_B | CLK.FS_EN_C | CLK.FS_EN_D) &
                            CLK.FS_EN_E & CLK.FS_EN_F & CLK.FS_EN_G & CLK.FS_CHECK;
  assign CLK.ERROR = e45FF4 | e45FF13;
  assign CLK.FS_ERROR = ~e45FF14;
  always_ff @(posedge CLK.ODD) begin
    e58FF <= {CLK.ERROR_HOLD_A,
              ~CRM.PAR_16 & CLK.CRAM_PAR_CHECK,
              ~APR.FM_ODD_PARITY & CLK.FM_PAR_CHECK,
              CLK.EBOX_SRC_EN,
              ~CLK.ERROR_HOLD_B,
              CLK.ERROR_HOLD_A};

    e45FF4 <= CLK.ERROR_HOLD_B;
    e45FF13 <= CLK.ERROR_HOLD_A;
    e45FF14 <= ~CLK.ERROR_HOLD_B;
  end

  logic [0:3] e25Count;
  logic e25COUT;
  UCR4 e25(.RESET('0),
           .CIN('1),
           .SEL({CLK.EBOX_CLK_EN, 1'b0}),
           .CLK(CLK.MBOX_CLK),
           .D(4'b0000),
           .COUT(e25COUT),
           .Q(e25Count));

  logic e31B;
  mux e31(.en(~CLK.SYNC_HOLD),
          .sel({|e25Count[0:1], e25Count[2:3]}),
          .d({CRAM._TIME[0] | CRAM._TIME[1], // DeMorgan E26 pin 7
              ~CRAM._TIME[0], ~CRAM._TIME[1], ~CON.DELAY_REQ, {4{~e25COUT}}}),
          .q(e31B));

  always_comb begin
    CLK.SYNC_EN = CLK.EBOX_SS & ~CLK.EBOX_CLK_EN | e31B & ~CLK.EBOX_CLK_EN;
  end

  logic e10FF;                  // Merged into single FF
  assign CLK.EBOX_SYNC = e10FF;
  assign CLK.SYNC = e10FF;      // XXX slashed signals

  always_ff @(posedge CLK.MBOX_CLK) begin
    e10FF <= CLK.SYNC_EN;       // XXX slashed signals
  end

  logic notHoldAB;
  logic [0:3] e12SR;
  logic e17out;
  assign notHoldAB = ~CLK.ERROR_HOLD_A & ~CLK.ERROR_HOLD_B;
  assign e17out = ~CON.MBOX_WAIT | CLK.RESP_MBOX | VMA.AC_REF | CLK.EBOX_SS | CLK.RESET;

  USR4 e12(.RESET('0),
           .S0(CLK.PF_DLYD_A),
           .D({CLK.SYNC & e17out & notHoldAB & ~CLK.EBOX_CRM_DIS,
               CLK.SYNC & e17out & notHoldAB & ~CLK.EBOX_EDP_DIS,
               CLK.SYNC & e17out & notHoldAB & ~CLK.EBOX_CTL_DIS,
               CLK.EBOX_SRC_EN}),
           .S3(1'b0),
           .SEL({CLK.PAGE_FAIL, CLK.PF_DLYD_A}),
           .CLK(CLK.ODD),
           .Q(e12SR));
           

  assign CLK.EBOX_SRC_EN = CLK.SYNC & e17out;
  assign CLK.EBOX_CLK_EN = CLK.EBOX_SRC_EN | CLK._1777_EN;

  assign CLK.CRM = e12SR[0];
  assign CLK.CRA = e12SR[0];
  assign CLK.EDP = CTL.DIAG_CLK_EDP | e12SR[1];
  assign CLK.APR = e12SR[2];
  assign CLK.CON = e12SR[2];
  assign CLK.VMA = e12SR[2];
  assign CLK.MCL = e12SR[2];
  assign CLK.IR  = e12SR[2];
  assign CLK.SCD = e12SR[2];
  assign CLK.EBOX_SOURCE = e12SR[3];

  // CLK4 p.171
  logic e32Q3, e32Q13;
  assign CLK.MBOX_RESP = e32Q3 | e32Q13;
  assign CLK.MB_XFER = e32Q3 | e32Q13;
  assign CLK.RESP_SIM = CSH.MBOX_RESP_IN & CLK.SYNC_EN;
  always_ff @(posedge CLK.MBOX_CLK) begin
    CLK.EBOX_REQ <= CLK.EBOX_REQ & ~VMA.AC_REF |
                    ~VMA.AC_REF & CSH.EBOX_RETRY_REQ |
                    CLK.SYNC_EN & MCL.MBOX_CYC_REQ |
                    CLK.SYNC & MCL.MBOX_CYC_REQ |
                    (~CLK.PAGE_FAIL_EN &
                     ~CSH.EBOX_T0_IN &
                     ~CLK.MBOX_CYCLE_DIS &
                     ~CLK.MR_RESET &
                     ~CLK.FORCE_1777);

    e32Q3 <= CON.MBOX_WAIT & MBOX_RESP_SIM & ~CLK.EBOX_CLK_EN & ~VMA.AC_REF;
    e32Q13 <= CSH.MBOX_RESP_IN;
    CLK.EBOX_CLK <= CLK.EBOX_CLK_EN;
  end

  USR4 e30(.RESET('0),
           .S0('0),
           .D({PAG.PF_EBOX_HANDLE,
               CON.AR_FROM_EBUS | CLK.PAGE_FAIL_EN,
               ~SHM.AR_PAR_ODD & CON.AR_LOADED,
               ~SHM.ARX_PAR_ODD & CON.ARX_LOADED}),
           .S3('0),
           .SEL({2{CLK.PAGE_FAIL}}),
           .CLK(CLK.ODD),
           .Q(CLK.PF_DISP[7:10]));

  always @(posedge CLK.ODD) begin
    CLK.PF_DLYD_A <= CLK.PAGE_FAIL;
    CLK.PF_DLYD_B <= CLK.PF_DLYD_A;
  end

  initial CLK.PAGE_FAIL_EN = '0;
  initial CLK.FORCE_1777 = '0;
  initial CLK.INSTR_1777 = '0;
  initial CLK.SBR_CALL = '0;

  assign CLK.PAGE_ERROR = CLK.PAGE_FAIL_EN | CLK.INSTR_1777;
  assign CLK._1777_EN = CLK.FORCE_1777 & CLK.SBR_CALL;
  always @(posedge CLK.MBOX_CLK) begin
    CLK.PAGE_FAIL_EN <= ~CLK.INSTR_1777 &
                        (CSH.PAGE_FAIL_HOLD | (CLK.PAGE_FAIL_EN & ~CLK.MR_RESET));
    CLK.INSTR_1777 <= CLK._1777_EN | (~CLK.EBOX_CLK_EN & CLK.INSTR_1777);
    CLK.FORCE_1777 <= CLK.PF_DLYD_A;
    CLK.SBR_CALL <= CLK.PF_DLYD_B;
  end

  logic e7out7;                 // XXX slashed
  logic e38out7;                // XXX slashed
  assign e7out7 = CLK.EBOX_SOURCE | CLK.PF_DLYD_B | CLK.INSTR_1777;
  assign e38out7 = ~APR.APR_PAR_CHK_EN | ~AR_ARX_PAR_CHECK | e7out7;
  assign CLK.PAGE_FAIL = APR.SET_PAGE_FAIL & e7out7 |
                         ~SHM.AR_PAR_ODD & CON.AR_LOADED & e38out7 |
                         ~SHM.ARX_PAR_ODD & CON.ARX_LOADED & e38out7 |
                         CRAM.MEM[2] & CLK.PAGE_FAIL_EN & e7out7;
  assign CLK.EBOX_CYC_ABORT = CLK.PAGE_FAIL | CLK.PF_DLYD_B;

  // CLK5 p.172
  always_comb begin

    if (CLK_DIAG_READ) begin
      CLK.EBUSdriver.driving = '1;
      CLK.EBUSdriver.data = '0;

      case (DIAG[4:6])
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
                                     ~CLK.BURST,
                                     CLK.MB_XFER,
                                     ~CLK.EBOX_CLK,
                                     CLK.PAGE_ERROR,
                                     CLK._1777_EN};
      3'b100: CLK.EBUSdriver.data = {CLK.CRAM_PAR_ERR,
                                     ~CLK.EBOX_SS,
                                     CLK.SOURCE_SEL[0],
                                     CLK.EBOX_SOURCE,
                                     ~CLK.FM_PAR_CHECK,
                                     CLK.MBOX_CYCLE_DIS};
      3'b101: CLK.EBUSdriver.data = {CLK.FM_PAR_ERR,
                                     SHM.AR_PAR_ODD,
                                     CLK.SOURCE_SEL[0],
                                     CLK.EBOX_CRM_DIS,
                                     ~CLK.CRAM_PAR_CHECK,
                                     ~MBOX_RESP_SIM};
      3'b110: CLK.EBUSdriver.data = {CLK.FS_ERROR,
                                     SHM.ARX_PAR_ODD,
                                     CLK.RATE_SEL[0],
                                     CLK.EBOX_EDP_DIS,
                                     ~CLK.DRAM_PAR_CHECK,
                                     ~AR_ARX_PAR_CHECK};
      3'b111: CLK.EBUSdriver.data = {~CLK.ERROR,
                                     CLK.PAGE_FAIL,
                                     CLK.RATE_SEL[1],
                                     CLK.EBOX_CTL_DIS,
                                     ~CLK.FS_CHECK,
                                     ~CLK.ERR_STOP_EN};
      endcase
    end else begin
      CLK.EBUSdriver.driving = '0;
      CLK.EBUSdriver.data[30:35] = 'z;
    end
  end

  logic [0:3] burstLSB;       // E21
  logic [0:3] burstMSB;       // E15
  logic burstLSBcarry;

  assign burstCounter = {burstMSB, burstLSB};
  assign burstCounterEQ0 = burstCounter == '0;

  UCR4 e15(.RESET('0),
           .CIN(burstLSBCarry),
           .SEL({CLK.BURST | CLK.FUNC_043, CLK.FUNC_043}),
           .D(EBUS.data[32:35]),
           .COUT(),
           .Q(burstMSB),
           .CLK(CLK.MAIN_SOURCE));

  UCR4 e21(.RESET('0),
           .CIN(~burstCounterEQ0),
           .SEL({CLK.FUNC_042 | CLK.RATE_SELECTED | CLK.BURST, CLK.FUNC_042}),
           .COUT(burstLSBcarry),
           .D(EBUS.data[32:35]),
           .Q(burstLSB),
           .CLK(CLK.MAIN_SOURCE));

  always_ff @(posedge CLK.MAIN_SOURCE) begin

    if (CLK.FUNC_044) begin
      CLK.SOURCE_SEL <= EBUS.data[32:33];
      CLK.RATE_SEL <= EBUS.data[34:35];
    end

    if (CLK.FUNC_045) begin
      CLK.EBOX_CRM_DIS <= EBUS.data[33];
      CLK.EBOX_EDP_DIS <= EBUS.data[34];
      CLK.EBOX_CTL_DIS <= EBUS.data[35];
    end

    if (CLK.FUNC_046) begin
      CLK.FM_PAR_CHECK = EBUS.data[32];
      CLK.CRAM_PAR_CHECK = EBUS.data[33];
      CLK.DRAM_PAR_CHECK = EBUS.data[34];
      CLK.FS_CHECK = EBUS.data[35];
    end

    if (CLK.FUNC_047) begin
      CLK.MBOX_CYCLE_DIS = EBUS.data[32];
      MBOX_RESP_SIM = EBUS.data[33];
      AR_ARX_PAR_CHECK = EBUS.data[34];
      CLK.ERR_STOP_EN = EBUS.data[35];
    end
  end
endmodule // clk
// Local Variables:
// verilog-library-files:("../ip/ebox_clocks/ebox_clocks_stub.v")
// End:
