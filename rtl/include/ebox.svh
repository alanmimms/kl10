`ifndef _EBOX_SVH_
 `define _EBOX_SVH_ 1

///////////////////////////////////////////////////////////////
// EBUS
typedef enum logic [0:2] {
                          ebusfCONO = 3'b000,
                          ebusfCONI = 3'b001,
                          ebusfDATAO = 3'b010,
                          ebusfDATAI = 3'b011,
                          ebusfPIserved = 3'b100,
                          ebusfPIaddrIn = 3'b101
                          } tEBUSfunction;


// Each driver of EBUS gets its own instance of this. These are all
// muxed onto the iEBUS.data member based on the one-hot
// tEBUSdriver.driving indicator.
typedef struct packed{
  logic [0:35] data;
  logic driving;
} tEBUSdriver;

interface iEBUS;
  logic [0:35] data;            // Driven by EBUS mux
  logic parity;                 // Parity for what exactly? XXX
  logic [0:6] cs;               // EBOX -> dev Controller select
  tEBUSfunction func;           // EBOX -> dev Function
  logic demand;                 // EBOX -> dev
  logic [0:7] pi;               // Dev -> EBOX Priority Interrupt
  logic ack;                    // Dev -> EBOX acknowledge
  logic xfer;                   // Dev -> EBOX transfer done
  logic reset;                  // EBOX -> dev
  logic [0:7] ds;               // Dev -> EBOX??? Diagnostic Select
  logic diagStrobe;             // Dev -> EBOX Diagnostic strobe
  logic dfunc;                  // Dev -> EBOX Diagnostic function
endinterface


////////////////////////////////////////////////////////////////
// CRAM
typedef logic [0:10] tCRADR;
typedef logic [0:10] tJ;
typedef logic [0:8] tMAGIC;
typedef logic [0:5] tMAJVER;
typedef logic [0:2] tMINVER;
typedef logic [0:2] tPXCT;
typedef logic [0:3] tACmagic;
typedef logic [0:83] tCRAM_ALL;

// CRAM_AD flag bits
 `define adCARRY 6'b100_000
 `define adBOOLEAN 6'b010_000

// CRAM_AD values
typedef enum logic [0:5] {
                          // ADDER LOGICAL FUNCTIONS
                          adSETCA =`adBOOLEAN | 6'b000_000,
                          adORC =`adBOOLEAN | 6'b000_001,      // NAND
                          adORCA =`adBOOLEAN | 6'b000_010,
                          adONES =`adBOOLEAN | 6'b000_011,
                          adNOR =`adBOOLEAN | 6'b000_100,
                          //      adANDC =`adBOOLEAN | adNOR,
                          adSETCB =`adBOOLEAN | 6'b000_101,
                          adEQV =`adBOOLEAN | 6'b000_110,
                          adORCB =`adBOOLEAN | 6'b000_111,
                          adANDCA =`adBOOLEAN | 6'b001_000,
                          adXOR =`adBOOLEAN | 6'b001_001,
                          adB =`adBOOLEAN | 6'b001_010,
                          adOR =`adBOOLEAN | 6'b001_011,
                          adZEROS =`adBOOLEAN | 6'b001_100,
                          adANDCB =`adBOOLEAN | 6'b001_101,
                          adAND =`adBOOLEAN | 6'b001_110,
                          adA =`adBOOLEAN | 6'b001_111,
                          // ADDER ARITHMETIC FUNCTIONS
                          adAplus1 =`adCARRY | 6'b000_000,
                          adAplusXCRY = 6'b000_000,
                          adAplusANDCB = 6'b000_001,
                          adAplusAND = 6'b000_010,
                          adA__2 = 6'b000_011,
                          adA__2plus1 =`adCARRY | adA__2,
                          adORplus1 =`adCARRY | 6'b000_100,
                          adORplusANDCB = 6'b000_101,
                          adAplusB = 6'b000_110,
                          adAplusBplus1 =`adCARRY | adAplusB,
                          adAplusOR = 6'b000_111,
                          adORCBplus1 =`adCARRY | adORCB,
                          adAminusBminus1 = 6'b001_001,
                          adAminusB =`adCARRY | adAminusBminus1,
                          adANDplusORCB =`adCARRY | 6'b001_010,
                          adAplusORCB =`adCARRY | 6'b001_011,
                          adXCRYminus1 =`adCARRY | 6'b001_100,
                          adANDCBminus1 = 6'b001_101,
                          adANDminus1 = 6'b001_110,
                          adAminus1 = 6'b001_111,
                          // BOOLEAN FUNCTIONS FOR WHICH CRY0 IS INTERESTING
                          adCRY_A_EQ_minus1 =`adCARRY |`adBOOLEAN | 6'b000_000,
                          adCRY_A_GE_B =`adCARRY |`adBOOLEAN | 6'b001_001
                          } tAD;

typedef enum logic [0:2] {
	                  adaAR = 3'b000,
	                  adaARX = 3'b001,
	                  adaMQ = 3'b010,
	                  adaPC = 3'b011,
                          adaZEROS = 3'b100
                          } tADA;

typedef enum logic [0:1] {
                          adbFM = 2'b00,
                          adbBRx2 = 2'b01,
                          adbBR = 2'b10,
                          adbARx4 = 2'b11
                          } tADB;

typedef enum logic [0:2] {
                          arAR = 3'b000, // also arARMM, arMEM
                          arCACHE = 3'b001,
                          arAD = 3'b010,
                          arEBUS = 3'b011,
                          arSH = 3'b100,
                          arADx2 = 3'b101,
                          arADX = 3'b110,
                          arADdiv4 = 3'b111
                          } tAR;

typedef enum logic [0:2] {
                          arxARX = 3'b000, // Also MEM
                          arxCACHE = 3'b001,
                          arxAD = 3'b010,
                          arxMQ = 3'b011,
                          arxSH = 3'b100,
                          arxADXx2 = 3'b101,
                          arxADX = 3'b110,
                          arxADXdiv4 = 3'b111
                          } tARX;

typedef enum logic {
                    brRECIRC = 1'b0,
                    brAR = 1'b1
                    } tBR;

typedef enum logic {
                    brxRECIRC = 1'b0,
                    brxARX = 1'b1
                    } tBRX;

typedef enum logic {
                    mqRECIRC = 1'b0,
                    mqSH = 1'b1
                    } tMQ;

typedef enum logic [0:2] {
                          fmadrAC0 = 3'b000,
                          fmadrAC1 = 3'b001,
                          fmadrXR = 3'b010,
                          fmadrVMA = 3'b011,
                          fmadrAC2 = 3'b100,
                          fmadrAC3 = 3'b101,
                          fmadrACplusMAGIC = 3'b110,
                          fmadrMAGIC = 3'b111
                          } tFMADR;

typedef enum logic [0:2] {
                          scadA = 3'b000,
                          scadAminusBminus1 = 3'b001,
                          scadAplusB = 3'b010,
                          scadAminus1 = 3'b011,
                          scadAplus1 = 3'b100,
                          scadAminusB = 3'b101,
                          scadOR = 3'b110,
                          scadAND = 3'b111
                          } tSCAD;

typedef enum logic [0:2] {
                          scadaFE = 3'b000,
                          scadaAR0_5 = 3'b001,
                          scadaAR_EXP = 3'b010,
                          scadaMAGIC = 3'b011,
                          scadaZEROS = 3'b100
                          } tSCADA;

typedef enum logic [0:1] {
                          scadbSC = 2'b00,
                          scadbAR6_11 = 2'b01,
                          scadbAR0_8 = 2'b10,
                          scadbMAGIC = 2'b11
                          } tSCADB;

typedef enum logic {
                    scRECIRC = 1'b0,
                    scSCAD = 1'b1
                    } tSC;

typedef enum logic {
                    feRECIRC = 1'b0,
                    feSCAD = 1'b1
                    } tFE;


typedef enum logic [0:1] {
                          shSHIFT_AR_ARX = 2'b00,
                          shAR = 2'b01,
                          shARX = 2'b10,
                          shAR_SWAP = 2'b11
                          } tSH;

typedef enum logic [0:1] {
                          armmMAGIC = 2'b00,
                          armmEXP_SIGN = 2'b01,
                          armmSCAD_EXP = 2'b10,
                          armmSCAD_POS = 2'b11
                          } tARMM;

typedef enum logic [0:1] {
                          vmaxVMAX = 2'b00,
                          vmaxPC_SEC = 2'b01,
                          vmaxPREV_SEC = 2'b10,
                          vmaxAD12_17 = 2'b11
                          } tVMAX;


typedef enum logic [0:1] {
                          vmaVMA = 2'b00,
                          vmaPC = 2'b01,
                          vmaPCplus1 = 2'b10,
                          vmaAD = 2'b11
                          } tVMA;

typedef enum logic [0:1] {
                          time2T = 2'b00,
                          time3T = 2'b01,
                          time4T = 2'b10,
                          time5T = 2'b11
                          } tTIME;

typedef enum logic [0:3] {
                          memNOP = 4'b0000,
                          memARL_IND = 4'b0001,
                          memMB_WAIT = 4'b0010,
                          memRESTORE_VMA = 4'b0011,
                          memA_RD = 4'b0100,
                          memB_WRITE = 4'b0101,
                          memFETCH = 4'b0110,
                          memREG_FUNC = 4'b0111,
                          memAD_FUNC = 4'b1000,
                          memEA_CALC = 4'b1001,
                          memLOAD_AR = 4'b1010,
                          memLOAD_ARX = 4'b1011,
                          memRW = 4'b1100,
                          memRPW = 4'b1101,
                          memWRITE = 4'b1110,
                          memIFET = 4'b1111
                          } tMEM;

typedef enum logic [0:5] {
                          skipNOP = 6'b000_000,
                          skipEVEN_PAR = 6'b100_001,
                          skipBR0 = 6'b100_010,
                          skipARX0 = 6'b100_011,
                          skipAR18 = 6'b100_100,
                          skipAR0 = 6'b100_101,
                          skipACne0 = 6'b100_110,
                          skipSC0 = 6'b100_111,

                          skipPC_SEC0 = 6'b101_000,
                          skipSCAD0 = 6'b101_001,
                          skipSCADne0 = 6'b101_010,
                          skipADX0 = 6'b101_011,
                          skipAD_CRY0 = 6'b101_100,
                          skipAD0 = 6'b101_101,
                          skipADne0 = 6'b101_110,
                          skipNotLOCAL_AC_ADDR = 6'b101_111,

                          skipFETCH = 6'b110_000,
                          skipKERNEL = 6'b110_001,
                          skipUSER = 6'b110_010,
                          skipPUBLIC = 6'b110_011,
                          skipRPW_REF = 6'b110_100,
                          skipPI_CYCLE = 6'b110_101,
                          skipNotEBUS_GRANT = 6'b110_110,
                          skipNotEBUS_XFER = 6'b110_111,

                          skipINTRPT = 6'b111_000,
                          skipNotSTART = 6'b111_001,
                          skipRUN = 6'b111_010,
                          skipIO_LEGAL = 6'b111_011,
                          skipPorSXCT = 6'b111_100,
                          skipNotVMA_SEC0 = 6'b111_101,
                          skipAC_REF = 6'b111_110,
                          skipNotMTR_REQ = 6'b111_111
                          } tSKIP;

typedef enum logic [0:5] {
                          condNOP = 6'b000_000,
                          condLD_AR0_8 = 6'b000_001,
                          condLD_AR9_17 = 6'b000_010,
                          condLD_AR18_35 = 6'b000_011,
                          condAR_CLR = 6'b000_100,
                          condARX_CLR = 6'b000_101,
                          condARX_IND = 6'b000_110,
                          condREG_CTL = 6'b000_111,

                          condFM_WRITE = 6'b001_000,
                          condPCF_MAGIC = 6'b001_001,
                          condFE_SHRT = 6'b001_010,
                          condAD_FLAGS = 6'b001_011,
                          condLOAD_IR = 6'b001_100,
                          condSPEC_INSTR = 6'b001_101,
                          condSRfromMAGIC = 6'b001_110,
                          condSEL_VMA = 6'b001_111,

                          condDIAG_FUNC = 6'b010_000,
                          condEBOX_STATE = 6'b010_001,
                          condEBUS_CTL = 6'b010_010,
                          condMBOX_CTL = 6'b010_011,

                          condLONG_EN = 6'b010_101,

                          condVMAfromMAGIC = 6'b011_000,
                          condVMAfromMAGICplusTRAP = 6'b011_001,
                          condVMAfromMAGICplusMODE = 6'b011_010,
                          condVMAfromMAGICplusAR32_35 = 6'b011_011,
                          condVMAfromMAGICplusPIx2 = 6'b011_100,
                          condVMA_DEC = 6'b011_101,
                          condVMA_INC = 6'b011_110,
                          condLD_VMA_HELD = 6'b011_111
                          } tCOND;


typedef enum logic [0:4] {
                          dispDIAG = 5'b00_000,
                          dispDRAM_J = 5'b00_001,
                          dispDRAM_A_RD = 5'b00_010,
                          dispRETURN = 5'b00_011,
                          dispPG_FAIL = 5'b00_100,
                          dispSR = 5'b00_101,
                          dispNICOND = 5'b00_110,
                          dispSH0_3 = 5'b00_111,

                          dispMUL = 5'b11_000,
                          dispDIV = 5'b11_001,
                          dispSIGNS = 5'b11_010,
                          dispDRAM_B = 5'b11_011,
                          dispBYTE = 5'b11_100,
                          dispNORM = 5'b11_101,
                          dispEA_MOD = 5'b11_110
                          } tDISP;

typedef enum logic [0:4] {
                          specNOP = 5'b01_000,
                          specINH_CRY18 = 5'b01_001,
                          specMQ_SHIFT = 5'b01_010,
                          specSCM_ALT = 5'b01_011,
                          specCLR_FPD = 5'b01_100,
                          specLOAD_PC = 5'b01_101,
                          specXCRY_AR0 = 5'b01_110,
                          specGEN_CRY18 = 5'b01_111,

                          specSTACK_UPDATE = 5'b10_000,
                          specARL_IND = 5'b10_010,
                          specMTR_CTL = 5'b10_011,
                          specFLAG_CTL = 5'b10_100,
                          specSAVE_FLAGS = 5'b10_101,
                          specSP_MEM_CYCLE = 5'b10_110,
                          specAD_LONG = 5'b10_111
                          } tSPEC;


typedef enum logic [0:2] {
                          acbPAGB = 3'b110,
                          acbMICROB = 3'b111
                          } tACB;

typedef enum logic [0:5] {
                          acopACplusMAGIC = 6'b000_110,
                          acopMAGIC = 6'b011_010,
                          acopOR_ACnumber = 6'b011_011
                          } tAC_OP;


typedef enum logic [0:3] {
                          clrNOP = 4'b0_000,
                          clrARR = 4'b0_001,
                          clrARL = 4'b0_010,
                          clrAR = 4'b0_011,
                          clrARX = 4'b0_100,
                          clrARLplusARX = 4'b0_110,
                          clrARplusARX = 4'b0_111,

                          clrMQ = 4'b1_000,
                          clrARRplusMQ = 4'b1_001,
                          clrARplusMQ = 4'b1_011,
                          clrARXplusMQ = 4'b1_100,
                          clrARLplusARXlusMQ = 4'b1_110,
                          clrARplusARXplusMQ = 4'b1_111
                          } tCLR;

typedef enum logic [0:2] {
                          arlARL = 3'b000,
                          arlCACHE = 3'b001,
                          arlAD = 3'b010,
                          arlEBUS = 3'b011,
                          arlSH = 3'b100,
                          arlADx2 = 3'b101,
                          arlADX = 3'b110,
                          arlADdiv4 = 3'b111
                          } tARL;

typedef enum logic [0:2] {
                          arctlNOP = 3'b000,
                          arctlARR_LOAD = 3'b001,
                          arctlAR9_17 = 3'b010,
                          arctlAR0_8 = 3'b100,
                          arctlARL_LOAD = 3'b110
                          } tAR_CTL;

typedef enum logic [0:1] {
                          mqctlMQ = 2'b00,
                          mqctlMQx2 = 2'b01,
                          mqctlMQdiv2 = 2'b10,
                          mqctlZEROS = 2'b11
                          } tMQ_CTL;

typedef enum logic [0:8] {
                          pcflagsNONE = 9'b000_000_000,
                          pcflagsOVERF = 9'b100_000_000,
                          pcflagsFLOVERF = 9'b010_000_000,
                          pcflagsFPD = 9'b001_000_000,
                          pcflagsTRAP2 = 9'b000_100_000,
                          pcflagsTRAP1 = 9'b000_010_000,
                          pcflagsEXPUND = 9'b000_001_000,
                          pcflagsNO_DIV = 9'b000_000_100,
                          pcflagsAROV = 9'b100_010_000,
                          pcflagsFLOV = 9'b110_010_000,
                          pcflagsFXU = 9'b110_011_000,
                          pcflagsDIV_CHK = 9'b100_010_100,
                          pcflagsFDV_CHK = 9'b110_010_100
                          } tPC_FLAGS;

typedef enum logic [0:8] {
                          flagctlNOP = 9'b000_000_000,
                          flagctlRSTR_FLAGS = 9'b100_010_000,
                          flagctlJFCL = 9'b110_000_010,
                          flagctlJFCLplusLD = 9'b110_010_010,
                          flagctlDISMISS = 9'b100_000_010,
                          flagctlDISMISSplusLD = 9'b101_010_010,
                          flagctlHALT = 9'b100_100_010,
                          flagctlSET_FLAGS = 9'b000_000_010,
                          flagctlPORTAL = 9'b100_001_010
                          } tFLAG_CTL;

typedef enum logic [0:8] {
                          specinstrSET_PI_CYCLE = 9'b111_001_100,
                          specinstrKERNEL_CYCLE = 9'b010_000_000,
                          specinstrINH_PCplus1 = 9'b001_000_000,
                          specinstrSXCT = 9'b000_100_000,
                          specinstrPXCT = 9'b000_010_000,
                          specinstrINTRPT_INH = 9'b000_001_000,
                          specinstrINSTR_ABORT = 9'b000_000_100,
                          specinstrHALTED = 9'b011_000_010,
                          specinstrCONS_XCT = 9'b011_001_000,
                          specinstrCONT = 9'b000_000_000
                          } tSPEC_INSTR;

typedef enum logic [0:8] {
                          fetchUNCOND = 9'b100_000_000,
                          fetchCOMP = 9'b010_000_000,
                          fetchSKIP = 9'b010_000_010,
                          fetchTEST = 9'b010_000_011,
                          fetchJUMP = 9'b101_000_010,
                          fetchJFCL = 9'b101_000_011
                          } tFETCH;

typedef enum logic [0:8] {
                          eacalcLOAD_AR = 9'b100_000_000,
                          eacalcLOAD_ARX = 9'b010_000_000,
                          eacalcPAUSE = 9'b001_000_000,
                          eacalcWRITE = 9'b000_100_000,
                          eacalcPREV_EN = 9'b000_010_000,
                          eacalcINDIRECT = 9'b000_001_000,
                          eacalcEA = 9'b000_000_010,
                          eacalcSTACK = 9'b000_000_001,
                          eacalcA_IND = 9'b010_011_000,
                          eacalcBYTE_LD = 9'b100_010_000,
                          eacalcBYTE_RD = 9'b110_010_000,
                          eacalcBYTE_RD_PCorPOP_AR_ARX = 9'b110_010_001,
                          eacalcBYTE_RPW = 9'b111_110_000,
                          eacalcBYTE_IND = 9'b110_001_000,
                          eacalcPUSH = 9'b000_100_001,
                          eacalcPOP_AR = 9'b100_010_001,
                          eacalcPOP_ARX = 9'b010_010_001,
                          eacalcWRITE_E = 9'b000_100_010,
                          eacalcWRITE_EA = 9'b100_000_010,
                          eacalcLD_AR_EA = 9'b100_100_010,
                          eacalcLD_ARplusWR = 9'b100_100_000,
                          eacalcLD_ARXplusWR = 9'b010_100_000
                          } tEA_CALC;


typedef enum logic [0:8] {
                          spmemFETCH = 9'b100_000_000,
                          spmemUSER = 9'b010_000_000,
                          spmemEXEC = 9'b001_000_000,
                          spmemSEC_0 = 9'b000_100_000,
                          spmemUPT_EN = 9'b000_010_000,
                          spmemEPT_EN = 9'b000_001_000,
                          spmemCACHE_INC = 9'b000_000_010,
                          spmemUNCSHplusUNPAGE = 9'b001_000_011,
                          spmemUNPAGEDplusCACHED = 9'b001_000_001,
                          spmemEPT = 9'b001_001_011,
                          spmemEPT_CACHE = 9'b001_001_001,
                          spmemEPT_FETCH = 9'b101_001_011,
                          spmemUPT = 9'b010_010_011,
                          spmemUPT_FETCH = 9'b110_010_011,
                          spmemPT = 9'b000_011_011,
                          spmemPT_FETCH = 9'b100_100_011
                          } tSP_MEM;

typedef enum logic [0:8] {
                          mregfncSBUS_DIAG = 9'b100_000_111,
                          mregfncREAD_UBR = 9'b101_000_010,
                          mregfncREAD_EBR = 9'b101_000_011,
                          mregfncREAD_ERA = 9'b101_000_100,
                          mregfncWR_REFILL_RAM = 9'b101_000_101,
                          mregfncLOAD_CCA = 9'b110_000_110,
                          mregfncLOAD_UBR = 9'b110_000_010,
                          mregfncLOAD_EBR = 9'b110_000_011,
                          mregfncMAP = 9'b001_100_000
                          } tMREG_FNC;

typedef enum logic [0:8] {
                          mboxctlSET_PAGE_FAIL = 9'b010_000_000,
                          mboxctlSET_IO_PF_ERR = 9'b001_000_000,
                          mboxctlCLR_PT_LINE_NK = 9'b000_110_001,
                          mboxctlPT_DIR_CLR_NK = 9'b000_100_001,
                          mboxctlCLR_PT_LINE = 9'b000_011_001,
                          mboxctlPT_DIR_WR = 9'b000_010_000,
                          mboxctlPT_WR = 9'b000_001_000,
                          mboxctlPT_DIR_CLR = 9'b000_000_001,
                          mboxctlNORMAL = 9'b000_000_000
                          } tMBOX_CTL;

typedef enum logic [0:2] {
                          mtrctlCLR_TIME = 3'b000,
                          mtrctlCLR_PERF = 3'b001,
                          mtrctlCLR_E_CNT = 3'b010,
                          mtrctlCLR_M_CNT = 3'b011,
                          mtrctlLD_PA_LH = 3'b100,
                          mtrctlLD_PA_RH = 3'b101,
                          mtrctlCONO_MTR = 3'b110,
                          mtrctlCONO_TIM = 3'b111
                          } tMTR_CTL;

// ;I/O FUNCTIONS

typedef enum logic [0:8] {
                          ebusctlGRAB_EEBUS = 9'b100_000_000,
                          ebusctlREQ_EBUS = 9'b010_000_000,
                          ebusctlREL_EBUS = 9'b001_000_000,
                          ebusctlEBUS_DEMAND = 9'b000_110_000,
                          ebusctlEBUS_NODEMAND = 9'b000_010_000,
                          ebusctlCTL_IR = 9'b000_001_000,
                          ebusctlDISABLE_CS = 9'b000_000_100,
                          ebusctlDATAIO = 9'b000_000_010,
                          ebusctlINPUT = 9'b000_000_001,
                          ebusctlIO_INIT = 9'b000_011_000,
                          ebusctlDATAO = 9'b000_010_110,
                          ebusctlDATAI = 9'b000_010_111,
                          ebusctlREL_EEBUS = 9'b000_000_000
                          } tEBUS_CTL;

typedef enum logic [0:8] {
                          diagfunc500_NS = 9'b100_000_000,
                          diagfuncLD_PA_LEFT = 9'b100_000_100,
                          diagfuncLD_PA_RIGHT = 9'b100_000_101,
                          diagfuncCONO_MTR = 9'b100_000_110,
                          diagfuncCONO_TIM = 9'b100_000_111,
                          diagfuncCONO_APR = 9'b100_001_100,
                          diagfuncCONO_PI = 9'b100_001_101,
                          diagfuncCONO_PAG = 9'b100_001_110,
                          diagfuncDATAO_APR = 9'b100_001_111,
                          diagfuncDATAO_PAG = 9'b110_010_000,
                          diagfuncLD_AC_BLKS = 9'b100_010_101,
                          diagfuncLD_PCSplusCWSX = 9'b100_010_110,
                          diagfuncCONI_PI_R = 9'b101_000_000,
                          diagfuncCONI_PI_L = 9'b101_000_001,
                          diagfuncRD_TIME = 9'b101_010_000,
                          diagfuncDATAI_PAG_LorRD_PERF_CNT = 9'b101_001_001,
                          diagfuncCONI_APR_LorRD_EBOX_CNT = 9'b101_001_010,
                          diagfuncDATAI_APRorRD_CACHE_CNT = 9'b101_001_011,
                          diagfuncRD_INTRVL = 9'b101_001_100,
                          diagfuncRD_PERIOD = 9'b101_001_101,
                          diagfuncCONI_MTR = 9'b101_001_110,
                          diagfuncRD_MTR_REQ = 9'b101_001_111,
                          diagfuncCONI_PI_PAR = 9'b101_011_000,
                          diagfuncCONI_PAG = 9'b101_011_001,
                          diagfuncRD_EBUS_REG = 9'b101_110_111
                          } tDIAG_FUNC;

typedef struct packed {
  logic u0;
  tJ J;
  tAD AD;
  tADA ADA;
  logic u21;
  tADB ADB;
  tAR AR;
  tARX ARX;
  tBR BR;
  tBRX BRX;
  tMQ MQ;
  tFMADR FMADR;
  tSCAD SCAD;
  tSCADA SCADA;
  logic u42;
  tSCADB SCADB;
  logic u45;
  tSC SC;
  tFE FE;
  logic u48;
  tSH SH;
  logic u51;
  tVMA VMA;
  tTIME _TIME;
  tMEM MEM;
  tCOND COND;
  logic CALL;
  tDISP DISP;
  logic [72:73] u73;
  logic MARK;
  tMAGIC MAGIC;
} tCRAM;

interface iCRAM;
  tJ J;
  tAD AD;
  tADA ADA;
  tADB ADB;
  tAR AR;
  tARX ARX;
  tBR BR;
  tBRX BRX;
  tMQ MQ;
  tFMADR FMADR;
  tSCAD SCAD;
  tSCADA SCADA;
  tSCADB SCADB;
  tSC SC;
  tFE FE;
  tSH SH;
  tVMA VMA;
  tTIME _TIME;
  tMEM MEM;
  tCOND COND;
  logic CALL;
  tDISP DISP;
  logic MARK;
  tMAGIC MAGIC;
endinterface


////////////////////////////////////////////////////////////////
// Modules
interface iAPR;
  logic CLK;
  logic CONO_OR_DATAO;
  logic CONI_OR_DATAI;
  logic EBUS_RETURN;
  logic PT_DIR_WR;
  logic PT_WR;
  logic WR_PT_SEL_0;
  logic WR_PT_SEL_1;
  logic FM_ODD_PARITY;
  logic APR_PAR_CHK_EN;
  logic SET_PAGE_FAIL;
  logic FM_BIT_36;
  logic FETCH_COMP;
  logic WRITE_COMP;
  logic READ_COMP;
  logic USER_COMP;
  logic FM_EXTENDED;
  logic APR_INTERRUPT;
  logic NXM_ERR;
  logic SBUS_ERR;
  logic EBOX_CCA;
  logic EBOX_ERA;
  logic EBOX_EBR;
  logic EBOX_UBR;
  logic EN_REFILL_RAM_WR;
  logic SWEEP_BUSY;
  logic MB_PAR_ERR;
  logic C_DIR_P_ERR;
  logic SET_IO_PF_ERR;
  logic WR_BAD_ADR_PAR;
  logic ANY_EBOX_ERR_FLG;
  logic EBOX_LOAD_REG;
  logic EBOX_SBUS_DIAG;
  logic EBOX_READ_REG;
  logic EBOX_SPARE;
  logic EBOX_SEND_F02;

  logic EBUS_F01;
  logic EBUS_REQ;
  logic EBUS_DEMAND;
  logic EBUS_DISABLE_CS;

  logic [3:6] MBOX_CTL;
  logic SPARE;
  logic [9:12] AC;
  logic [0:2] FM_BLOCK;
  logic [0:3] FM_ADR;
  logic [0:2] XR_BLOCK;
  logic [0:2] VMA_BLOCK;
  logic [0:2] PREV_BLOCK;
  logic [0:2] CURRENT_BLOCK;
  tEBUSdriver EBUSdriver;
endinterface


interface iCLK;
  logic RESET;
  logic MR_RESET;
  logic MAIN_SOURCE;
  logic EBOX_SOURCE;
  logic EBUS_CLK_SOURCE;
  logic MHZ16_FREE;

  logic CRM;
  logic CRA;
  logic EDP;
  logic APR;
  logic CON;
  logic VMA;
  logic MCL;
  logic IR;
  logic SCD;

  logic MBOX;
  logic CCL;
  logic CRC;
  logic CHC;
  logic MB_06;
  logic MB_12;
  logic CCW;
  logic MB_00;
  logic MBC;
  logic MBX;
  logic MBZ;
  logic MBOX_13;
  logic MBOX_14;
  logic MTR;
  logic CLK_OUT;
  logic PI;
  logic PMA;
  logic CHX;
  logic CSH;

  logic CLK;
  logic DELAYED;

  logic [0:1] SOURCE_SEL;
  logic [0:1] RATE_SEL;

  logic RATE_SELECTED;

  logic EBOX_CLK;
  logic MBOX_CLK;
  logic SBUS_CLK;
  logic EBUS_CLK;

  logic EBOX_SYNC;
  logic MBOX_WAIT;

  logic EBOX_REQ;
  logic MB_XFER;
  logic MBOX_RESP;
  logic EBOX_CYC_ABORT;

  logic BURST_CNTeq0;

  logic ODD;
  logic GATED_EN;
  logic GATED;
  logic ERR_STOP_EN;
  logic ERROR_STOP;

  logic _1777_EN;
  logic FORCE_1777;
  logic INSTR_1777;
  logic PAGE_FAIL;
  logic PF_DLYD;
  logic PF_DLYD_A;
  logic PF_DLYD_B;
  
  logic SYNC;
  logic SYNC_EN;
  logic EBOX_SRC_EN;
  logic EBOX_CLK_EN;

  logic EBOX_CLK_ERROR;

  logic MBOX_CYCLE_DIS;
  logic EBOX_CRM_DIS;
  logic EBOX_EDP_DIS;
  logic EBOX_CTL_DIS;

  logic [7:10] PF_DISP;

  logic DRAM_PAR_ERR;
  logic CRAM_PAR_ERR;
  logic FM_PAR_ERR;

  logic CRAM_PAR_CHECK;
  logic DRAM_PAR_CHECK;
  logic FM_PAR_CHECK;

  logic FM_ODD_PARITY;

  logic ERROR;
  logic ERROR_HOLD_A;
  logic ERROR_HOLD_B;

  logic PAGE_FAIL_EN;

  logic FS_ERROR;
  logic FS_CHECK;
  logic FS_EN_A;
  logic FS_EN_B;
  logic FS_EN_C;
  logic FS_EN_D;
  logic FS_EN_E;
  logic FS_EN_F;
  logic FS_EN_G;

  logic SYNC_HOLD;
  logic FUNC_GATE;
  logic FUNC_START;
  logic FUNC_BURST;
  logic FUNC_SET_RESET;
  logic FUNC_EBOX_SS;
  logic FUNC_SINGLE_STEP;

  logic FUNC_042;
  logic FUNC_043;
  logic FUNC_044;
  logic FUNC_045;
  logic FUNC_046;
  logic FUNC_047;
  
  logic GO;
  logic BURST;
  logic EBOX_SS;
  logic FUNC_COND_SS;
  logic TENELEVEN_CLK;

  logic PT_DIR_WR;
  logic PT_WR;

  logic CLK_ON;
  logic SOURCE_DELAYED;
  logic FUNC_CLR_RESET;
  logic EBUS_RESET;
  logic PAGE_ERROR;
  logic RESP_MBOX;
  logic RESP_SIM;
  logic SBR_CALL;
  logic CLR_PRIVATE_INSTR;
  tEBUSdriver EBUSdriver;
endinterface


interface iCON;
  
  logic START;
  logic RUN;
  logic RESET;
  logic EBOX_HALTED;

  logic KL10_PAGING_MODE;
  logic KI10_PAGING_MODE;

  logic COND_EN_00_07;
  logic COND_EN_10_17;
  logic COND_EN_20_27;
  logic COND_EN_30_37;
  logic SKIP_EN_40_47;
  logic SKIP_EN_50_57;
  logic SKIP_EN_60_67;
  logic SKIP_EN_70_77;

  logic DISP_EN_00_03;
  logic DISP_EN_00_07;
  logic DISP_EN_30_37;

  logic COND_PCF_MAGIC;
  logic COND_FE_SHRT;
  logic COND_AD_FLAGS;
  logic COND_SEL_VMA;
  logic COND_SPEC_INSTR;
  logic COND_DIAG_FUNC;
  logic COND_EBUS_CTL;
  logic COND_MBOX_CTL;
  logic COND_024;
  logic COND_026;
  logic COND_027;
  logic COND_FM_WRITE;
  logic COND_EBOX_STATE;
  logic COND_SR_MAGIC;
  logic COND_VMA_MAGIC;
  logic COND_VMA_INC;
  logic COND_VMA_DEC;
  logic COND_LONG_EN;
  logic COND_LOAD_VMA_HELD;
  logic COND_INSTR_ABORT;
  logic COND_ADR_10;
  logic COND_LOAD_IR;
  logic COND_EBUS_STATE;
  logic COND_VMAX_MAGIC;

  logic LOAD_AC_BLOCKS;
  logic LOAD_PREV_CONTEXT;
  logic LONG_EN;
  logic PI_CYCLE;
  logic PCplus1_INH;
  logic MB_XFER;
  logic FM_XFER;
  logic CACHE_LOOK_EN;
  logic LOAD_ACCESS_COND;
  logic LOAD_DRAM;
  logic LOAD_IR;

  logic AR_FROM_EBUS;
  logic AR_LOADED;
  logic ARX_LOADED;

  logic FM_WRITE00_17;
  logic FM_WRITE18_35;
  logic FM_WRITE_PAR;

  logic IO_LEGAL;
  logic EBUS_GRANT;
  logic MBOX_WAIT;

  logic CONO_PI;
  logic CONO_PAG;
  logic CONO_APR;
  logic DATAO_APR;
  logic CONO_200000;

  logic SEL_EN;
  logic SEL_DIS;
  logic SEL_CLR;
  logic SEL_SET;

  logic UCODE_STATE1;
  logic UCODE_STATE3;
  logic UCODE_STATE5;
  logic UCODE_STATE7;

  logic PI_DISABLE;
  logic CLR_PRIVATE_INSTR;
  logic TRAP_EN;
  logic NICOND_TRAP_EN;
  logic [7:10] NICOND;
  logic [0:3] SR;
  logic LOAD_SPEC_INSTR;
  logic [0:1] VMA_SEL;

  logic WR_EVEN_PAR_ADR;
  logic DELAY_REQ;
  logic AR_36;
  logic ARX_36;
  logic CACHE_LOAD_EN;
  logic EBUS_REL;
  tEBUSdriver EBUSdriver;
endinterface


interface iCRA;
  tCRADR CRADR;
  logic [1:10] AREAD;
  logic DISP_PARITY;
  tEBUSdriver EBUSdriver;
endinterface


interface iCRM;
  logic PAR_16;
endinterface


interface iCTL;
  logic AR00to08_LOAD;
  logic AR09to17_LOAD;
  logic ARR_LOAD;
  logic [0:2] ARL_SEL;
  logic [0:2] ARR_SEL;
  logic [0:2] ARXL_SEL;
  logic [0:2] ARXR_SEL;
  logic ARX_LOAD;
  logic [0:8] REG_CTL;
  logic [0:1] MQ_SEL;
  logic [0:1] MQM_SEL;
  logic MQM_EN;
  logic adToEBUS_L;
  logic adToEBUS_R;
  logic DISP_NICOND;
  logic DISP_RET;
  logic SPEC_SCM_ALT;
  logic SPEC_MTR_CTL;
  logic SPEC_CLR_FPD;
  logic SPEC_FLAG_CTL;
  logic SPEC_SP_MEM_CYCLE;
  logic SPEC_SAVE_FLAGS;
  logic SPEC_INH_CRY_18;
  logic SPEC_ADX_CRY_36;
  logic SPEC_GEN_CRY_18;
  logic SPEC_ARL_IND;
  logic SPEC_CALL;
  logic SPEC_SBR_CALL;
  logic SPEC_XCRY_AR0;
  logic SPEC_AD_LONG;
  logic SPEC_MQ_SHIFT;
  logic SPEC_LOAD_PC;
  logic SPEC_STACK_UPDATE;
  logic AD_LONG;
  logic AD_CRY_36;
  logic ADX_CRY_36;
  logic INH_CRY_18;
  logic GEN_CRY_18;
  logic COND_REG_CTL;
  logic COND_AR_EXP;
  logic COND_ARR_LOAD;
  logic COND_ARLR_LOAD;
  logic COND_ARLL_LOAD;
  logic COND_AR_CLR;
  logic COND_ARX_CLR;
  logic ARL_IND;
  logic [0:1] ARL_IND_SEL;
  logic MQ_CLR;
  logic AR_CLR;
  logic AR00to11_CLR;
  logic AR12to17_CLR;
  logic ARR_CLR;
  logic ARX_CLR;
  logic CONSOLE_CONTROL;
  logic DIAG_CTL_FUNC_00x;
  logic DIAG_CTL_FUNC_01x;
  logic DIAG_LD_FUNC_04x;
  logic DIAG_LOAD_FUNC_06x;
  logic DIAG_LOAD_FUNC_07x;
  logic DIAG_LOAD_FUNC_072;
  logic DIAG_LD_FUNC_073;
  logic DIAG_LD_FUNC_074;
  logic DIAG_SYNC_FUNC_075;
  logic DIAG_LD_FUNC_076;
  logic DIAG_CLK_EDP;
  logic DIAG_READ_FUNC_11x;
  logic DIAG_READ_FUNC_12x;
  logic DIAG_READ_FUNC_13x;
  logic DIAG_READ_FUNC_14x;
  logic DIAG_READ_FUNC_15x;
  logic DIAG_READ_FUNC_16x;
  logic DIAG_READ_FUNC_17x;
  logic PI_CYCLE_SAVE_FLAGS;
  logic LOAD_PC;
  logic DIAG_STROBE;
  logic DIAG_READ;
  logic DIAG_AR_LOAD;
  logic DIAG_LD_EBUS_REG;
  logic EBUS_XFER;
  logic AD_TO_EBUS_L;
  logic AD_TO_EBUS_R;
  logic EBUS_T_TO_E_EN;
  logic EBUS_E_TO_T_EN;
  logic EBUS_PARITY_OUT;
  logic DIAG_FORCE_EXTEND;
  logic diaFunc051;
  logic diaFunc052;
  logic DIAG_CHANNEL_CLK_STOP;
  logic [0:6] DIAG;
  tEBUSdriver EBUSdriver;
endinterface


interface iEDP;
  logic [-2:35] AD;
  logic [0:35] ADX;
  logic [0:35] BR;
  logic [0:35] BRX;
  logic [0:35] MQ;
  logic [0:35] AR;
  logic [0:35] ARX;
  logic [-2:35] AD_EX;
  logic [-2:36] AD_CRY;
  logic [0:36] ADX_CRY;
  logic [0:35] AD_OV;
  logic GEN_CRY_36;
  logic DIAG_READ_FUNC_10x;
  logic [0:35] FM;
  logic FM_PARITY;
  logic FM_WRITE;
  tEBUSdriver EBUSdriver;
endinterface


interface iIR;
  logic IO_LEGAL;
  logic ADeq0;
  logic ACeq0;
  logic JRST0;
  logic TEST_SATISFIED;

  logic [8:10] NORM;
  logic [0:12] IR;
  logic [9:12] IRAC;
  logic [0:2] DRAM_A;
  logic [0:2] DRAM_B;
  logic [0:10] DRAM_J;
  logic DRAM_ODD_PARITY;
  tEBUSdriver EBUSdriver;
endinterface


interface iMCL;
  logic _18_BIT_EA;
  logic _23_BIT_EA;
  logic LOAD_AR;
  logic STORE_AR;
  logic LOAD_ARX;
  logic LOAD_VMA;
  logic MBOX_CYC_REQ;
  logic PAGED_FETCH;
  logic MEM_ARL_IND;
  logic SHORT_STACK;
  logic SKIP_SATISFIED;
  logic PC_SECTION_0;
  logic EBOX_MAP;
  logic EBOX_CACHE;
  logic REQ_EN;
  logic MEM_REG_FUNC;
  logic VMA_AD;
  logic VMA_ADR_ERR;
  logic VMA_INC;
  logic VMA_FETCH;
  logic VMA_EXTENDED;
  logic VMA_SECTION_0;
  logic VMA_SECTION_01;
  logic VMA_READ_OR_WRITE;
  logic VMAX_EN;
  logic VMA_PAUSE;
  logic VMA_WRITE;
  logic VMA_PREV_EN;
  logic LOAD_VMA_CONTEXT;
  logic VMA_USER;
  logic VMA_PUBLIC;
  logic VMA_PREVIOUS;
  logic XR_PREVIOUS;
  logic [0:1] VMAX_SEL;
  logic LOAD_VMA_HELD;
  logic PAGE_UEBR_REF;
  logic PAGE_UEBR_REF_A;
  logic [27:33] VMA_G;
  logic ADR_ERR;
  tEBUSdriver EBUSdriver;
endinterface


interface iMTR;
  logic INTERRUPT_REQ;
  tEBUSdriver EBUSdriver;
endinterface


interface iPI;
  logic GATE_TTL_TO_ECL;
  logic EBUS_CP_GRANT;
  logic EXT_TRAN_REC;
  logic READY;
  logic [0:2] PI;
  logic [0:2] APR_PIA;
  tEBUSdriver EBUSdriver;
endinterface


interface iSCD;
  logic SC_GE_36;
  logic SC_36_TO_63;
  logic [0:8] ARMM_UPPER;
  logic [13:17] ARMM_LOWER;
  logic [0:9] FE;
  logic [0:9] SC;
  logic [0:35] SCADA;
  logic [0:35] SCADB;
  logic SCADeq0;
  logic SCAD_SIGN;
  logic SC_SIGN;
  logic FE_SIGN;
  logic OV;
  logic CRY0;
  logic CRY1;
  logic FOV;
  logic FXU;
  logic FPD;
  logic PCP;
  logic DIV_CHK;
  logic TRAP_REQ_1;
  logic TRAP_REQ_2;
  logic TRAP_CYC_1;
  logic TRAP_CYC_2;
  logic [32:35] TRAP_MIX;
  logic KERNEL_MODE;
  logic USER;
  logic USER_IOT;
  logic KERNEL_USER_IOT;
  logic PUBLIC;
  logic PUBLIC_EN;
  logic PRIVATE;
  logic PRIVATE_INSTR;
  logic ADR_BRK_PREVENT;
  logic ADR_BRK_INH;
  logic ADR_BRK_CYC;
  tEBUSdriver EBUSdriver;
endinterface


interface iSHM;
  logic [0:35] SH;
  logic [0:35] XR;
  logic AR_PAR_ODD;
  logic INDEXED;
  logic AR_EXTENDED;
  logic ARX_PAR_ODD;
  tEBUSdriver EBUSdriver;
endinterface


interface iVMA;
  logic LOCAL_AC_ADDRESS;
  logic AC_REF;
  logic [12:35] PC;
  logic [12:35] VMA;
  logic [12:35] ADR_BRK;
  logic [12:17] PREV_SEC;
  logic [12:35] HELD;
  logic [0:35] HELD_OR_PC;
  logic PC_SECTION_0;
  logic PCS_SECTION_0;
  logic VMA_SECTION_0;
  logic LOAD_PC;
  logic LOAD_VMA_HELD;
  logic MATCH_13_35;
  tEBUSdriver EBUSdriver;
endinterface

`endif
