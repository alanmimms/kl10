`timescale 1ns/1ps

typedef enum bit [0:5] {
                        t0 = 6'h03,
                        t1 = 6'h0A,
                        t2 = 6'h1A,
                        t3 = 6'h1B
} tENUM;

interface INTF;
  tENUM enumField;
  bit [0:5] bitsField;
endinterface


module submod(input [0:3] S, output bit [0:3] notS);
  assign notS = ~S;
endmodule


module mod(INTF intf);
  bit [0:3] notSenum;
  bit [0:3] notSbits;

  submod subEnum(.S(intf.enumField[2:5]), .notS(notSenum));
  submod subBits(.S(intf.bitsField[2:5]), .notS(notSbits));
  
  initial begin

    #10 intf.enumField = t0;
    $display($time, " t0=%06b, S=%04b, notSenum%04b", intf.enumField, intf.enumField[2:5], notSenum);
    
    #10 intf.enumField = t1;
    $display($time, " t1=%06b, S=%04b, notSenum%04b", intf.enumField, intf.enumField[2:5], notSenum);
    
    #10 intf.enumField = t2;
    $display($time, " t2=%06b, S=%04b, notSenum%04b", intf.enumField, intf.enumField[2:5], notSenum);
    
    #10 intf.enumField = t3;
    $display($time, " t3=%06b, S=%04b, notSenum%04b", intf.enumField, intf.enumField[2:5], notSenum);

    $display("");

    #10 intf.bitsField = t0;
    $display($time, " t0=%06b, S=%04b, notSbits%04b", intf.bitsField, intf.bitsField[2:5], notSbits);
    
    #10 intf.bitsField = t1;
    $display($time, " t1=%06b, S=%04b, notSbits%04b", intf.bitsField, intf.bitsField[2:5], notSbits);
    
    #10 intf.bitsField = t2;
    $display($time, " t2=%06b, S=%04b, notSbits%04b", intf.bitsField, intf.bitsField[2:5], notSbits);
    
    #10 intf.bitsField = t3;
    $display($time, " t3=%06b, S=%04b, notSbits%04b", intf.bitsField, intf.bitsField[2:5], notSbits);

    #10 $display($time, " [done]");
  end
endmodule


module top;
  INTF intf();
  mod mod0(.*);
endmodule
