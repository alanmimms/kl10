`timescale 1ns/1ns

module universal_tb();
  bit cin, cout, clk, s0, s3;
  bit [0:1] sel;
  bit [0:3] d, q;
  bit reset;

  USR4 sr4(.RESET(reset),
           .S0(s0),
           .D(d),
           .S3(s3),
           .SEL(sel),
           .CLK(clk),
           .Q(q));
  UCR c4(.RESET(reset),
         .CIN(cin),
         .D(d),
         .SEL(sel),
         .CLK(clk),
         .Q(q),
         .COUT(cout));

  initial begin
    $display($time, " >>>>>>>>>>>>>>>>>>>> COUNTER <<<<<<<<<<<<<<<<<<<<");

    reset = 1;
    #5 reset = 0;

    $display($time, " >>>> LOAD 1010");
    cin = 1;
    clk = 0;
    sel = 2'b00;                // LOAD
    d = 4'b1010;
    #10 clk = 1;
    #10 clk = 0;
    $display($time, " CIN=%1b D=%4b SEL=%2b Q=%4b COUT=%1b", cin, d, sel, q, cout);

    $display($time, " >>>> LOAD 0101");
    sel = 2'b00;                // LOAD
    d = 4'b0101;
    #10 clk = 1;
    #10 clk = 0;
    $display($time, " CIN=%1b D=%4b SEL=%2b Q=%4b COUT=%1b", cin, d, sel, q, cout);

    $display($time, " >>>> DEC");
    sel = 2'b01;                // DEC
    d = 4'b0101;
    #10 clk = 1;
    #10 clk = 0;
    $display($time, " CIN=%1b D=%4b SEL=%2b Q=%4b COUT=%1b", cin, d, sel, q, cout);

    $display($time, " >>>> DEC");
    sel = 2'b01;                // DEC
    d = 4'b0101;
    #10 clk = 1;
    #10 clk = 0;
    $display($time, " CIN=%1b D=%4b SEL=%2b Q=%4b COUT=%1b", cin, d, sel, q, cout);

    $display($time, " >>>> DEC");
    sel = 2'b01;                // DEC
    d = 4'b0101;
    #10 clk = 1;
    #10 clk = 0;
    $display($time, " CIN=%1b D=%4b SEL=%2b Q=%4b COUT=%1b", cin, d, sel, q, cout);

    $display($time, " >>>> DEC");
    sel = 2'b01;                // DEC
    d = 4'b0101;
    #10 clk = 1;
    #10 clk = 0;
    $display($time, " CIN=%1b D=%4b SEL=%2b Q=%4b COUT=%1b", cin, d, sel, q, cout);

    $display($time, " >>>> DEC");
    sel = 2'b01;                // DEC
    d = 4'b0101;
    #10 clk = 1;
    #10 clk = 0;
    $display($time, " CIN=%1b D=%4b SEL=%2b Q=%4b COUT=%1b", cin, d, sel, q, cout);

    $display($time, " >>>> DEC");
    sel = 2'b01;                // DEC
    d = 4'b0101;
    #10 clk = 1;
    #10 clk = 0;
    $display($time, " CIN=%1b D=%4b SEL=%2b Q=%4b COUT=%1b", cin, d, sel, q, cout);

    $display($time, " >>>> DEC");
    sel = 2'b01;                // DEC
    d = 4'b0101;
    #10 clk = 1;
    #10 clk = 0;
    $display($time, " CIN=%1b D=%4b SEL=%2b Q=%4b COUT=%1b", cin, d, sel, q, cout);

    $display($time, " >>>> DEC");
    sel = 2'b01;                // DEC
    d = 4'b0101;
    #10 clk = 1;
    #10 clk = 0;
    $display($time, " CIN=%1b D=%4b SEL=%2b Q=%4b COUT=%1b", cin, d, sel, q, cout);

    $display($time, " >>>> INC");
    sel = 2'b10;                // INC
    d = 4'b0101;
    #10 clk = 1;
    #10 clk = 0;
    $display($time, " CIN=%1b D=%4b SEL=%2b Q=%4b COUT=%1b", cin, d, sel, q, cout);

    $display($time, " >>>> INC");
    sel = 2'b10;                // INC
    d = 4'b0101;
    #10 clk = 1;
    #10 clk = 0;
    $display($time, " CIN=%1b D=%4b SEL=%2b Q=%4b COUT=%1b", cin, d, sel, q, cout);

    $display($time, " >>>> INC");
    sel = 2'b10;                // INC
    d = 4'b0101;
    #10 clk = 1;
    #10 clk = 0;
    $display($time, " CIN=%1b D=%4b SEL=%2b Q=%4b COUT=%1b", cin, d, sel, q, cout);

    $display($time, " >>>> INC");
    sel = 2'b10;                // INC
    d = 4'b0101;
    #10 clk = 1;
    #10 clk = 0;
    $display($time, " CIN=%1b D=%4b SEL=%2b Q=%4b COUT=%1b", cin, d, sel, q, cout);

    $display($time, " >>>> INC");
    sel = 2'b10;                // INC
    d = 4'b0101;
    #10 clk = 1;
    #10 clk = 0;
    $display($time, " CIN=%1b D=%4b SEL=%2b Q=%4b COUT=%1b", cin, d, sel, q, cout);

    $display($time, " >>>> INC");
    sel = 2'b10;                // INC
    d = 4'b0101;
    #10 clk = 1;
    #10 clk = 0;
    $display($time, " CIN=%1b D=%4b SEL=%2b Q=%4b COUT=%1b", cin, d, sel, q, cout);

    $display($time, " >>>> INC");
    sel = 2'b10;                // INC
    d = 4'b0101;
    #10 clk = 1;
    #10 clk = 0;
    $display($time, " CIN=%1b D=%4b SEL=%2b Q=%4b COUT=%1b", cin, d, sel, q, cout);

    $display($time, " >>>> INC");
    sel = 2'b10;                // INC
    d = 4'b0101;
    #10 clk = 1;
    #10 clk = 0;
    $display($time, " CIN=%1b D=%4b SEL=%2b Q=%4b COUT=%1b", cin, d, sel, q, cout);

    $display($time, " >>>> INC");
    sel = 2'b10;                // INC
    d = 4'b0101;
    #10 clk = 1;
    #10 clk = 0;
    $display($time, " CIN=%1b D=%4b SEL=%2b Q=%4b COUT=%1b", cin, d, sel, q, cout);

    $display($time, " >>>> HOLD");
    sel = 2'b11;                // HOLD
    d = 4'b0101;
    #10 clk = 1;
    #10 clk = 0;
    $display($time, " CIN=%1b D=%4b SEL=%2b Q=%4b COUT=%1b", cin, d, sel, q, cout);

    $display($time, " >>>> HOLD");
    sel = 2'b11;                // HOLD
    d = 4'b0101;
    #10 clk = 1;
    #10 clk = 0;
    $display($time, " CIN=%1b D=%4b SEL=%2b Q=%4b COUT=%1b", cin, d, sel, q, cout);

    $display($time, " >>>> HOLD");
    sel = 2'b11;                // HOLD
    d = 4'b0101;
    #10 clk = 1;
    #10 clk = 0;
    $display($time, " CIN=%1b D=%4b SEL=%2b Q=%4b COUT=%1b", cin, d, sel, q, cout);

    $display($time, " >>>> HOLD");
    sel = 2'b11;                // HOLD
    d = 4'b0101;
    #10 clk = 1;
    #10 clk = 0;
    $display($time, " CIN=%1b D=%4b SEL=%2b Q=%4b COUT=%1b", cin, d, sel, q, cout);

    $display($time, " >>>> DEC");
    sel = 2'b01;                // DEC
    d = 4'b0101;
    #10 clk = 1;
    #10 clk = 0;
    $display($time, " CIN=%1b D=%4b SEL=%2b Q=%4b COUT=%1b", cin, d, sel, q, cout);

    $display($time, " >>>> DEC");
    sel = 2'b00;                // LOAD
    d = 4'b1100;
    #10 clk = 1;
    #10 clk = 0;
    $display($time, " CIN=%1b D=%4b SEL=%2b Q=%4b COUT=%1b", cin, d, sel, q, cout);

    $display($time, " >>>>>>>>>>>>>>>>>>>> SHIFT REGISTER <<<<<<<<<<<<<<<<<<<<");

    $display($time, " >>>> LOAD 1010");
    sel = 2'b00;                // LOAD
    s0 = 0;
    d = 4'b1010;
    s3 = 0;
    #10 clk = 1;
    #10 clk = 0;
    $display($time, " S0=%1b D=%4b S3=%1b SEL=%2b Q=%4b", s0, d, s3, sel, q);

    $display($time, " >>>> LOAD 0101");
    sel = 2'b00;                // LOAD
    s0 = 0;
    d = 4'b0101;
    s3 = 0;
    #10 clk = 1;
    #10 clk = 0;
    $display($time, " S0=%1b D=%4b S3=%1b SEL=%2b Q=%4b", s0, d, s3, sel, q);

    $display($time, " >>>> SHIFT 0in 1");
    sel = 2'b01;                // SHIFT 0in
    s0 = 1;
    d = 4'b1010;
    s3 = 0;
    #10 clk = 1;
    #10 clk = 0;
    $display($time, " S0=%1b D=%4b S3=%1b SEL=%2b Q=%4b", s0, d, s3, sel, q);

    $display($time, " >>>> SHIFT 0in 0");
    sel = 2'b01;                // SHIFT 0in
    s0 = 0;
    d = 4'b1010;
    s3 = 0;
    #10 clk = 1;
    #10 clk = 0;
    $display($time, " S0=%1b D=%4b S3=%1b SEL=%2b Q=%4b", s0, d, s3, sel, q);

    $display($time, " >>>> SHIFT 3in 0");
    sel = 2'b10;                // SHIFT 3in
    s0 = 0;
    d = 4'b1010;
    s3 = 0;
    #10 clk = 1;
    #10 clk = 0;
    $display($time, " S0=%1b D=%4b S3=%1b SEL=%2b Q=%4b", s0, d, s3, sel, q);

    $display($time, " >>>> SHIFT 3in 1");
    sel = 2'b10;                // SHIFT 3in
    s0 = 0;
    d = 4'b1010;
    s3 = 1;
    #10 clk = 1;
    #10 clk = 0;
    $display($time, " S0=%1b D=%4b S3=%1b SEL=%2b Q=%4b", s0, d, s3, sel, q);

    $display($time, " >>>> SHIFT 3in 1");
    sel = 2'b10;                // SHIFT 3in
    s0 = 0;
    d = 4'b1010;
    s3 = 1;
    #10 clk = 1;
    #10 clk = 0;
    $display($time, " S0=%1b D=%4b S3=%1b SEL=%2b Q=%4b", s0, d, s3, sel, q);

    $display($time, " >>>> SHIFT 3in 1");
    sel = 2'b10;                // SHIFT 3in
    s0 = 0;
    d = 4'b1010;
    s3 = 1;
    #10 clk = 1;
    #10 clk = 0;
    $display($time, " S0=%1b D=%4b S3=%1b SEL=%2b Q=%4b", s0, d, s3, sel, q);

    $display($time, " >>>> SHIFT 3in 1");
    sel = 2'b10;                // SHIFT 3in
    s0 = 0;
    d = 4'b1010;
    s3 = 1;
    #10 clk = 1;
    #10 clk = 0;
    $display($time, " S0=%1b D=%4b S3=%1b SEL=%2b Q=%4b", s0, d, s3, sel, q);

    $display($time, " >>>> SHIFT 0in 0");
    sel = 2'b01;                // SHIFT 0in
    s0 = 0;
    d = 4'b1010;
    s3 = 0;
    #10 clk = 1;
    #10 clk = 0;
    $display($time, " S0=%1b D=%4b S3=%1b SEL=%2b Q=%4b", s0, d, s3, sel, q);

    $display($time, " >>>> SHIFT 0in 0");
    sel = 2'b01;                // SHIFT 0in
    s0 = 0;
    d = 4'b1010;
    s3 = 0;
    #10 clk = 1;
    #10 clk = 0;
    $display($time, " S0=%1b D=%4b S3=%1b SEL=%2b Q=%4b", s0, d, s3, sel, q);

    $display($time, " >>>> SHIFT 0in 0");
    sel = 2'b01;                // SHIFT 0in
    s0 = 0;
    d = 4'b1010;
    s3 = 0;
    #10 clk = 1;
    #10 clk = 0;
    $display($time, " S0=%1b D=%4b S3=%1b SEL=%2b Q=%4b", s0, d, s3, sel, q);

    $display($time, " >>>> SHIFT 0in 0");
    sel = 2'b01;                // SHIFT 0in
    s0 = 0;
    d = 4'b1010;
    s3 = 0;
    #10 clk = 1;
    #10 clk = 0;
    $display($time, " S0=%1b D=%4b S3=%1b SEL=%2b Q=%4b", s0, d, s3, sel, q);

    $display($time, " >>>> HOLD");
    sel = 2'b11;                // HOLD
    s0 = 0;
    d = 4'b1010;
    s3 = 0;
    #10 clk = 1;
    #10 clk = 0;
    $display($time, " S0=%1b D=%4b S3=%1b SEL=%2b Q=%4b", s0, d, s3, sel, q);

    $display($time, " >>>> HOLD");
    sel = 2'b11;                // HOLD
    s0 = 0;
    d = 4'b1010;
    s3 = 0;
    #10 clk = 1;
    #10 clk = 0;
    $display($time, " S0=%1b D=%4b S3=%1b SEL=%2b Q=%4b", s0, d, s3, sel, q);

    $display($time, " >>>> LOAD 0011");
    sel = 2'b00;                // LOAD
    s0 = 0;
    d = 4'b0011;
    s3 = 0;
    #10 clk = 1;
    #10 clk = 0;
    $display($time, " S0=%1b D=%4b S3=%1b SEL=%2b Q=%4b", s0, d, s3, sel, q);

    #10 clk = 0;
  end

  
endmodule
