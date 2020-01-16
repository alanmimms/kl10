-- Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2019.2.1 (lin64) Build 2729669 Thu Dec  5 04:48:12 MST 2019
-- Date        : Thu Jan 16 15:27:50 2020
-- Host        : alanm running 64-bit Ubuntu 19.10
-- Command     : write_vhdl -force -mode synth_stub
--               /home/alan/kl10-fpga-rtl/kl10-fpga-rtl.srcs/sources_1/ip/ebox_clocks/ebox_clocks_stub.vhdl
-- Design      : ebox_clocks
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z010clg400-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ebox_clocks is
  Port ( 
    eboxClk : out STD_LOGIC;
    fastMemClk : out STD_LOGIC;
    clk_in1 : in STD_LOGIC
  );

end ebox_clocks;

architecture stub of ebox_clocks is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "eboxClk,fastMemClk,clk_in1";
begin
end;
