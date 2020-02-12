`timescale 1ns/1ns
`include "ebox.svh"
`include "mbox.svh"
// M8545 APR
module apr(iAPR APR,
           iEDP EDP,
           iEBUS EBUS,
           input PWR_WARN,
           input PWR_FAIL
           );

  logic clk;
  logic RESET;
  logic [4:6] DIAG;

  assign clk = CLK.APR;

module IntEnabler(input clk,
                  input m,
                  output logic e,
                  output logic i);
  always_comb
    e = CON.SEL_EN & EBUS.data[m] |
        i & ~RESET & CON.SEL_DIS & EBUS.data[m];
  always_ff @(posedge clk)
    e <= i;
endmodule

module Event(input clk,
             input m,
             input o,
             output logic e,
             output logic i);
  always_comb
    i = CON.SEL_SET & EBUS.data[m] |
        ~CON.SEL_CLR & e & ~RESET |
        e & ~EBUS.data[m] & ~RESET |
        o;
  always_ff @(posedge clk)
    e <= i;
endmodule


  logic SBUS_ERR_IN, SBUS_ERR_IN_EN;
  logic NXM_ERR_INT_EN, NXM_ERR_EN_IN;
  logic IO_PF_ERR_INT_EN, IO_PF_ERR_EN_IN;
  logic MB_PAR_ERR_INT_EN, MB_PAR_ERR_EN_IN;
  logic IO_PF_ERR, IO_PF_ERR_IN;
  logic NXM_ERR, NXM_ERR_IN;
  logic SWEEP_BUSY_EN, SWEEP_BUSY;
  logic C_DIR_P_ERR_INT_EN, C_DIR_P_ERR_EN_IN;
  logic S_ADR_P_ERR_INT_EN, S_ADR_P_ERR_EN_IN;
  logic PWR_FAIL_INT_EN, PWR_FAIL_EN_IN;
  logic SWEEP_DONE_INT_EN, SWEEP_DONE_EN_IN;
  logic SWEEP_DONE, SWEEP_DONE_IN;
  logic F02_EN;

  assign clk = CLK.APR;
  assign APR.EBUSdriver.driving = '0;       // XXX temporary

  // APR1 p.382
  IntEnabler sbusInt(clk, 6, SBUS_ERR_INT_EN, SBUS_ERR_EN_IN);
  Event sbusErr(clk, 6, MBOX.SBUS_ERR, SBUS_ERR_EN, SBUS_ERR_IN);

  IntEnabler nxmInt(clk, 7, NXM_ERR_INT_EN, NXM_ERR_EN_IN);
  Event nxmErr(clk, 7, MBOX.NXM_ERR, NXM_ERR_EN, NXM_ERR_IN);

  IntEnabler iopfInt(clk, 8, IO_PF_ERR_INT_EN, IO_PF_ERR_EN_IN);
  Event iopfErr(clk, 8, APR.SET_IO_PF_ERR, IO_PF_ERR_EN, IO_PF_ERR_IN);

  IntEnabler mbParInt(clk, 9, MB_PAR_ERR_INT_EN, MB_PAR_ERR_EN_IN);
  Event mbParErr(clk, 9, MBOX.MB_PAR_ERR, MB_PAR_ERR, MB_PAR_ERR_IN);

  // APR2 p.383
  IntEnabler cdirpInt(clk, 10, C_DIR_P_ERR_INT_EN, C_DIR_P_ERR_EN_IN);
  Event cdirpErr(clk, 10, MBX.CSH_ADR_PAR_ERR, C_DIR_P_ERR_EN, C_DIR_P_ERR_IN);

  IntEnabler sadrpInt(clk, 11, S_ADR_P_ERR_INT_EN, S_ADR_P_ERR_EN_IN);
  Event sadrpErr(clk, 11, MBOX.ADR_PAR_ERR, S_ADR_P_ERR_EN, S_ADR_P_ERR_IN);

  IntEnabler pwrfInt(clk, 12, PWR_FAIL_ERR_INT_EN, PWR_FAIL_ERR_EN_IN);
  Event pwrfErr(clk, 12, PWR_WARN, PWR_FAIL_ERR_EN, PWR_FAIL_ERR_IN);

  IntEnabler swpdInt(clk, 13, SWEEP_DONE_INT_EN, SWEEP_DONE_EN_IN);
  Event swpdErr(clk, 13,
                ~APR.SWEEP_BUSY & APR.SWEEP_BUSY,
                SWEEP_DONE_EN, SWEEP_DONE_IN);

  assign APR.APR_INTERRUPT = APR.SBUS_ERR & SBUS_ERR_INT_EN |
                             APR.NXM_ERR & NXM_ERR_INT_EN |
                             IO_PF_ERR & IO_PF_ERR_INT_EN |
                             APR.MB_PAR_ERR & MB_PAR_ERR_INT_EN |
                             APR.C_DIR_P_ERR & C_DIR_P_ERR_INT_EN |
                             APR.S_ADR_P_ERR & S_ADR_P_ERR_INT_EN |
                             PWR_FAIL & PWR_FAIL_INT_EN |
                             SWEEP_DONE & SWEEP_DONE_INT_EN;
  assign APR.WR_BAD_ADR_PAR = ~APR.S_ADR_P_ERR &
                              CON.WR_EVEN_PAR_ADR &
                              ~MBOX.ADR_PAR_ERR;

  always_ff @(posedge clk) begin
    APR.ANY_EBOX_ERR_FLG <= NXM_ERR_IN | MB_PAR_ERR_IN | S_ADR_P_ERR_IN;
  end


  // APR3 p.384
  logic [0:3] e14SR;
  always_ff @(posedge clk) begin

    if (CON.COND_EBUS_CTL | RESET) begin
      e14SR <= {CRAM.MAGIC[0:1], CRAM.MAGIC[3:4]};
    end
  end

  logic [0:2] e2Latch;
  always_latch begin

    if (e14SR[3]) begin
      e2Latch = CRAM.MAGIC[5] ?
                {CRAM.MAGIC[6], ~APR.AC[9], F02_EN} :
                {CRAM.MAGIC[6:8]};
    end
  end

  always_comb begin
    APR.EBUS_DISABLE_CS = e14SR[3] & e2Latch[0];
    APR.EBUS_F01 = e14SR[3] & e2Latch[1];
    APR.APR_EBOX_SEND_F02 = e14SR[3] & e2Latch[2];
    APR.CONI_OR_DATAI = ~APR.APR_EBOX_SEND_F02;
    APR.CONO_OR_DATAO = e14SR[3] & ~APR.CONI_OR_DATAI;
  end

  logic fm36XORin;

`ifdef KL10PV_TB
  sim_mem
    #(.SIZE(128), .WIDTH(2), .NBYTES(1))
  fm
  (.clk(clk),
   .din({SHM.AR_EXTENDED, SHM.AR_PAR_ODD ^ SHM.AR_EXTENDED}),
   .dout({APR.FM_EXTENDED, fm36XORin}),
   .addr({APR.FMblk, APR.FMadr}),
   .wea(~clk & CON.FM_WRITE_PAR & APR.SPARE)); // ??? WTF ???
`else
  fm_ext_mem fm_ext(.addra({APR.FMblk, APR.FMadr}),
                    .clka(clk),
                    .dina({SHM.AR_EXTENDED, SHM.AR_PAR_ODD ^ SHM.AR_EXTENDED}),
                    .douta({APR.FM_EXTENDED, fm36XORin}),
                    .wea(~clk & CON.FM_WRITE_PAR & APR.SPARE)); // WTF?
`endif

  always_comb begin
    APR.FM_36 = fm36XORin ^ APR.FM_EXTENDED;
    APR.FM_ODD_PARITY = |CRAM.ADB | EDP.FM_PARITY;
  end

  always_ff @(posedge clk) begin
    if (CON.DATAO_APR) begin
      {APR.FETCH_COMP,
       APR.READ_COMP,
       APR.WRITE_COMP,
       APR.USER_COMP} <= EBUS.data[9:12];
    end
  end


  // APR4 p.385
  
endmodule // apr
