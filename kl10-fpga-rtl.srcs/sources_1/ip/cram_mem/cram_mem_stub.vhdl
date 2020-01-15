-- Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2019.2.1 (lin64) Build 2729669 Thu Dec  5 04:48:12 MST 2019
-- Date        : Wed Jan 15 11:15:24 2020
-- Host        : alanm running 64-bit Ubuntu 19.10
-- Command     : write_vhdl -force -mode synth_stub
--               /home/alan/kl10-fpga-rtl/kl10-fpga-rtl.srcs/sources_1/ip/cram_mem/cram_mem_stub.vhdl
-- Design      : cram_mem
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z010clg400-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity cram_mem is
  Port ( 
    clka : in STD_LOGIC;
    wea : in STD_LOGIC_VECTOR ( 0 to 0 );
    addra : in STD_LOGIC_VECTOR ( 10 downto 0 );
    dina : in STD_LOGIC_VECTOR ( 83 downto 0 );
    douta : out STD_LOGIC_VECTOR ( 83 downto 0 )
  );

end cram_mem;

architecture stub of cram_mem is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clka,wea[0:0],addra[10:0],dina[83:0],douta[83:0]";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "blk_mem_gen_v8_4_4,Vivado 2019.2.1";
begin
end;
