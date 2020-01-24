`ifndef _CRAM_DEFS_
 `define _CRAM_DEFS_ 1

// CRAM_AD flag bits
 `define adfCARRY 6'b100_000
 `define adfBOOLEAN 6'b010_000


typedef enum logic [0:5] {
                          // CRAM_AD values
                          // ADDER LOGICAL FUNCTIONS
                          adSETCA =`adfBOOLEAN | 6'b000_000,
                          adORC =`adfBOOLEAN | 6'b000_001,      // NAND
                          adORCA =`adfBOOLEAN | 6'b000_010,
                          adONES =`adfBOOLEAN | 6'b000_011,
                          adNOR =`adfBOOLEAN | 6'b000_100,
                          //      adANDC =`adfBOOLEAN | adNOR,
                          adSETCB =`adfBOOLEAN | 6'b000_101,
                          adEQV =`adfBOOLEAN | 6'b000_110,
                          adORCB =`adfBOOLEAN | 6'b000_111,
                          adANDCA =`adfBOOLEAN | 6'b001_000,
                          adXOR =`adfBOOLEAN | 6'b001_001,
                          adB =`adfBOOLEAN | 6'b001_010,
                          adOR =`adfBOOLEAN | 6'b001_011,
                          adZEROS =`adfBOOLEAN | 6'b001_100,
                          adANDCB =`adfBOOLEAN | 6'b001_101,
                          adAND =`adfBOOLEAN | 6'b001_110,
                          adA =`adfBOOLEAN | 6'b001_111,
                          // ADDER ARITHMETIC FUNCTIONS
                          adAplus1 =`adfCARRY | 6'b000_000,
                          adAplusXCRY = 6'b000_000,
                          adAplusANDCB = 6'b000_001,
                          adAplusAND = 6'b000_010,
                          adA__2 = 6'b000_011,
                          adA__2plus1 =`adfCARRY | adA__2,
                          adORplus1 =`adfCARRY | 6'b000_100,
                          adORplusANDCB = 6'b000_101,
                          adAplusB = 6'b000_110,
                          adAplusBplus1 =`adfCARRY | adAplusB,
                          adAplusOR = 6'b000_111,
                          adORCBplus1 =`adfCARRY | adORCB,
                          adAminusBminus1 = 6'b001_001,
                          adAminusB =`adfCARRY | adAminusBminus1,
                          adANDplusORCB =`adfCARRY | 6'b001_010,
                          adAplusORCB =`adfCARRY | 6'b001_011,
                          adXCRYminus1 =`adfCARRY | 6'b001_100,
                          adANDCBminus1 = 6'b001_101,
                          adANDminus1 = 6'b001_110,
                          adAminus1 = 6'b001_111,
                          // BOOLEAN FUNCTIONS FOR WHICH CRY0 IS INTERESTING
                          adCRY_A_EQ_minus1 =`adfCARRY |`adfBOOLEAN | 6'b000_000,
                          adCRY_A_GE_B =`adfCARRY |`adfBOOLEAN | 6'b001_001
                          } tCRAM_AD;

typedef enum logic [0:1] {
	                  adaAR=3'b000,
	                  adaARX=3'b001,
	                  adaMQ=3'b010,
	                  adaPC=3'b011
                          } tCRAM_ADA;
typedef enum logic {
                    adaEnable = 1'b0,
	            adaZEROS=1'b1
                    } tCRAM_ADA_EN;

typedef enum logic [0:1] {
                          adbFM = 2'b00,
                          adbBRx2 = 2'b01,
                          adbBR = 2'b10,
                          adbARx4 = 2'b11
                          } tCRAM_ADB;

typedef enum logic [0:2] {
                          arAR = 3'b000, // also arARMM, arMEM
                          arCACHE = 3'b001,
                          arAD = 3'b010,
                          arEBUS = 3'b011,
                          arSH = 3'b100,
                          arADx2 = 3'b101,
                          arADX = 3'b110,
                          arADdiv4 = 3'b111
                          } tCRAM_AR;

typedef enum logic [0:2] {
                          arxARX = 3'b000, // Also MEM
                          arxCACHE = 3'b001,
                          arxAD = 3'b010,
                          arxMQ = 3'b011,
                          arxSH = 3'b100,
                          arxADXx2 = 3'b101,
                          arxADX = 3'b110,
                          arxADXdiv4 = 3'b111
                          } tCRAM_ARX;

typedef enum logic {
                    brRECIRC = 1'b0,
                    brAR = 1'b1
                    } tCRAM_BR;

typedef enum logic {
                    brxRECIRC = 1'b0,
                    brxARX = 1'b1
                    } tCRAM_BRX;

typedef enum logic {
                    mqRECIRC = 1'b0,
                    mqSH = 1'b1
                    } tCRAM_MQ;

typedef enum logic [0:2] {
                          fmadrAC0 = 3'b000,
                          fmadrAC1 = 3'b001,
                          fmadrXR = 3'b010,
                          fmadrVMA = 3'b011,
                          fmadrAC2 = 3'b100,
                          fmadrAC3 = 3'b101,
                          fmadrACplusMAGIC = 3'b110,
                          fmadrMAGIC = 3'b111
                          } tCRAM_FMADR;

typedef enum logic [0:2] {
                          scadA = 3'b000,
                          scadAminusB = 3'b001,
                          scadAplusB = 3'b010,
                          scadAminus1 = 3'b011,
                          scadAplus1 = 3'b100,
                          scadAminusB = 3'b101,
                          scadOR = 3'b110,
                          scadAND = 3'b111
                          } tCRAM_SCAD;

typedef enum logic [0:1] {
                          scadaFE = 1'b00,
                          scadaAR0_5 = 2'b01,
                          scadaAR_EXP = 2'b10,
                          scadaMAGIC = 2'b11
                          } tCRAM_SCADA;

typedef enum logic {
                    scadaEnable = 1'b0,
                    scadaZEROS = 1'b1
                    } tCRAM_SCADA_EN;


typedef enum logic [0:1] {
                          scadbSC = 1'b00,
                          scadbAR6_11 = 2'b01,
                          scadbAR0_8 = 2'b10,
                          scadbMAGIC = 2'b11
                          } tCRAM_SCADB;
                          
typedef enum logic {
                    scRECIRC = 1'b0,
                    scSCAD = 1'b1
                    } tCRAM_SC;

typedef enum logic {
                    feRECIRC = 1'b0,
                    feSCAD = 1'b1
                    } tCRAM_FE;


typedef enum logic [0:1] {
                          shSHIFT_AR_ARX = 2'b00,
                          shAR = 2'b01,
                          shARX = 2'b10,
                          shAR_SWAP = 2'b11
                          } tCRAM_SH;

typedef enum logic [0:1] {
                          armmMAGIC = 2'b00,
                          armmEXP_SIGN = 2'b01,
                          armmSCAD_EXP = 2'b10,
                          armmSCAD_POS = 2'b11
                          } tCRAM_ARMM;

typedef enum logic [0:1] {
                          vmaxVMAX = 2'b00,
                          vmaxPC_SEC = 2'b01,
                          vmaxPREV_SEC = 2'b10,
                          vmaxAD12_17 = 2'b11
                          } tCRAM_VMAX;


typedef enum logic [0:1] {
                          vmaVMA = 2'b00,
                          vmaPC = 2'b01,
                          vmaPCplus1 = 2'b10,
                          vmaAD = 2'b11
                          } tCRAM_VMA;

typedef enum logic [0:1] {
                          time2T = 2'b00,
                          time3T = 2'b01,
                          time4T = 2'b10,
                          time5T = 2'b11
                          } tCRAM_TIME;

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
                          } tCRAM_MEM;

typedef enum logic [0:5] {
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
                          } tCRAM_SKIP;

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
                          } tCRAM_COND;


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
                          } tCRAM_DISP;

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
                          } tCRAM_SPEC;


typedef enum logic [0:2] {
                          adbPAGB = 3'b110,
                          adbMICROB = 3'b111
                          } tCRAM_ACB;

typedef enum logic [0:5] {
                          // ADDER LOGICAL FUNCTIONS
                          acopSETCA =`adfBOOLEAN | 6'b000_000,
                          acopORC =`adfBOOLEAN | 6'b000_001,      // NAND
                          acopORCA =`adfBOOLEAN | 6'b000_010,
                          acopONES =`adfBOOLEAN | 6'b000_011,
                          acopNOR =`adfBOOLEAN | 6'b000_100,
                          //      adANDC =`adfBOOLEAN | adNOR,
                          acopSETCB =`adfBOOLEAN | 6'b000_101,
                          acopEQV =`adfBOOLEAN | 6'b000_110,
                          acopORCB =`adfBOOLEAN | 6'b000_111,
                          acopANDCA =`adfBOOLEAN | 6'b001_000,
                          acopXOR =`adfBOOLEAN | 6'b001_001,
                          acopB =`adfBOOLEAN | 6'b001_010,
                          acopOR =`adfBOOLEAN | 6'b001_011,
                          acopZEROS =`adfBOOLEAN | 6'b001_100,
                          acopANDCB =`adfBOOLEAN | 6'b001_101,
                          acopAND =`adfBOOLEAN | 6'b001_110,
                          acopA =`adfBOOLEAN | 6'b001_111,
                          // ADDER ARITHMETIC FUNCTIONS
                          acopAplusXCRY = 6'b000_000,
                          acopAplusANDCB = 6'b000_001,
                          acopAplusAND = 6'b000_010,
                          acopA__2 = 6'b000_011,
                          acopORplusANDCB = 6'b000_101,
                          acopAplusB = 6'b000_110,
                          acopAplusOR = 6'b000_111,
                          acopAminusBminus1 = 6'b001_001,
                          acopANDCBminus1 = 6'b001_101,
                          acopANDminus1 = 6'b001_110,
                          acopAminus1 = 6'b001_111,

                          acopACplusMAGIC = 5'b00_110,
                          acopMAGIC = 5'b011_010,
                          acopOR_ACnumber = 5'b011_011
                          } tCRAM_AC_OP;


typedef enum logic [0:3] {
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
                          } tCRAM_CLR;

typedef enum logic [0:2] {
                          arlARL = 3'b000,
                          arlCACHE = 3'b001,
                          arlAD = 3'b010,
                          arlEBUS = 3'b011,
                          arlSH = 3'b100,
                          arlADx2 = 3'b101,
                          arlADX = 3'b110,
                          arlADdiv4 = 3'b111
                          } tCRAM_ARL;

typedef enum logic [0:2] {
                          arctlARR_LOAD = 3'b001,
                          arctlAR9_17 = 3'b010,
                          arctlAR0_8 = 3'b100,
                          arctlARL_LOAD = 3'b110
                          } tCRAM_AR_CTL;

typedef enum logic [0:1] {
                          mqctlMQ = 2'b00,
                          mqctlMQx2 = 2'b01,
                          mqctlMQdiv2 = 2'b10,
                          mqctlZEROS = 2'b11
                          } tCRAM_MQ_CTL;

typedef enum logic [0:8] {
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
                          } tCRAM_PC_FLAGS;

typedef enum logic [0:8] {
                          flagctlRSTR_FLAGS = 9'b100_010_000,
                          flagctlJFCL = 9'b110_000_010,
                          flagctlJFCLplusLD = 9'b110_010_010,
                          flagctlDISMISS = 9'b100_000_010,
                          flagctlDISMISSplusLD = 9'b101_010_010,
                          flagctlHALT = 9'b100_100_010,
                          flagctlSET_FLAGS = 9'b000_000_010,
                          flagctlPORTAL = 9'b100_001_010
                          } tCRAM_FLAG_CTL;

typedef enum logic [0:8] {
                          specinstrSET_PI_CYCLE = 9'b111_001_100,
                          specinstrKERNEL_CYCLE = 9'b010_000_000,
                          specinstrINH_PCplus1 = 9'b001_000_000,
                          specinstrSXCT = 9'b000_100_000,
                          specinstrPXCT = 9'b000_010_000
                          specinstrINTRPT_INH = 9'b000_001_000,
                          specinstrINSTR_ABORT = 9'b000_000_100,
                          specinstrHALTED = 9'b011_000_010,
                          specinstrCONS_XCT = 9'b011_001_000,
                          specinstrCONT = 9'b000_000_000
                          } tCRAM_SPEC_INSTR;

typedef enum logic [0:8] {
                          fetchUNCOND = 9'b100_000_000,
                          fetchCOMP = 9'b010_000_000,
                          fetchSKIP = 9'b010_000_010,
                          fetchTEST = 9'b010_000_011,
                          fetchJUMP = 9'b101_000_010,
                          fetchJFCL = 9'b101_000_011
                          } tCRAM_FETCH;

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
                          eacalcBYTE_RD_PC = 9'b110_010_001,
                          eacalcBYTE_RPW = 9'b111_110_000,
                          eacalcBYTE_IND = 9'b110_010_000,
                          eacalcPUSH = 9'b000_100_001,
                          eacalcPOP_AR = 9'b100_010_001,
                          eacalcPOP_ARX = 9'b010_010_001,
                          eacalcPOP_AR_ARX = 9'b110_010_001,
                          eacalcWRITE_E = 9'b000_100_010,
                          eacalcWRITE_EA = 9'b100_000_010,
                          eacalcLD_AR_EA = 9'b100_100_010,
                          eacalcLD_ARplusWR = 9'b100_100_000,
                          eacalcLD_ARXplusWR = 9'b010_100_000
                          } tCRAM_EA_CALC;


typedef enum logic [0:8] {
                          spmemFETCH = 9'b100_000_000,
                          spmemUSER = 9'b010_000_000,
                          spmemEXEC = 9'b001_000_000,
                          spmemSEC_0 = 9'b000_100_000,
                          spmemUPT_EN = 9'b000_010_000,
                          spmemEPT_EN = 9'b000_001_000,
                          spmemCACHE_INC = 9'b000_000_010,
                          spmemUNCSHplusUNPAGE = 9'b001_000_011,
                          spmemUNPAGEDplusCACHED = 9'b001_000_001

                          spmemUNPAGED = 9'b001_000_011,
                          spmemEPT = 9'b001_001_011,
                          spmemEPT_CACHE = 9'b001_001_001,
                          spmemEPT_FETCH = 9'b101_001_011,
                          spmemUPT = 9'b010_010_011,
                          spmemUPT_FETCH = 9'b110_010_011,
                          spmemPT = 9'b000_011_011,
                          spmemPT_FETCH = 9'b100_100_011,
                          } tCRAM_SP_MEM;

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
                          } tCRAM_MREG_FNC;

typedef enum logic [0:8] {
                          mboxctlSET_PAGE_FAIL = 9'b010_000_000,
                          mboxctlSET_IO_PF_ERR = 9'b001_000_000,
                          mboxctlCLR_PT_LINE_NK = 9'b000_110_001,
                          mboxctlPT_DIR_CLR_NK = 9'b000_100_001,
                          mboxctlCLR_PT_LINE = 9'b000_011_001,
                          mboxctlPT_DIR_WR = 9'b000_010_000,
                          mboxctlPT_WR = 9'b000_001_000,
                          mboxctlPT_DIR_CLR = 9'b000_000_001,
                          mboxctlNORMAL = 9'b000_000_000,
                          } tCRAM_MBOX_CTL;

MBOX CTL/=<75:83>	;ENABLED BY COND/MBOX CTL (APR5)
	SET PAGE FAIL=200
	SET IO PF ERR=100
	CLR PT LINE(NK)=61,,1;[333] Clear valid if no Keep bit set
	PT DIR CLR(NK)=41;Enable clear of PT DIR for non keep entries
	CLR PT LINE=31,,1;CLEAR VALID FOR 4 ENTRIES (new pager board) [342]
	PT DIR WR=20,1	;WRITE PAGE TABLE DIRECTORY
	PT WR=10,1	;WRITE PAGE TABLE ENTRY SELECTED BY VMA
	PT DIR CLR=1	;SELECT FOR CLEARING PT DIR (PAG3)
	NORMAL=0	;RESET PT WR SELECTION
MTR CTL/=<81:83>	;FUNCTION DECODING FOR METERS (MTR3)
	CLR TIME=0		; USUALLY USED WITH DIAG FUNC
	CLR PERF=1
	CLR E CNT=2
	CLR M CNT=3
	LD PA LH=4
	LD PA RH=5
	CONO MTR=6
	CONO TIM=7

;I/O FUNCTIONS

EBUS CTL/=<75:83>	;ENABLED BY COND/EBUS CTL (APR3)
	GRAB EEBUS=400	;"EBUS RETURN" TAKES ECL EBUS FOR EBOX
	REQ EBUS=200
	REL EBUS=100	; (CON3)
	EBUS DEMAND=60	;ASSERT DEMAND, KEEP CS, FUNC
	EBUS NODEMAND=20;DROP DEMAND, KEEP CS, FUNC
;	CTL_IR=10	;SELECT F01 & F02 FROM IR
;	DISABLE CS=4	;TURN OFF CONTROLLER SELECT
;	DATAIO=2	;0 FOR CONI/O
;	INPUT=1		;0 FOR OUTPUT
	IO INIT=30	;ENABLE IR3-9 TO EBUS CONTROLLER SELECT,
			; IR10-12 (DECODED) TO FUNCTION
			; AND AR ONTO EBUS IF FUNCTION IS OUTPUT
	DATAO=26	;0'S TO CS, DATAO TO FCN, AND AR TO EBUS
	DATAI=27	;0'S TO CS, DATAI TO FCN
	REL EEBUS=0	;LEGGO
DIAG FUNC/=<75:83>	;ENABLED BY COND/DIAG FUNC (CTL3)
	.5 USEC=400,3		;STRETCH CLOCK TO LET EBUS SETTLE (CON?)
	LD PA LEFT=404,3	;LH PERF ANAL CONTROLS FROM RH (MTR)
	LD PA RIGHT=405,3	;RH PA CONTROLS FROM RH (MTR)
	CONO MTR=406,3		;ACCOUNTING CONTROLS (MTR)
	CONO TIM=407,3		;INTERVAL TIMER CONTROLS (MTR)
	CONO APR=414,3		; (CON3)
	CONO PI=415,3		; (CON3)
	CONO PAG=416,3		;CACHE & PAGING CTL (CON3)
	DATAO APR=417,3		;ADDRESS BREAK (CON3)
	DATAO PAG=620,3		;AC BLOCKS & PREV CONTXT (CON3)
	LD AC BLKS=425,3	;FORCE LOADING AC BLOCKS
	LD PCS+CWSX=426,3	;FORCE LOADING PREV CONTXT SEC, CWSX
	CONI PI(R)=500,3	;PI HOLD & ACTIVE TO LH (PI)
	CONI PI(L)=501,3	;PI GEN TO LH (PI)
	CONI APR(R)=510,3	;APR INTERRUPT & PIA TO LH (APR6)
	RD TIME=510,3		;TIME BASE TO RH (MTR5)
	DATAI PAG(L)=511,3	;AC BLOCKS, PREV CONTXT TO LH (APR6)
	RD PERF CNT=511,3	;PERFORMANCE COUNT TO RH (MTR5)
	CONI APR(L)=512,3	;APR INTERRUPT ENABLES TO LH (APR6)
	RD EBOX CNT=512,3	;EBOX COUNT TO RH (MTR5)
	DATAI APR=513,3		;ADDR BREAK CONDITIONS TO LH (APR6)
	RD CACHE CNT=513,3	;CACHE COUNT TO RH (MTR5)
	RD INTRVL=514,3		;INTERVAL TIMER TO RH (MTR5)
	RD PERIOD=515,3		;PERIOD REGISTER TO RH (MTR5)
	CONI MTR=516,3		;CONTROLS & PIA TO RH (MTR5)
	RD MTR REQ=517,3	;ENCODED UPDATE REQUEST TO 20-22 (MTR5)
	CONI PI(PAR)=530,3	;WRITE EVEN PARITY ENABLES TO RH (CON1)
	CONI PAG=531,3		;CACHE & TRAP CTL TO RH (CON1)
	RD EBUS REG=567,3	;EBUS REGISTER IN MBOX (MBZ1 & MBC1)


`endif
