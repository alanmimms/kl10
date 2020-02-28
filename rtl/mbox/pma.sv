`timescale 1ns/1ns
module pma(iAPR APR,
           iCLK CLK,
           iMBX MBX,
           iVMA VMA,
);

  // PMA1 p.84
  USR4  e5(.S0('0),
           .D(VA[15:18]),
           .S3('0),
           .SEL({2{~(APR.EBOX_UBR & MBX.EBOX_LOAD_REG)}}),
           .Q(UBR[15:18]),
           .CLK(clock));

  USR4 e13(.S0('0),
           .D(VA[19:22]),
           .S3('0),
           .SEL({2{~(APR.EBOX_UBR & MBX.EBOX_LOAD_REG)}}),
           .Q(UBR[19:22]),
           .CLK(clock));

  USR4 e12(.S0('0),
           .D(VA[23:26]),
           .S3('0),
           .SEL({2{~(APR.EBOX_UBR & MBX.EBOX_LOAD_REG)}}),
           .Q(UBR[23:26]),
           .CLK(clock));

  USR4  e3(.S0('0),
           .D(VA[15:18]),
           .S3('0),
           .SEL({2{APR.EBOX_UBR & MBX.EBOX_LOAD_REG}}),
           .Q(EBR[15:18]),
           .CLK(clock));

  USR4  e8(.S0('0),
           .D(VA[19:22]),
           .S3('0),
           .SEL({2{APR.EBOX_UBR & MBX.EBOX_LOAD_REG}}),
           .Q(EBR[19:22]),
           .CLK(clock));

  USR4  e7(.S0('0),
           .D(VA[23:26]),
           .S3('0),
           .SEL({2{APR.EBOX_UBR & MBX.EBOX_LOAD_REG}}),
           .Q(EBR[23:26]),
           .CLK(clock));

  USR4 e20(.S0('0),
           .D({(UBR[14] | APR.EBOX_UBR & MBX.EBOX_LOAD_REG) &
               (VA[14] | ~(APR.EBOX_UBR & MBX.EBOX_LOAD_REG)),
               (EBR[14] | APR.EBOX_EBR & MBX.EBOX_LOAD_REG) &
               (VA[14] | ~(APR.EBOX_EBR & MBX.EBOX_LOAD_REG)),
              (CCA[14] | CCA_LOAD) & (VA[14] & ~CCA_LOAD),
              1'b0}),
           .S3('0),
           .SEL('0),
           .Q({UBR[14], EBR[14], CCA[14]}),
           .CLK(clock));

  mux4x2  e4(.EN('1),
             .SEL(UBR_SEL),
             .D0(EBR[15:18]), 
             .D1(UBR[15:18]),
             .B(UEBR[15:18]));

  mux4x2 e18(.EN('1),
             .SEL(UBR_SEL),
             .D0(EBR[19:22]),
             .D1(UBR[19:22]),
             .B(UEBR[19:22]));

  mux4x2  e2(.EN('1),
             .SEL(UBR_SEL),
             .D0(EBR[23:26]),
             .D1(UBR[23:26]),
             .B(UEBR[23:26]));

  always_comb begin
    UEBR[14] = (UBR_SEL | EBR[14]) & (~UBR_SEL & UBR[14]);
    VA[14:17] = VMA.VMA[14:17];
    VA[18:20] = VMA[18:20];
    VM[21:26] = VMA.VMA[21:26];
    VA_19to27ne7 = ~VMA[19];
  end


  // PMA2 p.85
  // PMA1 p.84
  USR4  e5(.S0('0),
           .D(VA[15:18]),
           .S3('0),
           .SEL({2{~(APR.EBOX_UBR & MBX.EBOX_LOAD_REG)}}),
           .Q(UBR[15:18]),
           .CLK(clock));

  USR4 e13(.S0('0),
           .D(VA[19:22]),
           .S3('0),
           .SEL({2{~(APR.EBOX_UBR & MBX.EBOX_LOAD_REG)}}),
           .Q(UBR[19:22]),
           .CLK(clock));

  USR4 e12(.S0('0),
           .D(VA[23:26]),
           .S3('0),
           .SEL({2{~(APR.EBOX_UBR & MBX.EBOX_LOAD_REG)}}),
           .Q(UBR[23:26]),
           .CLK(clock));

  USR4  e3(.S0('0),
           .D(VA[15:18]),
           .S3('0),
           .SEL({2{APR.EBOX_UBR & MBX.EBOX_LOAD_REG}}),
           .Q(EBR[15:18]),
           .CLK(clock));

  USR4  e8(.S0('0),
           .D(VA[19:22]),
           .S3('0),
           .SEL({2{APR.EBOX_UBR & MBX.EBOX_LOAD_REG}}),
           .Q(EBR[19:22]),
           .CLK(clock));

  USR4  e7(.S0('0),
           .D(VA[23:26]),
           .S3('0),
           .SEL({2{APR.EBOX_UBR & MBX.EBOX_LOAD_REG}}),
           .Q(EBR[23:26]),
           .CLK(clock));

  USR4 e20(.S0('0),
           .D({(UBR[14] | APR.EBOX_UBR & MBX.EBOX_LOAD_REG) &
               (VA[14] | ~(APR.EBOX_UBR & MBX.EBOX_LOAD_REG)),
               (EBR[14] | APR.EBOX_EBR & MBX.EBOX_LOAD_REG) &
               (VA[14] | ~(APR.EBOX_EBR & MBX.EBOX_LOAD_REG)),
              (CCA[14] | CCA_LOAD) & (VA[14] & ~CCA_LOAD),
              1'b0}),
           .S3('0),
           .SEL('0),
           .Q({UBR[14], EBR[14], CCA[14]}),
           .CLK(clock));

  mux4x2  e4(.EN('1),
             .SEL(UBR_SEL),
             .D0(EBR[15:18]), 
             .D1(UBR[15:18]),
             .B(UEBR[15:18]));

  mux4x2 e18(.EN('1),
             .SEL(UBR_SEL),
             .D0(EBR[19:22]),
             .D1(UBR[19:22]),
             .B(UEBR[19:22]));

  mux4x2  e2(.EN('1),
             .SEL(UBR_SEL),
             .D0(EBR[23:26]),
             .D1(UBR[23:26]),
             .B(UEBR[23:26]));

  always_comb begin
    UEBR[14] = (UBR_SEL | EBR[14]) & (~UBR_SEL & UBR[14]);
    VA[14:17] = VMA.VMA[14:17];
    VA[18:20] = VMA[18:20];
    VM[21:26] = VMA.VMA[21:26];
    VA_19to27ne7 = ~VMA[19];
  end


  // PMA2 p.85
  bit e65q2;
  bit e36q15;
  bit unusedE40;
  bit [0:1] unusedE70;
  always_comb begin
    clock = CLK.PMA;
    CCA_LOAD = ~(APR.EBOX_UBR & MBX.EBOX_LOAD_REG);
    e65q2 = ~MBX.CCA_ALL_PAGES_CYC | ~CCA[34] & ~CCA[35];
    e36q15 = &~CCA[30:33];
    PMA.CCA_CRY_OUT = &{e65q2, e36q15, ~CCA[27:29]};
  end
  
  USR4 e10(.S0('0),
           .D(VA[15:18]),
           .S3('0),
           .SEL({2{CCA_LOAD}}),
           .Q(CCA[15:18]),
           .CLK(clock));

  USR4 e24(.S0('0),
           .D(VA[19:22]),
           .S3('0),
           .SEL({2{CCA_LOAD}}),
           .Q(CCA[19:22]),
           .CLK(clock));

  USR4 e28(.S0('0),
           .D(VA[23:26]),
           .S3('0),
           .SEL({2{CCA_LOAD}}),
           .Q(CCA[23:26]),
           .CLK(clock));

  UCR4 e40(.D({1'b0, 3'b111}),
           .CIN(~e36q15),
           .Q({unusedE40, CCA[27:29]}),
           .COUT(),
           .SEL(CCA_SEL),
           .CLK(clock));

  UCR4 e75(.D(4'b1111),
           .CIN(~e65q2),
           .Q({CCA[30:33]}),
           .COUT(),
           .SEL(CCA_SEL),
           .CLK(clock));

  UCR4 e70(.D(4'b0011),
           .CIN('1),
           .Q({unusedE70, CCA[34:35]}),
           .COUT(),
           .SEL(CCA_SEL),
           .CLK(clock));


  // PMA3 p.86
  TODO

  // PMA4 p.87
  TODO

  // PMA5 p.88
  TODO

endmodule // pma
