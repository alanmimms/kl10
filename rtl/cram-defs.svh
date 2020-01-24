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
      //`adfBOOLEAN FUNCTIONS FOR WHICH CRY0 IS INTERESTING
      adCRY_A_EQ_minus1 =`adfCARRY |`adfBOOLEAN | 6'b000_000, // GENERATE CRY0 IF A = 1S, AD=SETCA
//    adCRY_AandB_NE_0 =`adfBOOLEAN | 6'b001_110,             // CRY 0 IF A&B NONZERO, AD=AND
//    adCRY_A_NE_0 =`adfBOOLEAN | 6'b001_111,                 // GENERATE CRY0 IF A .NE. 0, AD=A
      adCRY_A_GE_B =`adfCARRY |`adfBOOLEAN | 6'b001_001       // CRY0 IF A .GE. B, UNSIGNED; AD=XOR
      } tCRAM_AD;

`endif
