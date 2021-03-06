--
--  NCO (Numerically Controlled Oscillator)
-- 
--  Version: 1.0
--
--  Copyright 2014 J. Consugar
-- 
--  The FreeBSD license
--  
--  Redistribution and use in source and binary forms, with or without
--  modification, are permitted provided that the following conditions
--  are met:
--  
--  1. Redistributions of source code must retain the above copyright
--     notice, this list of conditions and the following disclaimer.
--  2. Redistributions in binary form must reproduce the above
--     copyright notice, this list of conditions and the following
--     disclaimer in the documentation and/or other materials
--     provided with the distribution.
--  
--  THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY
--  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
--  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
--  PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
--  ZPU PROJECT OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
--  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
--  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
--  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
--  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
--  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
--  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
--  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

library UNISIM;
use UNISIM.Vcomponents.ALL;

library DesignLab;
use DesignLab.ALL;

--
-- Core entity definition.
--
-- Unfortunately the Xilinx Schematic Editor does not support records, 
-- so we have to put all wishbone signals into one array.
--
-- Turning them into an array looks like this:
--	
--  wishbone_in_record.wb_clk_i <= wishbone_in(61);
--  wishbone_in_record.wb_rst_i <= wishbone_in(60);
--  wishbone_in_record.wb_dat_i <= wishbone_in(59 downto 28);
--  wishbone_in_record.wb_adr_i <= wishbone_in(27 downto 3);
--  wishbone_in_record.wb_we_i <= wishbone_in(2);
--  wishbone_in_record.wb_cyc_i <= wishbone_in(1);
--  wishbone_in_record.wb_stb_i <= wishbone_in(0); 
--
-- wishbone_out : out std_logic_vector(33 downto 0);
--
--  wishbone_out(33 downto 2) <= wishbone_out_record.wb_dat_o;
--  wishbone_out(1) <= wishbone_out_record.wb_ack_o;
--  wishbone_out(0) <= wishbone_out_record.wb_inta_o; 
--
entity NCO is
  generic (
    DDS_ROM_DATA_WIDTH : integer := 8;
    DDS_ROM_ADDRESS_WIDTH : integer := 8;
    DDS_INC_HI_WIDTH : integer := 8
  );
  port ( 
    wishbone_in  : in    std_logic_vector (100 downto 0); 
    wishbone_out : out   std_logic_vector (100 downto 0);
			 
		--Put your external connections here
		nco_out     : out std_logic_vector(DDS_ROM_DATA_WIDTH-1 downto 0);
    nco_clk_out : out std_logic
		);
end NCO;

--
-- Core architecture.
-- 
architecture behavioral of NCO is
  --
  -- Define the accumulator associated with the NCO
  --
  component dds_acc is
  port (
    clk:    in  std_logic;
    reset:  in  std_logic;
    inc_hi: in  std_logic_vector(DDS_INC_HI_WIDTH-1 downto 0);
    inc_lo: in  std_logic_vector(31-DDS_INC_HI_WIDTH downto 0);
    carry:  out std_logic;
    q:      out std_logic_vector(DDS_ROM_ADDRESS_WIDTH-1 downto 0)
  );
  end component dds_acc;

  -- 
  -- Define the ROM used to hold the NCO values.
  --
  component dds_rom is
  port (
    addr_i    : in  std_logic_vector(DDS_ROM_ADDRESS_WIDTH-1 downto 0); -- 8 bits wide
    data_o    : out signed(DDS_ROM_DATA_WIDTH-1 downto 0) -- 8 bits wide
  );
  end component dds_rom;

  --
  -- Rather than deal with slices out of the wishbone arrays we'll define some
  -- aliases here that allow use of the original names.
  --
  alias wb_clk_i: std_logic is wishbone_in(61);     -- FPGA clock signal
  alias wb_rst_i: std_logic is wishbone_in(60);     -- reset signal
  alias wb_dat_i: std_logic_vector(31 downto 0) is wishbone_in(59 downto 28); -- data in signal
  alias wb_adr_i: std_logic_vector(26 downto 2) is wishbone_in(27 downto 3);  -- read/write address
  alias wb_we_i : std_logic is wishbone_in(2);      -- write enable
  alias wb_cyc_i: std_logic is wishbone_in(1);
  alias wb_stb_i: std_logic is wishbone_in(0);

  alias wb_dat_o: std_logic_vector(31 downto 0) is wishbone_out(33 downto 2); -- data out signal
  alias wb_ack_o: std_logic is wishbone_out(1);
  alias wb_inta_o:std_logic is wishbone_out(0);
    
	-- Put your unique register names here
  -- Signals associated with the DDS NCO accumulator.
  signal dds_acc_reg_o  : std_logic_vector(DDS_ROM_ADDRESS_WIDTH-1 downto 0); -- register to hold accumulator value
  signal dds_acc_inc_hi : std_logic_vector(DDS_INC_HI_WIDTH-1 downto 0);      -- upper accumulator increment.
  signal dds_acc_inc_lo : std_logic_vector(31-DDS_INC_HI_WIDTH downto 0);     -- lower accumulator increment.

  -- Signals associated with the DDS rom.
  signal dds_rom_addr_i   : std_logic_vector(DDS_ROM_ADDRESS_WIDTH-1 downto 0); -- psk rom address
  signal dds_rom_o        : signed(DDS_ROM_DATA_WIDTH-1 downto 0);              -- rom output

begin

  -- Put your code here
  --
  -- Instance of the NCO accumulator
  --
  dds_acc_inst: dds_acc
  port map (
    clk     => wb_clk_i,            -- wishbone clock signal
    reset   => wb_rst_i,            -- wishbone reset signal
    inc_hi  => dds_acc_inc_hi,      -- 7 downto 0
    inc_lo  => dds_acc_inc_lo,      -- 23 downto 0
    carry   => open,
    q       => dds_acc_reg_o        -- 7 downto 0
  );
  
  --
  -- Instance of the NCO rom.
  --
  dds_rom_inst: dds_rom
  port map (
    addr_i  => dds_rom_addr_i,      -- 7 downto 0
    data_o  => dds_rom_o            -- 7 downto 0
  );

  --
  -- Begin the architecture code.     
  --
  -- Acknowledge all tranfers per the wishbone spec.
  --
  wb_ack_o <= wb_stb_i and wb_cyc_i; 
  
  -- 
  -- Tie interrupt to '0', we never interrupt 
  --
  wb_inta_o <= '0';
  
  --
  -- Connect accumulator register output to the ROM address lines.
  --
  dds_rom_addr_i <= dds_acc_reg_o; 
  nco_out <= std_logic_vector(dds_rom_o + 128);
  nco_clk_out <= wb_clk_i;

  --
  -- DDS processing loop.
  --
  process(wb_clk_i, wb_rst_i)
  begin
    if (wb_rst_i = '1') then
      --
      -- Reset signal is set.
      --
      dds_acc_inc_hi <= (others => '0');
      dds_acc_inc_lo <= (others => '0');
      
    elsif (rising_edge(wb_clk_i)) then
      --
      -- On the rising edge of the clock...
      --
      if (wb_cyc_i='1' and wb_stb_i='1' and wb_we_i='1') then
        case wb_adr_i(4 downto 2) is
          when "000" =>
            --
            -- Update the DDS increment value.
            --
            dds_acc_inc_hi <= 
                std_logic_vector(wb_dat_i(31 downto 31-DDS_INC_HI_WIDTH+1));
            dds_acc_inc_lo <= 
                std_logic_vector(wb_dat_i(31-DDS_INC_HI_WIDTH downto 0));
          when others =>
        end case;
      end if;
    end if;
  end process;
  
  --
  -- Load the output data when address is read.
  --
  process(wb_adr_i, dds_acc_inc_hi, dds_acc_inc_lo)
  begin
    case wb_adr_i(4 downto 2) is
      when "000" =>
        -- 
        -- Store the value to be returned.
        --
        wb_dat_o(31 downto 0) <= (others => '0');
        wb_dat_o(31 downto 31-DDS_INC_HI_WIDTH+1) <= dds_acc_inc_hi;
        wb_dat_o(31-DDS_INC_HI_WIDTH downto 0) <= dds_acc_inc_lo;
      when others =>
        wb_dat_o(31 downto 0) <= (others => '0');
    end case;
  end process;
  
end behavioral;


