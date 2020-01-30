`timescale 1ns/1ns
`include "cram-defs.svh"
`include "ebus-defs.svh"

// M8543 CTL
module ctl(input eboxClk,
           input MR_RESET,

           input [0:35] EDP_AR,
           input [0:35] EDP_ARX,

           input CON_PI_CYCLE,
           input CON_PCplus1_INH,
           input CON_FM_XFER,
           input CON_COND_EN00_07,
           input CON_COND_DIAG_FUNC,

           input APR_CLK,
           input APR_CONO_OR_DATAO,
           input APR_CONI_OR_DATAI,
           input APR_EBUS_RETURN,

           input SHM_AR_PAR_ODD,

           input CLK_SBR_CALL,
           input CLK_RESP_MBOX,
           input CLK_RESP_SIM,

           input MCL_SHORT_STACK,
           input MCL_18_BIT_EA,
           input MCL_23_BIT_EA,
           input MCL_LOAD_AR,
           input MCL_LOAD_ARX,
           input MCL_MEM_ARL_IND,

           input P15_GATE_TTL_TO_ECL,

           iEBUS EBUS,
           tEBUSdriver EBUSdriver,

           output logic CTL_AR00to08_LOAD,
           output logic CTL_AR09to17_LOAD,
           output logic CTL_ARR_LOAD,

           output logic [0:2] CTL_ARL_SEL,
           output logic [0:2] CTL_ARR_SEL,
           output logic [0:2] CTL_ARXL_SEL,
           output logic [0:2] CTL_ARXR_SEL,
           output logic CTL_ARX_LOAD,
           output logic [0:8] CTL_REG_CTL,

           output logic [0:1] CTL_MQ_SEL,
           output logic [0:1] CTL_MQM_SEL,
           output logic CTL_MQM_EN,

           output logic CTL_adToEBUS_L,
           output logic CTL_adToEBUS_R,

           output logic CTL_DISP_NICOND,
           output logic CTL_DISP_RET,

           output logic CTL_SPEC_SCM_ALT,
           output logic CTL_SPEC_CLR_FPD,
           output logic CTL_SPEC_FLAG_CTL,
           output logic CTL_SPEC_SP_MEM_CYCLE,
           output logic CTL_SPEC_SAVE_FLAGS,
           output logic CTL_SPEC_ADX_CRY_36,
           output logic CTL_SPEC_GEN_CRY18,
           output logic CTL_SPEC_CALL,
           output logic CTL_SPEC_SBR_CALL,
           output logic CTL_SPEC_XCRY_AR0,

           output logic CTL_AD_LONG,
           output logic CTL_ADX_CRY_36,
           output logic CTL_INH_CRY_18,
           output logic CTL_GEN_CRY_18,

           output logic CTL_COND_REG_CTL,
           output logic CTL_COND_AR_EXP,
           output logic CTL_COND_ARR_LOAD,
           output logic CTL_COND_ARLR_LOAD,
           output logic CTL_COND_ARLL_LOAD,
           output logic CTL_COND_AR_CLR,
           output logic CTL_COND_ARX_CLR,

           output logic CTL_ARL_IND,
           output logic [0:1] CTL_ARL_IND_SEL,
           output logic CTL_MQ_CLR,
           output logic CTL_AR_CLR,
           output logic CTL_AR00to11_CLR,
           output logic CTL_AR12to17_CLR,
           output logic CTL_ARR_CLR,
           output logic CTL_ARX_CLR,

           output logic CTL_DIAG_CTL_FUNC_00x,
           output logic CTL_DIAG_LD_FUNC_04x,
           output logic CTL_DIAG_LOAD_FUNC_06x,
           output logic CTL_DIAG_LOAD_FUNC_07x,
           output logic CTL_DIAG_LOAD_FUNC_072,
           output logic CTL_DIAG_LD_FUNC_073,
           output logic CTL_DIAG_LD_FUNC_074,
           output logic CTL_DIAG_SYNC_FUNC_075,
           output logic CTL_DIAG_LD_FUNC_076,
           output logic CTL_DIAG_CLK_EDP,
           output logic CTL_DIAG_READ_FUNC_11x,
           output logic CTL_DIAG_READ_FUNC_12x,
           output logic CTL_DIAG_READ_FUNC_13x,
           output logic CTL_DIAG_READ_FUNC_14x,
           
           output logic CTL_PI_CYCLE_SAVE_FLAGS,
           output logic CTL_LOAD_PC,

           output logic CTL_DIAG_STROBE,
           output logic CTL_DIAG_READ,
           output logic CTL_DIAG_AR_LOAD,
           output logic CTL_DIAG_LD_EBUS_REG,
           output logic CTL_EBUS_XFER,

           output logic CTL_AD_TO_EBUS_L,
           output logic CTL_AD_TO_EBUS_R,
           output logic CTL_EBUS_T_TO_E_EN,
           output logic CTL_EBUS_E_TO_T_EN,

           output logic CTL_EBUS_PARITY_OUT,

           output logic DIAG_CHANNEL_CLK_STOP,
           output logic CTL_DIAG_FORCE_EXTEND,
           output logic [0:6] CTL_DIAG_DIAG,
           output logic [4:6] DIAG
);


  logic CTL_DISP_AREAD;
  logic CTL_DISP_RETURN;
  logic CTL_DISP_MUL;
  logic CTL_DISP_DIV;
  logic CTL_DISP_NORM;
  logic CTL_DISP_EA_MOD;
  
  logic CTL_SPEC_INH_CRY_18;
  logic CTL_SPEC_MQ_SHIFT;
  logic CTL_SPEC_LOAD_PC;
  logic CTL_SPEC_GEN_CRY_18;
  logic CTL_SPEC_STACK_UPDATE;
  logic CTL_SPEC_ARL_IND;
  logic CTL_SPEC_AD_LONG;
  logic CTL_SPEC_MTR_CTL;
  logic SPEC_MTR_CTL;

  logic CTL_COND_ARL_IND;

  logic CTL_CONSOLE_CONTROL;

  logic [0:6] CTL_DS;

  logic CTL_36_BIT_EA;
  logic [0:1] CTL_DISP_EN;
  logic CTL_RESET;
  logic DIAG_MEM_RESET;
  logic CTL_READ_STROBE;

  logic DIAG_CONTROL_FUNC_01x;
  logic DIAG_LOAD_FUNC_05x;
  logic DIAG_LOAD_FUNC_070;
  logic DIAG_LOAD_FUNC_071;
  logic DIAG_READ_FUNC_10x;
  logic DIAG_READ_FUNC_15x;
  logic DIAG_READ_FUNC_16x;
  logic DIAG_READ_FUNC_17x;

`include "cram-aliases.svh"

  // p.364: Decode all the things.
  // Dispatches
  assign CTL_DISP_AREAD = CRAM.DISP === dispDRAM_A_RD;
  assign CTL_DISP_RETURN = CRAM.DISP === dispRETURN;
  assign CTL_DISP_NICOND = CRAM.DISP === dispNICOND;
  assign CTL_DISP_MUL = CRAM.DISP === dispMUL;
  assign CTL_DISP_DIV = CRAM.DISP === dispDIV;
  assign CTL_DISP_NORM = CRAM.DISP === dispNORM;
  assign CTL_DISP_EA_MOD = CRAM.DISP === dispEA_MOD;
  
  // Special functions
  assign CTL_SPEC_INH_CRY_18 = SPEC === specINH_CRY18;
  assign CTL_SPEC_MQ_SHIFT = SPEC === specMQ_SHIFT;
  assign CTL_SPEC_SCM_ALT = SPEC === specSCM_ALT;
  assign CTL_SPEC_CLR_FPD = SPEC === specCLR_FPD;
  assign CTL_SPEC_LOAD_PC = SPEC === specLOAD_PC;
  assign CTL_SPEC_XCRY_AR0 = SPEC === specXCRY_AR0;
  assign CTL_SPEC_GEN_CRY_18 = SPEC === specGEN_CRY18;
  assign CTL_SPEC_STACK_UPDATE = SPEC === specSTACK_UPDATE;
  assign CTL_SPEC_ARL_IND = SPEC === specARL_IND;
  assign CTL_SPEC_FLAG_CTL = SPEC === specFLAG_CTL;
  assign CTL_SPEC_SAVE_FLAGS = SPEC === specSAVE_FLAGS;
  assign CTL_SPEC_SP_MEM_CYCLE = SPEC === specSP_MEM_CYCLE;
  assign CTL_SPEC_AD_LONG = SPEC === specAD_LONG;
  assign SPEC_MTR_CTL = SPEC === specMTR_CTL;

  // EBUS
  always_comb begin
    EBUSdriver.driving = CTL_DIAG_READ;

    unique case ({CTL_DIAG_READ, CTL_DS[4:6]})
    default: EBUSdriver.data[24:28] = 0;
    4'b1000: EBUSdriver.data[24:28] = {CTL_SPEC_SCM_ALT,
                                       CTL_SPEC_SAVE_FLAGS,
                                       CTL_ARL_SEL[1],
                                       CTL_ARR_LOAD,
                                       CTL_AR00to08_LOAD};
    4'b1001: EBUSdriver.data[24:28] = {CTL_SPEC_CLR_FPD,
                                       CTL_SPEC_MTR_CTL,
                                       CTL_ARL_SEL[0],
                                       CTL_ARR_LOAD,
                                       CTL_AR09to17_LOAD};
    4'b1010: EBUSdriver.data[24:28] = {CTL_SPEC_GEN_CRY_18,
                                       CTL_COND_AR_EXP,
                                       CTL_ARR_SEL[1],
                                       CTL_MQM_SEL[1],
                                       CTL_ARX_LOAD};
    4'b1011: EBUSdriver.data[24:28] = {CTL_SPEC_STACK_UPDATE,
                                       CTL_DISP_RET,
                                       CTL_ARR_SEL[0],
                                       CTL_MQM_SEL[0],
                                       CTL_ARL_SEL[2]};
    4'b1100: EBUSdriver.data[24:28] = {CTL_SPEC_FLAG_CTL,
                                       CTL_LOAD_PC,
                                       CTL_ARXL_SEL[1],
                                       CTL_MQ_SEL[1],
                                       CTL_AR00to11_CLR};
    4'b1101: EBUSdriver.data[24:28] = {CTL_SPEC_SP_MEM_CYCLE,
                                       CTL_SPEC_ADX_CRY_36,
                                       CTL_ARXL_SEL[0],
                                       CTL_MQ_SEL[0],
                                       CTL_AR12to17_CLR};
    4'b1110: EBUSdriver.data[24:28] = {CTL_AD_LONG,
                                       CTL_ADX_CRY_36,
                                       CTL_ARXR_SEL[1],
                                       CTL_MQM_EN,
                                       CTL_ARR_CLR};
    4'b1111: EBUSdriver.data[24:28] = {CTL_INH_CRY_18,
                                       DIAG_MEM_RESET,
                                       CTL_ARXR_SEL[0],
                                       CTL_DIAG_LD_EBUS_REG,
                                       CTL_SPEC_CALL};
    endcase
  end
  
  // Miscellaneous control signals CTL1
  logic loadPC1 = 0;
  always_comb begin
    CTL_PI_CYCLE_SAVE_FLAGS = CON_PCplus1_INH & CTL_SPEC_SAVE_FLAGS;
    // This is "CRAM.AD & adCARRY" term is actually shown on CTL1
    // E8 pins 5 and 7 as CRAM AD CRY. I'm just guessing this is
    // what they mean since I don't have backplane wiring.
    CTL_ADX_CRY_36 = ~CTL_PI_CYCLE_SAVE_FLAGS &&
                     ((CRAM.AD & `adCARRY) !== 0) ^ (EDP_AR[0] & CTL_SPEC_XCRY_AR0);

    CTL_REG_CTL[0:2] = CRAM.MAGIC[0:2] & CTL_COND_REG_CTL;
    CTL_COND_AR_EXP = CRAM.MAGIC[5] & CTL_COND_REG_CTL;
    CTL_REG_CTL[7:8] = CRAM.MAGIC[7:8] & CTL_COND_REG_CTL;

    // This mess is CTL1 E12, E3, E16 p.364. My confidence in this
    // is not high.
    // Race?
    loadPC1 = ~((APR_CLK & loadPC1) |                   // E12
                ((CTL_SPEC_LOAD_PC | CTL_DISP_NICOND) & // E16
                 CLK_SBR_CALL));                        // E12
    CTL_LOAD_PC = CON_PI_CYCLE & loadPC1;

    CTL_GEN_CRY_18 = (CTL_SPEC_GEN_CRY_18 | CTL_SPEC_STACK_UPDATE) &
                     (CTL_SPEC_GEN_CRY_18 | MCL_SHORT_STACK);

    CTL_DISP_EN = CRAM.DISP[0:1];

    CTL_RESET = MR_RESET;

    CTL_AD_LONG = CTL_DISP_MUL |
                  CTL_DISP_DIV |
                  CTL_DISP_NORM |
                  CTL_SPEC_AD_LONG |
                  CTL_SPEC_MQ_SHIFT;

    CTL_DISP_RET = ~(~CLK_SBR_CALL | ~CTL_DISP_RETURN);
    CTL_SPEC_MTR_CTL = SPEC_MTR_CTL & APR_CLK;
  end

  // CTL2 p.365
  logic load1;
  logic d2, d3;
  logic shortEA;
  logic FMandARload;
  logic FMandARXload;
  logic diagLoadARorInd;
  logic diagLoadARorARM;
  logic respMBOXorSIM;
  logic resetOrREG_CTLorMQ_CLR;
  logic mathOrREG_CTLorMQ_CLR;

  always_comb begin
    CTL_ARR_LOAD = ~(CTL_REG_CTL[2] | |{CRAM.AR[2],
                                        CTL_ARR_SEL[1],
                                        CTL_ARR_SEL[0],
                                        CTL_ARR_CLR,
                                        CTL_COND_ARR_LOAD});
    load1 = |{CTL_AR00to11_CLR, CTL_ARL_SEL};
    CTL_AR09to17_LOAD = CTL_COND_ARLR_LOAD | CTL_REG_CTL[1] | load1;
    CTL_AR00to08_LOAD = CTL_COND_ARLL_LOAD | CTL_REG_CTL[0] | load1 |
                        CRAM.MAGIC[0] & CTL_ARL_IND;

    CTL_MQ_CLR = CTL_ARL_IND ? CRAM.MAGIC[2] : '0;
    CTL_ARX_CLR = CTL_ARL_IND ? CRAM.MAGIC[3] : CTL_COND_ARX_CLR;
    d2 = CTL_ARL_IND ? CRAM.MAGIC[4] : CTL_COND_AR_CLR;
    d3 = CTL_ARL_IND ? CRAM.MAGIC[5] : CTL_COND_AR_CLR;
    shortEA = CTL_DISP_EA_MOD & EDP_ARX[18];
    CTL_AR12to17_CLR = CTL_RESET | MCL_18_BIT_EA | d2 | shortEA;
    CTL_AR00to11_CLR = CTL_AR12to17_CLR | MCL_23_BIT_EA;

    CTL_SPEC_CALL = ~(CLK_SBR_CALL | (CTL_ARL_IND ? CRAM.MAGIC[0] : CTL_SPEC_SBR_CALL));
    CTL_ARL_SEL[2] = CTL_ARL_IND ? CRAM.MAGIC[6] : CRAM.AR[2];
    CTL_ARL_SEL[1] = CTL_ARL_IND ? CRAM.MAGIC[7] : CRAM.AR[1];
    CTL_ARL_IND_SEL[0] = CTL_ARL_IND ? CRAM.MAGIC[8] : CRAM.AR[0];

    FMandARload = CON_FM_XFER & MCL_LOAD_AR;
    CTL_ARL_SEL[1] = CTL_ARL_IND_SEL[1] | CTL_36_BIT_EA | CTL_DIAG_AR_LOAD | FMandARload;
    CTL_ARR_SEL[1] = CRAM.AR[1] | CTL_DISP_AREAD | CTL_DIAG_AR_LOAD | FMandARload;
    
    FMandARXload = CON_FM_XFER & MCL_LOAD_ARX;
    CTL_ARXL_SEL[1] = CRAM.ARX[1] | FMandARXload;
    CTL_ARXR_SEL[1] = CTL_ARXL_SEL[1];

    CTL_ARX_LOAD = CRAM.ARX[0] | CTL_ARXR_SEL[1] | CTL_ARXR_SEL[2] | CTL_ARX_CLR | CTL_RESET;

    CTL_ARL_IND = MCL_MEM_ARL_IND | CTL_SPEC_ARL_IND | CTL_COND_ARL_IND;

    CTL_EBUS_XFER = CRAM.AR[0] & APR_CONO_OR_DATAO & ~(CRAM.AR[1] & CRAM.AR[2]);
    CTL_36_BIT_EA = CTL_DISP_AREAD & CTL_AR00to11_CLR;

    CTL_COND_ARLL_LOAD = CON_COND_EN00_07 & (CRAM.COND[3:5] === 3'b001);
    CTL_COND_ARLR_LOAD = CON_COND_EN00_07 & (CRAM.COND[3:5] === 3'b010);
    CTL_COND_ARR_LOAD =  CON_COND_EN00_07 & (CRAM.COND[3:5] === 3'b011);
    CTL_COND_AR_CLR =    CON_COND_EN00_07 & (CRAM.COND[3:5] === 3'b100);
    CTL_COND_ARX_CLR =   CON_COND_EN00_07 & (CRAM.COND[3:5] === 3'b101);
    CTL_COND_ARL_IND =   CON_COND_EN00_07 & (CRAM.COND[3:5] === 3'b110);
    CTL_COND_REG_CTL =   CON_COND_EN00_07 & (CRAM.COND[3:5] === 3'b111);

    respMBOXorSIM = CLK_RESP_MBOX | CLK_RESP_SIM;
    diagLoadARorInd = CTL_ARL_IND | CTL_DIAG_AR_LOAD;
    diagLoadARorARM = CRAM.AR[2] | CTL_DIAG_AR_LOAD;
    CTL_ARL_SEL[0] = (MCL_LOAD_AR | diagLoadARorInd) & (diagLoadARorInd | respMBOXorSIM);
    CTL_ARR_SEL[0] = (MCL_LOAD_AR | diagLoadARorARM) & (diagLoadARorARM | respMBOXorSIM);
    CTL_ARXL_SEL[0] = (MCL_LOAD_ARX | CRAM.ARX[2]) & (CRAM.ARX[2] | respMBOXorSIM);
    CTL_ARXR_SEL[0] = CTL_ARXL_SEL[0];

    resetOrREG_CTLorMQ_CLR = CTL_RESET | CTL_REG_CTL[7] | CTL_MQ_CLR;
    mathOrREG_CTLorMQ_CLR = CTL_MQ_CLR | CTL_REG_CTL[8] | CTL_SPEC_MQ_SHIFT |
                            CTL_DISP_MUL | CTL_DISP_DIV;
    CTL_MQM_EN = CRAM.MQ | CTL_RESET;
    CTL_MQM_SEL[1] = CTL_MQM_EN & resetOrREG_CTLorMQ_CLR;
    CTL_MQM_SEL[0] = CTL_MQM_EN & mathOrREG_CTLorMQ_CLR;
    CTL_MQ_SEL[1] = ~CTL_MQM_EN & resetOrREG_CTLorMQ_CLR;
    CTL_MQ_SEL[0] = ~CTL_MQM_EN & mathOrREG_CTLorMQ_CLR;
  end

  // CTL3 p.366
  logic ds00OrDiagStrobe;
  logic en1xx;
  always_comb begin
    ds00OrDiagStrobe = EBUS.ds[0] & CTL_DIAG_STROBE;
    CTL_DIAG_CTL_FUNC_00x  = ds00OrDiagStrobe && EBUS.ds[1:3] === 3'b000;
    DIAG_CONTROL_FUNC_01x  = ds00OrDiagStrobe && EBUS.ds[1:3] === 3'b010;
    CTL_DIAG_LD_FUNC_04x   = ds00OrDiagStrobe && EBUS.ds[1:3] === 3'b100;
    DIAG_LOAD_FUNC_05x     = ds00OrDiagStrobe && EBUS.ds[1:3] === 3'b101;
    CTL_DIAG_LOAD_FUNC_06x = ds00OrDiagStrobe && EBUS.ds[1:3] === 3'b110;
    CTL_DIAG_LOAD_FUNC_07x = ds00OrDiagStrobe && EBUS.ds[1:3] === 3'b111;

    DIAG_LOAD_FUNC_070     = CTL_DIAG_LOAD_FUNC_07x && EBUS.ds[4:6] === 3'b000;
    DIAG_LOAD_FUNC_071     = CTL_DIAG_LOAD_FUNC_07x && EBUS.ds[4:6] === 3'b001;
    CTL_DIAG_LOAD_FUNC_072 = CTL_DIAG_LOAD_FUNC_07x && EBUS.ds[4:6] === 3'b010;
    CTL_DIAG_LD_FUNC_073   = CTL_DIAG_LOAD_FUNC_07x && EBUS.ds[4:6] === 3'b011;
    CTL_DIAG_LD_FUNC_074   = CTL_DIAG_LOAD_FUNC_07x && EBUS.ds[4:6] === 3'b100;
    CTL_DIAG_SYNC_FUNC_075 = CTL_DIAG_LOAD_FUNC_07x && EBUS.ds[4:6] === 3'b101;
    CTL_DIAG_LD_FUNC_076   = CTL_DIAG_LOAD_FUNC_07x && EBUS.ds[4:6] === 3'b110;
    CTL_DIAG_CLK_EDP       = CTL_DIAG_LOAD_FUNC_07x && EBUS.ds[4:6] === 3'b111;

    en1xx = CTL_DS[0] & CTL_READ_STROBE;
    DIAG_READ_FUNC_10x     = en1xx && CTL_DS[1:3] === 3'b000;
    CTL_DIAG_READ_FUNC_11x = en1xx && CTL_DS[1:3] === 3'b001;
    CTL_DIAG_READ_FUNC_12x = en1xx && CTL_DS[1:3] === 3'b010;
    CTL_DIAG_READ_FUNC_13x = en1xx && CTL_DS[1:3] === 3'b011;
    CTL_DIAG_READ_FUNC_14x = en1xx && CTL_DS[1:3] === 3'b100;
    DIAG_READ_FUNC_15x     = en1xx && CTL_DS[1:3] === 3'b101;
    DIAG_READ_FUNC_16x     = en1xx && CTL_DS[1:3] === 3'b110;
    DIAG_READ_FUNC_17x     = en1xx && CTL_DS[1:3] === 3'b111;

    CTL_DIAG_READ = DIAG_READ_FUNC_10x;

    CTL_DIAG_STROBE = EBUS.diagStrobe;

    CTL_CONSOLE_CONTROL = EBUS.ds[0] | EBUS.ds[1];
    CTL_READ_STROBE = CTL_CONSOLE_CONTROL ? CTL_DIAG_STROBE : CON_COND_DIAG_FUNC & APR_CLK;
    CTL_DS = CTL_CONSOLE_CONTROL ? EBUS.ds[0:6] : CRAM.MAGIC[2:8];

    DIAG[4:6] = CTL_DS[4:6];

    CTL_AD_TO_EBUS_L = CTL_CONSOLE_CONTROL &
                       (APR_CONO_OR_DATAO | (CON_COND_DIAG_FUNC | CRAM.MAGIC[2] | APR_CLK));
    CTL_AD_TO_EBUS_R = CTL_AD_TO_EBUS_L;

    CTL_DIAG_AR_LOAD = CTL_DS[0] & &EBUS.ds[1:3] & &DIAG[4:6];

    CTL_EBUS_T_TO_E_EN = (P15_GATE_TTL_TO_ECL | APR_CONI_OR_DATAI) & CTL_CONSOLE_CONTROL |
                         (EBUS.ds[0] & CTL_CONSOLE_CONTROL);
    CTL_EBUS_E_TO_T_EN = APR_EBUS_RETURN & CTL_EBUS_T_TO_E_EN |
                         CTL_CONSOLE_CONTROL & CTL_EBUS_T_TO_E_EN;
    CTL_EBUS_PARITY_OUT = SHM_AR_PAR_ODD | CTL_AD_TO_EBUS_L;
  end

  always_ff @(posedge CTL_DIAG_LD_FUNC_076) begin
    DIAG_MEM_RESET <= EBUS.data[24];
    DIAG_CHANNEL_CLK_STOP = EBUS.data[25];
    CTL_DIAG_LD_EBUS_REG = EBUS.data[26];
    CTL_DIAG_FORCE_EXTEND = EBUS.data[27];
    CTL_DIAG_DIAG[4] = EBUS.data[28];
  end
endmodule // ctl
