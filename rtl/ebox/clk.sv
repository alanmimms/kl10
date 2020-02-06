// PROBLEM: CLK.GATED_EN is false because CLK.GO & CLK.RATE_SELECTED are both 0.

`timescale 1ns/1ns
`include "ebox.svh"

// M8526 CLK
//
// HUGE thanks to Rich Alderson of Living Computers Museum for a
// gorgeous 600 DPI scan of the MP00301 p. 170 in which original scan
// was obscured in a few places.
module clk(input clk,
           input FPGA_RESET,
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
  logic SYNCHRONIZE_CLK = '0;
  logic DIAG_READ;
  logic MBOX_RESP_SIM;
  logic AR_ARX_PAR_CHECK;

  logic [0:7] burstCounter;
  logic burstCounterEQ0;

  logic RESET;
  assign RESET = CLK.MR_RESET;
  assign CLK.EBOX_RESET = CLK.MR_RESET;

  ebox_clocks ebox_clocks0(.clk_in1(clk));

  // XXX this is for sim but probably won't work in hardware.
  logic fastMemClk;
  assign fastMemClk = CLK.EDP;

  logic [4:6] DIAG;
  assign DIAG[4:6] = EBUS.ds[4:6];

  logic CLK_DIAG_READ;
  assign CLK_DIAG_READ = EDP.DIAG_READ_FUNC_10x;

  // CLK1 p.168
  always_comb begin

    case ({CROBAR, CLK.SOURCE_SEL})
    default:CLK.MAIN_SOURCE = clk30;
    3'b001: CLK.MAIN_SOURCE = clk31;
    3'b010: CLK.MAIN_SOURCE = EXTERNAL_CLK;
    3'b011: CLK.MAIN_SOURCE = clk31;
    endcase

    CLK.ERROR_STOP = CLK.FS_ERROR & ~CLK.CLK_ON & CLK.ERR_STOP_EN |
                     CLK.EBOX_CLK_ERROR & CLK.EBOX_SOURCE & ~CLK.CLK_ON & CLK.ERR_STOP_EN;
  end

  // XXX ignoring the delay lines
  logic latchedGatedEn;
  assign CLK.GATED = latchedGatedEn & CLK.MAIN_SOURCE;
  assign CLK.EBUS_CLK_SOURCE = CLK.GATED;
  assign CLK.SOURCE_DELAYED = CLK.EBUS_CLK_SOURCE;
  assign CLK.CLK_ON = (~CLK.ERROR_STOP | DESKEW_CLK) &
                      (CLK.SOURCE_DELAYED | DESKEW_CLK | CLK.GATED);

  always_ff @(posedge CLK.MAIN_SOURCE) begin
    latchedGatedEn <= CLK.GATED_EN;
  end

  assign CLK.MBOX_CLK = CLK.CLK_ON;
  assign CLK.ODD = CLK.CLK_ON;

  logic [0:3] rateSelectorSR;
  assign CLK.RATE_SELECTED = rateSelectorSR[0] | rateSelectorSR[2];
  always_ff @(posedge CLK.MAIN_SOURCE) begin

    if (~CLK.RATE_SELECTED) begin       // SHIFT 3in (0)
      rateSelectorSR <= {rateSelectorSR[1:3], 1'b0};
    end else begin                      // LOAD
      rateSelectorSR <= {CLK.RATE_SEL[0], CLK.RATE_SEL[0], CLK.RATE_SEL[1], 1'b0};
    end
  end

  logic ebusClkIn;
  always @(posedge CLK.GATED) begin

    if (CLK.FUNC_CLR_RESET) begin
      CLK.SBUS_CLK <= '0;
      ebusClkIn <= '0;
    end else begin
      CLK.SBUS_CLK <= ebusClkIn;
      ebusClkIn <= CLK.SBUS_CLK;
    end
  end

  always @(posedge CLK.EBUS_CLK_SOURCE) begin

    if (CLK.FUNC_CLR_RESET) begin
      CLK.EBUS_CLK <= '0;
    end else begin
      CLK.EBUS_CLK <= ebusClkIn;
    end
  end

  logic [0:3] gatedSR;
  always @(posedge CLK.MAIN_SOURCE) begin

    case ({CLK.FUNC_GATE, CLK.FUNC_GATE | CLK.RATE_SELECTED})
    default: gatedSR <= gatedSR;
    2'b01: gatedSR <= {gatedSR[1:3], CROBAR};
    2'b10: gatedSR <= {1'b0, gatedSR[0:2]};
    3'b11: gatedSR <= {CLK.FUNC_SINGLE_STEP,
                       CLK.FUNC_EBOX_SS,
                       CLK.FUNC_EBOX_SS & ~CLK.SYNC,
                       CLK.FUNC_EBOX_SS};
    endcase
  end

  assign CLK.GATED_EN = CLK.GO & CLK.RATE_SELECTED |
                        burstCounterEQ0 & CLK.BURST & CLK.RATE_SELECTED |
                        CLK.RATE_SELECTED & gatedSR[0] |
                        CLK.FUNC_COND_SS & CLK.EBOX_CLK;

  // CLK2 p.169
  logic [0:3] e64SR;
  logic [0:3] e60FF;
  assign CLK.MHZ16_FREE = e64SR[3];
  assign CLK.FUNC_GATE = |e60FF[0:2];
  assign CLK.TENELEVEN_CLK = e60FF[3];

  always_ff @(posedge CLK.MAIN_SOURCE) begin

    if (CLK.MHZ16_FREE) begin
      e64SR <= {e64SR[1:3], SYNCHRONIZE_CLK};
    end else begin
      e64SR <= {e64SR[0:1], CTL.DIAG_CTL_FUNC_00x | CTL.DIAG_LD_FUNC_04x, 1'b1};
    end

    e60FF <= {e64SR[0], e64SR[1:3]};
  end

  assign CLK.SYNC_HOLD = CLK.MR_RESET | CLK.SYNC;
  always @(posedge CLK.MHZ16_FREE) begin // Changed from async set/reset to synchronous

    if (CLK.FUNC_CLR_RESET) begin
      CLK.MR_RESET <= '0;
    end else if (CROBAR) begin
      CLK.MR_RESET <= '1;
    end else if (CLK.FUNC_SET_RESET) begin
      CLK.MR_RESET <= '1;
    end
  end

  always_ff @(posedge CLK.MBOX_CLK) begin
    CLK.PT_DIR_WR <= CLK.EBOX_CLK & APR.PT_DIR_WR;
    CLK.PT_WR <= CLK.EBOX_CLK & APR.PT_WR;
  end

  logic [0:3] e52Counter;
  logic e52COUT;
  assign CLK.EBUS_RESET = e52Counter[0];
  always @(posedge CLK.MHZ16_FREE) begin
    
    if (FPGA_RESET) begin
      e52Counter <= '0;
      e52COUT <= '0;
    end else if (e52COUT | CROBAR | CON.CONO_200000) begin

      if (|e52Counter == '0) begin
        e52COUT <= '1;
        e52Counter <= '1;
      end else begin
        e52Counter <= e52Counter - 1;
      end
    end
  end

  always_ff @(posedge CLK.MAIN_SOURCE iff CLK.FUNC_GATE | CROBAR) begin
    CLK.GO <= CLK.FUNC_START;
    CLK.BURST <= CLK.FUNC_BURST;
    CLK.EBOX_SS <= CLK.FUNC_EBOX_SS;
  end

  logic e47xx;
  decoder e47Decoder(.en(CLK.FUNC_GATE & CTL.DIAG_CTL_FUNC_00x),
                     .sel(DIAG[4:6]),
                     .q({e47xx, CLK.FUNC_START, CLK.FUNC_SINGLE_STEP, CLK.FUNC_EBOX_SS,
                         CLK.FUNC_COND_SS, CLK.FUNC_BURST, CLK.FUNC_CLR_RESET,
                         CLK.FUNC_SET_RESET}));
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
  assign CLK.ERROR_HOLD_B = (CLK.FS_EN_A | CLK.FS_EN_B | CLK.FS_EN_C | CLK.FS_EN_D) &
                            CLK.FS_EN_E & CLK.FS_EN_F & CLK.FS_EN_G & CLK.FS_CHECK;
  assign CLK.ERROR = e45FF4 | e45FF13;
  assign CLK.FS_ERROR = ~e45FF14;
  always_ff @(posedge CLK.ODD) begin
    e58FF <= {CLK.ERROR_HOLD,
              ~CRM.PAR_16 & CLK.CRAM_PAR_CHECK,
              ~APR.FM_ODD_PARITY & CLK.FM_PAR_CHECK,
              CLK.EBOX_SRC_EN,
              ~CLK.ERROR_HOLD,
              CLK.ERROR_HOLD};

    e45FF4 <= CLK.ERROR_HOLD_B;
    e45FF13 <= CLK.ERROR_HOLD_A;
    e45FF14 <= CLK.ERROR_HOLD_B;
  end

  logic [3:0] e25Counter;
  logic e25COUT;
  always_ff @(posedge CLK.MBOX_CLK) begin

    if (CLK.EBOX_CLK_EN) begin

      if (&e25Counter) begin
        e25COUT <= '1;
        e25Counter <= '0;
      end else begin
        e25Counter <= e25Counter - 1;
      end
    end else begin
      e25Counter <= '0;
      e25COUT <= '0;
    end
  end

  logic e31B;
  always_comb begin

    if (CLK.SYNC_HOLD) begin

      case ({|e25Counter[3:2], e25Counter[1:0]})
      3'b000: e31B = ~(~CRAM._TIME[0] & ~CRAM._TIME[1]);
      3'b001: e31B = ~CRAM._TIME[0];
      3'b010: e31B = ~CRAM._TIME[1];
      3'b011: e31B = ~CON.DELAY_REQ;
      3'b100: e31B = e25COUT;
      3'b101: e31B = e25COUT;
      3'b110: e31B = e25COUT;
      3'b111: e31B = e25COUT;
      endcase
    end else begin
      e31B = '0;
    end

    CLK.SYNC_EN = CLK.EBOX_SS & ~CLK.EBOX_CLK_EN | e31B & ~CLK.EBOX_CLK_EN;
  end

  logic [0:1] e10FF;            // D0..D4 merged into one
  assign CLK.EBOX_SYNC = e10FF[0];
  assign CLK.SYNC = |e10FF;

  always_ff @(posedge CLK.MBOX_CLK) begin
    e10FF <= {CLK.SYNC_EN, ~CLK.SYNC_EN};
  end


  logic [0:3] e12SR;
  logic e17out;
  assign e17out = ~CON.MBOX_WAIT | CLK.RESP_MBOX | VMA.AC_REF | CLK.EBOX_SS | RESET;
  assign CLK.EBOX_CLK_EN = CLK.EBOX_SRC_EN | CLK.F1777_EN;
  assign CLK.EBOX_SRC_EN = CLK.SYNC & e17out;

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

  logic holdAB;
  assign holdAB = ~CLK.ERROR_HOLD_A & ~CLK.ERROR_HOLD_B;

  always_ff @(posedge CLK.ODD) begin
    
    if (CLK.PAGE_FAIL && CLK.PF_DLYD) begin // HOLD
      e12SR <= e12SR;
    end else if (CLK.PAGE_FAIL) begin   // Shift up from 3in (0)
      e12SR <= {e12SR[1:3], 1'b0};
    end else if (CLK.PF_DLYD) begin     // Shift down from 0in
      e12SR <= {CLK.PF_DLYD, e12SR[0:2]};
    end else begin                      // LOAD
      e12SR <= {CLK.SYNC & e17out & holdAB & ~CLK.EBOX_CRM_DIS,
                CLK.SYNC & e17out & holdAB & ~CLK.EBOX_EDP_DIS,
                CLK.SYNC & e17out & holdAB & ~CLK.EBOX_CTL_DIS,
                CLK.EBOX_SRC_EN};
    end
  end

  // p.171
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

  always_ff @(posedge CLK.ODD) begin

    if (CLK.PAGE_FAIL) begin
      CLK.PF_DISP[7] <= PAG.PF_EBOX_HANDLE;
      CLK.PF_DISP[8] <= CON.AR_FROM_EBUS | CLK.PAGE_FAIL_EN;
      CLK.PF_DISP[9] <= ~SHM.AR_PAR_ODD & CON.AR_LOADED;
      CLK.PF_DISP[10] <= ~SHM.ARX_PAR_ODD & CON.ARX_LOADED;
    end else begin
      CLK.PF_DISP <= CLK.PF_DISP;
    end
  end

  always @(posedge CLK.ODD) begin
    CLK.PF_DLYD_A <= CLK.PAGE_FAIL;
    CLK.PF_DLYD_B <= CLK.PF_DLYD_A;
  end

  assign CLK.PAGE_ERROR = CLK.PAGE_FAIL_EN | CLK.INSTR_1777;
  assign CLK.F1777_EN = CLK.FORCE_1777 & CLK.SBR_CALL;
  always @(posedge CLK.MBOX_CLK) begin
    CLK.PAGE_FAIL_EN <= ~CLK.INSTR_1777 &
                        (CSH.PAGE_FAIL_HOLD | (CLK.PAGE_FAIL_EN & ~CLK.MR_RESET));
    CLK.INSTR_1777 <= CLK.F1777_EN | (~CLK.EBOX_CLK_EN & CLK.INSTR_1777);
    CLK.FORCE_1777 <= CLK.PF_DLYD_A;
    CLK.SBR_CALL <= CLK.PF_DLYD_B;
  end

  logic e7out7;
  logic e38out6;
  assign e7out7 = CLK.EBOX_SOURCE | CLK.PF_DLYD_B | CLK.INSTR_1777;
  assign e38out6 = ~APR.APR_PAR_CHK_EN | ~AR_ARX_PAR_CHECK | e7out7;
  assign CLK.PAGE_FAIL = APR.SET_PAGE_FAIL & e7out7 |
                         ~SHM.AR_PAR_ODD & CON.AR_LOADED & e38out6 |
                         ~SHM.ARX_PAR_ODD & CON.ARX_LOADED & e38out6 |
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
                                     CLK.F1777_EN};
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
  assign burstCounterEQ0 = burstCounter == 8'b0;

  always_ff @(posedge CLK.MAIN_SOURCE) begin

    // LSB
    if (CLK.FUNC_042) begin // LOAD 042
      burstLSB <= EBUS.data[32:35];
      burstLSBcarry <= '0;
    end else if (CLK.BURST || CLK.RATE_SELECTED || CLK.FUNC_042) begin
      burstLSBcarry <= burstLSB == 4'b1111; // INCREMENT
      if (~burstCounterEQ0) burstLSB <= burstLSB + 4'b0001;
    end else begin                   // HOLD
      burstLSB <= burstLSB;
      burstLSBcarry <= '0;
    end

    // MSB
    if (CLK.BURST) begin             // INCREMENT
      if (burstLSBcarry) burstMSB <= burstMSB + 4'b0001;
    end else if (CLK.FUNC_043) begin // LOAD 043
      burstMSB[0:3] <= EBUS.data[32:35];
    end else begin                   // HOLD
      burstMSB <= burstMSB;
    end
  end

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
