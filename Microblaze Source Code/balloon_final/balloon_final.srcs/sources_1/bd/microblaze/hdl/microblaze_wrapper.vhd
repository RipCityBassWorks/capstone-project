--Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
--Date        : Sun Mar 31 11:36:25 2019
--Host        : Galentine running 64-bit major release  (build 9200)
--Command     : generate_target microblaze_wrapper.bd
--Design      : microblaze_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity microblaze_wrapper is
  port (
    data_in_tri_i : in STD_LOGIC_VECTOR ( 31 downto 0 );
    data_out_tri_o : out STD_LOGIC_VECTOR ( 31 downto 0 );
    ja_pin10_io : inout STD_LOGIC;
    ja_pin1_io : inout STD_LOGIC;
    ja_pin2_io : inout STD_LOGIC;
    ja_pin3_io : inout STD_LOGIC;
    ja_pin4_io : inout STD_LOGIC;
    ja_pin7_io : inout STD_LOGIC;
    ja_pin8_io : inout STD_LOGIC;
    ja_pin9_io : inout STD_LOGIC;
    jb_pin10_io : inout STD_LOGIC;
    jb_pin1_io : inout STD_LOGIC;
    jb_pin2_io : inout STD_LOGIC;
    jb_pin3_io : inout STD_LOGIC;
    jb_pin4_io : inout STD_LOGIC;
    jb_pin7_io : inout STD_LOGIC;
    jb_pin8_io : inout STD_LOGIC;
    jb_pin9_io : inout STD_LOGIC;
    jc_pin10_io : inout STD_LOGIC;
    jc_pin1_io : inout STD_LOGIC;
    jc_pin2_io : inout STD_LOGIC;
    jc_pin3_io : inout STD_LOGIC;
    jc_pin4_io : inout STD_LOGIC;
    jc_pin7_io : inout STD_LOGIC;
    jc_pin8_io : inout STD_LOGIC;
    jc_pin9_io : inout STD_LOGIC;
    lfsr_data_tri_i : in STD_LOGIC_VECTOR ( 15 downto 0 );
    lfsr_en_tri_o : out STD_LOGIC_VECTOR ( 0 to 0 );
    mem_addr_tri_o : out STD_LOGIC_VECTOR ( 10 downto 0 );
    mem_en_tri_o : out STD_LOGIC_VECTOR ( 0 to 0 );
    reset : in STD_LOGIC;
    sys_clock : in STD_LOGIC
  );
end microblaze_wrapper;

architecture STRUCTURE of microblaze_wrapper is
  component microblaze is
  port (
    reset : in STD_LOGIC;
    sys_clock : in STD_LOGIC;
    lfsr_en_tri_o : out STD_LOGIC_VECTOR ( 0 to 0 );
    lfsr_data_tri_i : in STD_LOGIC_VECTOR ( 15 downto 0 );
    data_in_tri_i : in STD_LOGIC_VECTOR ( 31 downto 0 );
    data_out_tri_o : out STD_LOGIC_VECTOR ( 31 downto 0 );
    ja_pin1_o : out STD_LOGIC;
    ja_pin7_i : in STD_LOGIC;
    ja_pin2_o : out STD_LOGIC;
    ja_pin8_i : in STD_LOGIC;
    ja_pin3_o : out STD_LOGIC;
    ja_pin9_i : in STD_LOGIC;
    ja_pin10_o : out STD_LOGIC;
    ja_pin4_o : out STD_LOGIC;
    ja_pin3_i : in STD_LOGIC;
    ja_pin4_i : in STD_LOGIC;
    ja_pin1_i : in STD_LOGIC;
    ja_pin2_i : in STD_LOGIC;
    ja_pin10_t : out STD_LOGIC;
    ja_pin8_t : out STD_LOGIC;
    ja_pin9_t : out STD_LOGIC;
    ja_pin4_t : out STD_LOGIC;
    ja_pin9_o : out STD_LOGIC;
    ja_pin10_i : in STD_LOGIC;
    ja_pin7_t : out STD_LOGIC;
    ja_pin1_t : out STD_LOGIC;
    ja_pin2_t : out STD_LOGIC;
    ja_pin7_o : out STD_LOGIC;
    ja_pin3_t : out STD_LOGIC;
    ja_pin8_o : out STD_LOGIC;
    jb_pin1_o : out STD_LOGIC;
    jb_pin7_i : in STD_LOGIC;
    jb_pin2_o : out STD_LOGIC;
    jb_pin8_i : in STD_LOGIC;
    jb_pin3_o : out STD_LOGIC;
    jb_pin9_i : in STD_LOGIC;
    jb_pin10_o : out STD_LOGIC;
    jb_pin4_o : out STD_LOGIC;
    jb_pin3_i : in STD_LOGIC;
    jb_pin4_i : in STD_LOGIC;
    jb_pin1_i : in STD_LOGIC;
    jb_pin2_i : in STD_LOGIC;
    jb_pin10_t : out STD_LOGIC;
    jb_pin8_t : out STD_LOGIC;
    jb_pin9_t : out STD_LOGIC;
    jb_pin4_t : out STD_LOGIC;
    jb_pin9_o : out STD_LOGIC;
    jb_pin10_i : in STD_LOGIC;
    jb_pin7_t : out STD_LOGIC;
    jb_pin1_t : out STD_LOGIC;
    jb_pin2_t : out STD_LOGIC;
    jb_pin7_o : out STD_LOGIC;
    jb_pin3_t : out STD_LOGIC;
    jb_pin8_o : out STD_LOGIC;
    mem_addr_tri_o : out STD_LOGIC_VECTOR ( 10 downto 0 );
    mem_en_tri_o : out STD_LOGIC_VECTOR ( 0 to 0 );
    jc_pin1_o : out STD_LOGIC;
    jc_pin7_i : in STD_LOGIC;
    jc_pin2_o : out STD_LOGIC;
    jc_pin8_i : in STD_LOGIC;
    jc_pin3_o : out STD_LOGIC;
    jc_pin9_i : in STD_LOGIC;
    jc_pin10_o : out STD_LOGIC;
    jc_pin4_o : out STD_LOGIC;
    jc_pin3_i : in STD_LOGIC;
    jc_pin4_i : in STD_LOGIC;
    jc_pin1_i : in STD_LOGIC;
    jc_pin2_i : in STD_LOGIC;
    jc_pin10_t : out STD_LOGIC;
    jc_pin8_t : out STD_LOGIC;
    jc_pin9_t : out STD_LOGIC;
    jc_pin4_t : out STD_LOGIC;
    jc_pin9_o : out STD_LOGIC;
    jc_pin10_i : in STD_LOGIC;
    jc_pin7_t : out STD_LOGIC;
    jc_pin1_t : out STD_LOGIC;
    jc_pin2_t : out STD_LOGIC;
    jc_pin7_o : out STD_LOGIC;
    jc_pin3_t : out STD_LOGIC;
    jc_pin8_o : out STD_LOGIC
  );
  end component microblaze;
  component IOBUF is
  port (
    I : in STD_LOGIC;
    O : out STD_LOGIC;
    T : in STD_LOGIC;
    IO : inout STD_LOGIC
  );
  end component IOBUF;
  signal ja_pin10_i : STD_LOGIC;
  signal ja_pin10_o : STD_LOGIC;
  signal ja_pin10_t : STD_LOGIC;
  signal ja_pin1_i : STD_LOGIC;
  signal ja_pin1_o : STD_LOGIC;
  signal ja_pin1_t : STD_LOGIC;
  signal ja_pin2_i : STD_LOGIC;
  signal ja_pin2_o : STD_LOGIC;
  signal ja_pin2_t : STD_LOGIC;
  signal ja_pin3_i : STD_LOGIC;
  signal ja_pin3_o : STD_LOGIC;
  signal ja_pin3_t : STD_LOGIC;
  signal ja_pin4_i : STD_LOGIC;
  signal ja_pin4_o : STD_LOGIC;
  signal ja_pin4_t : STD_LOGIC;
  signal ja_pin7_i : STD_LOGIC;
  signal ja_pin7_o : STD_LOGIC;
  signal ja_pin7_t : STD_LOGIC;
  signal ja_pin8_i : STD_LOGIC;
  signal ja_pin8_o : STD_LOGIC;
  signal ja_pin8_t : STD_LOGIC;
  signal ja_pin9_i : STD_LOGIC;
  signal ja_pin9_o : STD_LOGIC;
  signal ja_pin9_t : STD_LOGIC;
  signal jb_pin10_i : STD_LOGIC;
  signal jb_pin10_o : STD_LOGIC;
  signal jb_pin10_t : STD_LOGIC;
  signal jb_pin1_i : STD_LOGIC;
  signal jb_pin1_o : STD_LOGIC;
  signal jb_pin1_t : STD_LOGIC;
  signal jb_pin2_i : STD_LOGIC;
  signal jb_pin2_o : STD_LOGIC;
  signal jb_pin2_t : STD_LOGIC;
  signal jb_pin3_i : STD_LOGIC;
  signal jb_pin3_o : STD_LOGIC;
  signal jb_pin3_t : STD_LOGIC;
  signal jb_pin4_i : STD_LOGIC;
  signal jb_pin4_o : STD_LOGIC;
  signal jb_pin4_t : STD_LOGIC;
  signal jb_pin7_i : STD_LOGIC;
  signal jb_pin7_o : STD_LOGIC;
  signal jb_pin7_t : STD_LOGIC;
  signal jb_pin8_i : STD_LOGIC;
  signal jb_pin8_o : STD_LOGIC;
  signal jb_pin8_t : STD_LOGIC;
  signal jb_pin9_i : STD_LOGIC;
  signal jb_pin9_o : STD_LOGIC;
  signal jb_pin9_t : STD_LOGIC;
  signal jc_pin10_i : STD_LOGIC;
  signal jc_pin10_o : STD_LOGIC;
  signal jc_pin10_t : STD_LOGIC;
  signal jc_pin1_i : STD_LOGIC;
  signal jc_pin1_o : STD_LOGIC;
  signal jc_pin1_t : STD_LOGIC;
  signal jc_pin2_i : STD_LOGIC;
  signal jc_pin2_o : STD_LOGIC;
  signal jc_pin2_t : STD_LOGIC;
  signal jc_pin3_i : STD_LOGIC;
  signal jc_pin3_o : STD_LOGIC;
  signal jc_pin3_t : STD_LOGIC;
  signal jc_pin4_i : STD_LOGIC;
  signal jc_pin4_o : STD_LOGIC;
  signal jc_pin4_t : STD_LOGIC;
  signal jc_pin7_i : STD_LOGIC;
  signal jc_pin7_o : STD_LOGIC;
  signal jc_pin7_t : STD_LOGIC;
  signal jc_pin8_i : STD_LOGIC;
  signal jc_pin8_o : STD_LOGIC;
  signal jc_pin8_t : STD_LOGIC;
  signal jc_pin9_i : STD_LOGIC;
  signal jc_pin9_o : STD_LOGIC;
  signal jc_pin9_t : STD_LOGIC;
begin
ja_pin10_iobuf: component IOBUF
     port map (
      I => ja_pin10_o,
      IO => ja_pin10_io,
      O => ja_pin10_i,
      T => ja_pin10_t
    );
ja_pin1_iobuf: component IOBUF
     port map (
      I => ja_pin1_o,
      IO => ja_pin1_io,
      O => ja_pin1_i,
      T => ja_pin1_t
    );
ja_pin2_iobuf: component IOBUF
     port map (
      I => ja_pin2_o,
      IO => ja_pin2_io,
      O => ja_pin2_i,
      T => ja_pin2_t
    );
ja_pin3_iobuf: component IOBUF
     port map (
      I => ja_pin3_o,
      IO => ja_pin3_io,
      O => ja_pin3_i,
      T => ja_pin3_t
    );
ja_pin4_iobuf: component IOBUF
     port map (
      I => ja_pin4_o,
      IO => ja_pin4_io,
      O => ja_pin4_i,
      T => ja_pin4_t
    );
ja_pin7_iobuf: component IOBUF
     port map (
      I => ja_pin7_o,
      IO => ja_pin7_io,
      O => ja_pin7_i,
      T => ja_pin7_t
    );
ja_pin8_iobuf: component IOBUF
     port map (
      I => ja_pin8_o,
      IO => ja_pin8_io,
      O => ja_pin8_i,
      T => ja_pin8_t
    );
ja_pin9_iobuf: component IOBUF
     port map (
      I => ja_pin9_o,
      IO => ja_pin9_io,
      O => ja_pin9_i,
      T => ja_pin9_t
    );
jb_pin10_iobuf: component IOBUF
     port map (
      I => jb_pin10_o,
      IO => jb_pin10_io,
      O => jb_pin10_i,
      T => jb_pin10_t
    );
jb_pin1_iobuf: component IOBUF
     port map (
      I => jb_pin1_o,
      IO => jb_pin1_io,
      O => jb_pin1_i,
      T => jb_pin1_t
    );
jb_pin2_iobuf: component IOBUF
     port map (
      I => jb_pin2_o,
      IO => jb_pin2_io,
      O => jb_pin2_i,
      T => jb_pin2_t
    );
jb_pin3_iobuf: component IOBUF
     port map (
      I => jb_pin3_o,
      IO => jb_pin3_io,
      O => jb_pin3_i,
      T => jb_pin3_t
    );
jb_pin4_iobuf: component IOBUF
     port map (
      I => jb_pin4_o,
      IO => jb_pin4_io,
      O => jb_pin4_i,
      T => jb_pin4_t
    );
jb_pin7_iobuf: component IOBUF
     port map (
      I => jb_pin7_o,
      IO => jb_pin7_io,
      O => jb_pin7_i,
      T => jb_pin7_t
    );
jb_pin8_iobuf: component IOBUF
     port map (
      I => jb_pin8_o,
      IO => jb_pin8_io,
      O => jb_pin8_i,
      T => jb_pin8_t
    );
jb_pin9_iobuf: component IOBUF
     port map (
      I => jb_pin9_o,
      IO => jb_pin9_io,
      O => jb_pin9_i,
      T => jb_pin9_t
    );
jc_pin10_iobuf: component IOBUF
     port map (
      I => jc_pin10_o,
      IO => jc_pin10_io,
      O => jc_pin10_i,
      T => jc_pin10_t
    );
jc_pin1_iobuf: component IOBUF
     port map (
      I => jc_pin1_o,
      IO => jc_pin1_io,
      O => jc_pin1_i,
      T => jc_pin1_t
    );
jc_pin2_iobuf: component IOBUF
     port map (
      I => jc_pin2_o,
      IO => jc_pin2_io,
      O => jc_pin2_i,
      T => jc_pin2_t
    );
jc_pin3_iobuf: component IOBUF
     port map (
      I => jc_pin3_o,
      IO => jc_pin3_io,
      O => jc_pin3_i,
      T => jc_pin3_t
    );
jc_pin4_iobuf: component IOBUF
     port map (
      I => jc_pin4_o,
      IO => jc_pin4_io,
      O => jc_pin4_i,
      T => jc_pin4_t
    );
jc_pin7_iobuf: component IOBUF
     port map (
      I => jc_pin7_o,
      IO => jc_pin7_io,
      O => jc_pin7_i,
      T => jc_pin7_t
    );
jc_pin8_iobuf: component IOBUF
     port map (
      I => jc_pin8_o,
      IO => jc_pin8_io,
      O => jc_pin8_i,
      T => jc_pin8_t
    );
jc_pin9_iobuf: component IOBUF
     port map (
      I => jc_pin9_o,
      IO => jc_pin9_io,
      O => jc_pin9_i,
      T => jc_pin9_t
    );
microblaze_i: component microblaze
     port map (
      data_in_tri_i(31 downto 0) => data_in_tri_i(31 downto 0),
      data_out_tri_o(31 downto 0) => data_out_tri_o(31 downto 0),
      ja_pin10_i => ja_pin10_i,
      ja_pin10_o => ja_pin10_o,
      ja_pin10_t => ja_pin10_t,
      ja_pin1_i => ja_pin1_i,
      ja_pin1_o => ja_pin1_o,
      ja_pin1_t => ja_pin1_t,
      ja_pin2_i => ja_pin2_i,
      ja_pin2_o => ja_pin2_o,
      ja_pin2_t => ja_pin2_t,
      ja_pin3_i => ja_pin3_i,
      ja_pin3_o => ja_pin3_o,
      ja_pin3_t => ja_pin3_t,
      ja_pin4_i => ja_pin4_i,
      ja_pin4_o => ja_pin4_o,
      ja_pin4_t => ja_pin4_t,
      ja_pin7_i => ja_pin7_i,
      ja_pin7_o => ja_pin7_o,
      ja_pin7_t => ja_pin7_t,
      ja_pin8_i => ja_pin8_i,
      ja_pin8_o => ja_pin8_o,
      ja_pin8_t => ja_pin8_t,
      ja_pin9_i => ja_pin9_i,
      ja_pin9_o => ja_pin9_o,
      ja_pin9_t => ja_pin9_t,
      jb_pin10_i => jb_pin10_i,
      jb_pin10_o => jb_pin10_o,
      jb_pin10_t => jb_pin10_t,
      jb_pin1_i => jb_pin1_i,
      jb_pin1_o => jb_pin1_o,
      jb_pin1_t => jb_pin1_t,
      jb_pin2_i => jb_pin2_i,
      jb_pin2_o => jb_pin2_o,
      jb_pin2_t => jb_pin2_t,
      jb_pin3_i => jb_pin3_i,
      jb_pin3_o => jb_pin3_o,
      jb_pin3_t => jb_pin3_t,
      jb_pin4_i => jb_pin4_i,
      jb_pin4_o => jb_pin4_o,
      jb_pin4_t => jb_pin4_t,
      jb_pin7_i => jb_pin7_i,
      jb_pin7_o => jb_pin7_o,
      jb_pin7_t => jb_pin7_t,
      jb_pin8_i => jb_pin8_i,
      jb_pin8_o => jb_pin8_o,
      jb_pin8_t => jb_pin8_t,
      jb_pin9_i => jb_pin9_i,
      jb_pin9_o => jb_pin9_o,
      jb_pin9_t => jb_pin9_t,
      jc_pin10_i => jc_pin10_i,
      jc_pin10_o => jc_pin10_o,
      jc_pin10_t => jc_pin10_t,
      jc_pin1_i => jc_pin1_i,
      jc_pin1_o => jc_pin1_o,
      jc_pin1_t => jc_pin1_t,
      jc_pin2_i => jc_pin2_i,
      jc_pin2_o => jc_pin2_o,
      jc_pin2_t => jc_pin2_t,
      jc_pin3_i => jc_pin3_i,
      jc_pin3_o => jc_pin3_o,
      jc_pin3_t => jc_pin3_t,
      jc_pin4_i => jc_pin4_i,
      jc_pin4_o => jc_pin4_o,
      jc_pin4_t => jc_pin4_t,
      jc_pin7_i => jc_pin7_i,
      jc_pin7_o => jc_pin7_o,
      jc_pin7_t => jc_pin7_t,
      jc_pin8_i => jc_pin8_i,
      jc_pin8_o => jc_pin8_o,
      jc_pin8_t => jc_pin8_t,
      jc_pin9_i => jc_pin9_i,
      jc_pin9_o => jc_pin9_o,
      jc_pin9_t => jc_pin9_t,
      lfsr_data_tri_i(15 downto 0) => lfsr_data_tri_i(15 downto 0),
      lfsr_en_tri_o(0) => lfsr_en_tri_o(0),
      mem_addr_tri_o(10 downto 0) => mem_addr_tri_o(10 downto 0),
      mem_en_tri_o(0) => mem_en_tri_o(0),
      reset => reset,
      sys_clock => sys_clock
    );
end STRUCTURE;
