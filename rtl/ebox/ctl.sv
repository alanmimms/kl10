`timescale 1ns/1ns
`include "ebox.svh"

// M8543 CTL
module ctl(iAPR APR,
           iCLK CLK,
           iCON CON,
           iCRAM CRAM,
           iEDP EDP,
           iMCL MCL,
           iPI PI,
           iSHM SHM,

           iEBUS EBUS
);

  iCTL CTL();

  logic CTL_DISP_AREAD;
  logic CTL_DISP_RETURN;
  logic CTL_DISP_MUL;
  logic CTL_DISP_DIV;
  logic CTL_DISP_NORM;
  logic CTL_DISP_EA_MOD;
  
  logic CTL_COND_ARL_IND;
  logic CTL_COND_AR_EXP;
  logic CTL_COND_REG_CTL;

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
  logic DIAG_READ_FUNC_15x;
  logic DIAG_READ_FUNC_16x;
  logic DIAG_READ_FUNC_17x;

  logic SPEC_MTR_CTL;


`include "cram-aliases.svh"

  // p.364: Decode all the things.
  // Dispatches
  assign CTL_DISP_AREAD = CRAM.DISP === dispDRAM_A_RD;
  assign CTL_DISP_RETURN = CRAM.DISP === dispRETURN;
  assign CTL.DISP_NICOND = CRAM.DISP === dispNICOND;
  assign CTL_DISP_MUL = CRAM.DISP === dispMUL;
  assign CTL_DISP_DIV = CRAM.DISP === dispDIV;
  assign CTL_DISP_NORM = CRAM.DISP === dispNORM;
  assign CTL_DISP_EA_MOD = CRAM.DISP === dispEA_MOD;
  
  // Special functions
  assign CTL.SPEC_INH_CRY_18 = SPEC === specINH_CRY18;
  assign CTL.SPEC_MQ_SHIFT = SPEC === specMQ_SHIFT;
  assign CTL.SPEC_SCM_ALT = SPEC === specSCM_ALT;
  assign CTL.SPEC_CLR_FPD = SPEC === specCLR_FPD;
  assign CTL.SPEC_LOAD_PC = SPEC === specLOAD_PC;
  assign CTL.SPEC_XCRY_AR0 = SPEC === specXCRY_AR0;
  assign CTL.SPEC_GEN_CRY_18 = SPEC === specGEN_CRY18;
  assign CTL.SPEC_STACK_UPDATE = SPEC === specSTACK_UPDATE;
  assign CTL.SPEC_ARL_IND = SPEC === specARL_IND;
  assign CTL.SPEC_FLAG_CTL = SPEC === specFLAG_CTL;
  assign CTL.SPEC_SAVE_FLAGS = SPEC === specSAVE_FLAGS;
  assign CTL.SPEC_SP_MEM_CYCLE = SPEC === specSP_MEM_CYCLE;
  assign CTL.SPEC_AD_LONG = SPEC === specAD_LONG;

  // This one is internal because of reclock with APR_CLK below.
  assign SPEC_MTR_CTL = SPEC === specMTR_CTL;

  // EBUS
  always_comb begin
    CTL.EBUSdriver.driving = CTL.DIAG_READ;

    unique case ({CTL.DIAG_READ, CTL_DS[4:6]})
    default: CTL.EBUSdriver.data[24:28] = 0;
    4'b1000: CTL.EBUSdriver.data[24:28] = {CTL.SPEC_SCM_ALT,
                                           CTL.SPEC_SAVE_FLAGS,
                                           CTL.ARL_SEL[1],
                                           CTL.ARR_LOAD,
                                           CTL.AR00to08_LOAD};
    4'b1001: CTL.EBUSdriver.data[24:28] = {CTL.SPEC_CLR_FPD,
                                           CTL.SPEC_MTR_CTL,
                                           CTL.ARL_SEL[0],
                                           CTL.ARR_LOAD,
                                           CTL.AR09to17_LOAD};
    4'b1010: CTL.EBUSdriver.data[24:28] = {CTL.SPEC_GEN_CRY_18,
                                           CTL_COND_AR_EXP,
                                           CTL.ARR_SEL[1],
                                           CTL.MQM_SEL[1],
                                           CTL.ARX_LOAD};
    4'b1011: CTL.EBUSdriver.data[24:28] = {CTL.SPEC_STACK_UPDATE,
                                           CTL.DISP_RET,
                                           CTL.ARR_SEL[0],
                                           CTL.MQM_SEL[0],
                                           CTL.ARL_SEL[2]};
    4'b1100: CTL.EBUSdriver.data[24:28] = {CTL.SPEC_FLAG_CTL,
                                           CTL.LOAD_PC,
                                           CTL.ARXL_SEL[1],
                                           CTL.MQ_SEL[1],
                                           CTL.AR00to11_CLR};
    4'b1101: CTL.EBUSdriver.data[24:28] = {CTL.SPEC_SP_MEM_CYCLE,
                                           CTL.SPEC_ADX_CRY_36,
                                           CTL.ARXL_SEL[0],
                                           CTL.MQ_SEL[0],
                                           CTL.AR12to17_CLR};
    4'b1110: CTL.EBUSdriver.data[24:28] = {CTL.AD_LONG,
                                           CTL.ADX_CRY_36,
                                           CTL.ARXR_SEL[1],
                                           CTL.MQM_EN,
                                           CTL.ARR_CLR};
    4'b1111: CTL.EBUSdriver.data[24:28] = {CTL.INH_CRY_18,
                                           DIAG_MEM_RESET,
                                           CTL.ARXR_SEL[0],
                                           CTL.DIAG_LD_EBUS_REG,
                                           CTL.SPEC_CALL};
    endcase
  end
  
  // Miscellaneous control signals CTL1
  logic loadPC1 = 0;
  always_comb begin
    CTL.PI_CYCLE_SAVE_FLAGS = CON.PCplus1_INH & CTL.SPEC_SAVE_FLAGS;
    // This is "CRAM.AD & adCARRY" term is actually shown on CTL1
    // E8 pins 5 and 7 as CRAM AD CRY. I'm just guessing this is
    // what they mean since I don't have backplane wiring.
    CTL.ADX_CRY_36 = ~CTL.PI_CYCLE_SAVE_FLAGS &&
                     ((CRAM.AD & `adCARRY) !== 0) ^ (EDP.AR[0] & CTL.SPEC_XCRY_AR0);

    CTL.REG_CTL[0:2] = CRAM.MAGIC[0:2] & CTL_COND_REG_CTL;
    CTL_COND_AR_EXP = CRAM.MAGIC[5] & CTL_COND_REG_CTL;
    CTL.REG_CTL[7:8] = CRAM.MAGIC[7:8] & CTL_COND_REG_CTL;

    // This mess is CTL1 E12, E3, E16 p.364. My confidence in this
    // is not high.
    // Race?
    loadPC1 = ~((APR.CLK & loadPC1) |                   // E12
                ((CTL.SPEC_LOAD_PC | CTL.DISP_NICOND) & // E16
                 CLK.SBR_CALL));                        // E12
    CTL.LOAD_PC = CON.PI_CYCLE & loadPC1;

    CTL.GEN_CRY_18 = (CTL.SPEC_GEN_CRY_18 | CTL.SPEC_STACK_UPDATE) &
                     (CTL.SPEC_GEN_CRY_18 | MCL.SHORT_STACK);

    CTL_DISP_EN = CRAM.DISP[0:1];

    CTL_RESET = CLK.MR_RESET;

    CTL.AD_LONG = CTL_DISP_MUL |
                  CTL_DISP_DIV |
                  CTL_DISP_NORM |
                  CTL.SPEC_AD_LONG |
                  CTL.SPEC_MQ_SHIFT;

    CTL.DISP_RET = ~(~CLK.SBR_CALL | ~CTL_DISP_RETURN);
    CTL.SPEC_MTR_CTL = SPEC_MTR_CTL & APR.CLK;
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
    CTL.ARR_LOAD = ~(CTL.REG_CTL[2] | |{CRAM.AR[2],
                                        CTL.ARR_SEL[1],
                                        CTL.ARR_SEL[0],
                                        CTL.ARR_CLR,
                                        CTL.COND_ARR_LOAD});
    load1 = |{CTL.AR00to11_CLR, CTL.ARL_SEL};
    CTL.AR09to17_LOAD = CTL.COND_ARLR_LOAD | CTL.REG_CTL[1] | load1;
    CTL.AR00to08_LOAD = CTL.COND_ARLL_LOAD | CTL.REG_CTL[0] | load1 |
                        CRAM.MAGIC[0] & CTL.ARL_IND;

    CTL.MQ_CLR = CTL.ARL_IND ? CRAM.MAGIC[2] : '0;
    CTL.ARX_CLR = CTL.ARL_IND ? CRAM.MAGIC[3] : CTL.COND_ARX_CLR;
    d2 = CTL.ARL_IND ? CRAM.MAGIC[4] : CTL.COND_AR_CLR;
    d3 = CTL.ARL_IND ? CRAM.MAGIC[5] : CTL.COND_AR_CLR;
    shortEA = CTL_DISP_EA_MOD & EDP.ARX[18];
    CTL.AR12to17_CLR = CTL_RESET | MCL._18_BIT_EA | d2 | shortEA;
    CTL.AR00to11_CLR = CTL.AR12to17_CLR | MCL._23_BIT_EA;

    CTL.SPEC_CALL = ~(CLK.SBR_CALL | (CTL.ARL_IND ? CRAM.MAGIC[0] : CTL.SPEC_SBR_CALL));
    CTL.ARL_SEL[2] = CTL.ARL_IND ? CRAM.MAGIC[6] : CRAM.AR[2];
    CTL.ARL_SEL[1] = CTL.ARL_IND ? CRAM.MAGIC[7] : CRAM.AR[1];
    CTL.ARL_IND_SEL[0] = CTL.ARL_IND ? CRAM.MAGIC[8] : CRAM.AR[0];

    FMandARload = CON.FM_XFER & MCL.LOAD_AR;
    CTL.ARL_SEL[1] = CTL.ARL_IND_SEL[1] | CTL_36_BIT_EA | CTL.DIAG_AR_LOAD | FMandARload;
    CTL.ARR_SEL[1] = CRAM.AR[1] | CTL_DISP_AREAD | CTL.DIAG_AR_LOAD | FMandARload;
    
    FMandARXload = CON.FM_XFER & MCL.LOAD_ARX;
    CTL.ARXL_SEL[1] = CRAM.ARX[1] | FMandARXload;
    CTL.ARXR_SEL[1] = CTL.ARXL_SEL[1];

    CTL.ARX_LOAD = CRAM.ARX[0] | CTL.ARXR_SEL[1] | CTL.ARXR_SEL[2] | CTL.ARX_CLR | CTL_RESET;

    CTL.ARL_IND = MCL.MEM_ARL_IND | CTL.SPEC_ARL_IND | CTL_COND_ARL_IND;

    CTL.EBUS_XFER = CRAM.AR[0] & APR.CONO_OR_DATAO & ~(CRAM.AR[1] & CRAM.AR[2]);
    CTL_36_BIT_EA = CTL_DISP_AREAD & CTL.AR00to11_CLR;

    CTL.COND_ARLL_LOAD = CON.COND_EN00_07 & (CRAM.COND[3:5] === 3'b001);
    CTL.COND_ARLR_LOAD = CON.COND_EN00_07 & (CRAM.COND[3:5] === 3'b010);
    CTL.COND_ARR_LOAD =  CON.COND_EN00_07 & (CRAM.COND[3:5] === 3'b011);
    CTL.COND_AR_CLR =    CON.COND_EN00_07 & (CRAM.COND[3:5] === 3'b100);
    CTL.COND_ARX_CLR =   CON.COND_EN00_07 & (CRAM.COND[3:5] === 3'b101);
    CTL_COND_ARL_IND =   CON.COND_EN00_07 & (CRAM.COND[3:5] === 3'b110);
    CTL_COND_REG_CTL =   CON.COND_EN00_07 & (CRAM.COND[3:5] === 3'b111);

    respMBOXorSIM = CLK.RESP_MBOX | CLK.RESP_SIM;
    diagLoadARorInd = CTL.ARL_IND | CTL.DIAG_AR_LOAD;
    diagLoadARorARM = CRAM.AR[2] | CTL.DIAG_AR_LOAD;
    CTL.ARL_SEL[0] = (MCL.LOAD_AR | diagLoadARorInd) & (diagLoadARorInd | respMBOXorSIM);
    CTL.ARR_SEL[0] = (MCL.LOAD_AR | diagLoadARorARM) & (diagLoadARorARM | respMBOXorSIM);
    CTL.ARXL_SEL[0] = (MCL.LOAD_ARX | CRAM.ARX[2]) & (CRAM.ARX[2] | respMBOXorSIM);
    CTL.ARXR_SEL[0] = CTL.ARXL_SEL[0];

    resetOrREG_CTLorMQ_CLR = CTL_RESET | CTL.REG_CTL[7] | CTL.MQ_CLR;
    mathOrREG_CTLorMQ_CLR = CTL.MQ_CLR | CTL.REG_CTL[8] | CTL.SPEC_MQ_SHIFT |
                            CTL_DISP_MUL | CTL_DISP_DIV;
    CTL.MQM_EN = CRAM.MQ | CTL_RESET;
    CTL.MQM_SEL[1] = CTL.MQM_EN & resetOrREG_CTLorMQ_CLR;
    CTL.MQM_SEL[0] = CTL.MQM_EN & mathOrREG_CTLorMQ_CLR;
    CTL.MQ_SEL[1] = ~CTL.MQM_EN & resetOrREG_CTLorMQ_CLR;
    CTL.MQ_SEL[0] = ~CTL.MQM_EN & mathOrREG_CTLorMQ_CLR;
  end

  // CTL3 p.366
  logic ds00OrDiagStrobe;
  logic en1xx;
  always_comb begin
    ds00OrDiagStrobe = EBUS.ds[0] & CTL.DIAG_STROBE;
    CTL.DIAG_CTL_FUNC_00x  = ds00OrDiagStrobe && EBUS.ds[1:3] === 3'b000;
    DIAG_CONTROL_FUNC_01x  = ds00OrDiagStrobe && EBUS.ds[1:3] === 3'b010;
    CTL.DIAG_LD_FUNC_04x   = ds00OrDiagStrobe && EBUS.ds[1:3] === 3'b100;
    DIAG_LOAD_FUNC_05x     = ds00OrDiagStrobe && EBUS.ds[1:3] === 3'b101;
    CTL.DIAG_LOAD_FUNC_06x = ds00OrDiagStrobe && EBUS.ds[1:3] === 3'b110;
    CTL.DIAG_LOAD_FUNC_07x = ds00OrDiagStrobe && EBUS.ds[1:3] === 3'b111;

    DIAG_LOAD_FUNC_070     = CTL.DIAG_LOAD_FUNC_07x && EBUS.ds[4:6] === 3'b000;
    DIAG_LOAD_FUNC_071     = CTL.DIAG_LOAD_FUNC_07x && EBUS.ds[4:6] === 3'b001;
    CTL.DIAG_LOAD_FUNC_072 = CTL.DIAG_LOAD_FUNC_07x && EBUS.ds[4:6] === 3'b010;
    CTL.DIAG_LD_FUNC_073   = CTL.DIAG_LOAD_FUNC_07x && EBUS.ds[4:6] === 3'b011;
    CTL.DIAG_LD_FUNC_074   = CTL.DIAG_LOAD_FUNC_07x && EBUS.ds[4:6] === 3'b100;
    CTL.DIAG_SYNC_FUNC_075 = CTL.DIAG_LOAD_FUNC_07x && EBUS.ds[4:6] === 3'b101;
    CTL.DIAG_LD_FUNC_076   = CTL.DIAG_LOAD_FUNC_07x && EBUS.ds[4:6] === 3'b110;
    CTL.DIAG_CLK_EDP       = CTL.DIAG_LOAD_FUNC_07x && EBUS.ds[4:6] === 3'b111;

    en1xx = CTL_DS[0] & CTL_READ_STROBE;
    EDP.DIAG_READ_FUNC_10x = en1xx && CTL_DS[1:3] === 3'b000;
    CTL.DIAG_READ_FUNC_11x = en1xx && CTL_DS[1:3] === 3'b001;
    CTL.DIAG_READ_FUNC_12x = en1xx && CTL_DS[1:3] === 3'b010;
    CTL.DIAG_READ_FUNC_13x = en1xx && CTL_DS[1:3] === 3'b011;
    CTL.DIAG_READ_FUNC_14x = en1xx && CTL_DS[1:3] === 3'b100;
    DIAG_READ_FUNC_15x     = en1xx && CTL_DS[1:3] === 3'b101;
    DIAG_READ_FUNC_16x     = en1xx && CTL_DS[1:3] === 3'b110;
    DIAG_READ_FUNC_17x     = en1xx && CTL_DS[1:3] === 3'b111;

    CTL.DIAG_READ = EDP.DIAG_READ_FUNC_10x;

    CTL.DIAG_STROBE = EBUS.diagStrobe;

    CTL_CONSOLE_CONTROL = EBUS.ds[0] | EBUS.ds[1];
    CTL_READ_STROBE = CTL_CONSOLE_CONTROL ? CTL.DIAG_STROBE : CON.COND_DIAG_FUNC & APR.CLK;
    CTL_DS = CTL_CONSOLE_CONTROL ? EBUS.ds[0:6] : CRAM.MAGIC[2:8];

    CTL.DIAG[4:6] = CTL_DS[4:6];

    CTL.AD_TO_EBUS_L = CTL_CONSOLE_CONTROL &
                       (APR.CONO_OR_DATAO | (CON.COND_DIAG_FUNC | CRAM.MAGIC[2] | APR.CLK));
    CTL.AD_TO_EBUS_R = CTL.AD_TO_EBUS_L;

    CTL.DIAG_AR_LOAD = CTL_DS[0] & &EBUS.ds[1:3] & &CTL.DIAG[4:6];

    CTL.EBUS_T_TO_E_EN = (PI.GATE_TTL_TO_ECL | APR.CONI_OR_DATAI) & CTL_CONSOLE_CONTROL |
                         (EBUS.ds[0] & CTL_CONSOLE_CONTROL);
    CTL.EBUS_E_TO_T_EN = APR.EBUS_RETURN & CTL.EBUS_T_TO_E_EN |
                         CTL_CONSOLE_CONTROL & CTL.EBUS_T_TO_E_EN;
    CTL.EBUS_PARITY_OUT = SHM.AR_PAR_ODD | CTL.AD_TO_EBUS_L;
  end

  always_ff @(posedge CTL.DIAG_LD_FUNC_076) begin
    DIAG_MEM_RESET <= EBUS.data[24];
    CTL.DIAG_CHANNEL_CLK_STOP = EBUS.data[25];
    CTL.DIAG_LD_EBUS_REG = EBUS.data[26];
    CTL.DIAG_FORCE_EXTEND = EBUS.data[27];
    CTL.DIAG[4] = EBUS.data[28];
  end
endmodule // ctl
