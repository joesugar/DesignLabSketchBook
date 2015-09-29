--------------------------------------------------------------------------------
-- Copyright (c) 1995-2013 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____ 
--  /   /\/   / 
-- /___/  \  /    Vendor: Xilinx 
-- \   \   \/     Version : 14.7
--  \   \         Application : 
--  /   /         Filename : xil_12112_30
-- /___/   /\     Timestamp : 09/23/2014 15:24:59
-- \   \  /  \ 
--  \___\/\___\ 
--
--Command: 
--Design Name: 
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.ALL;
use ieee.std_logic_misc.ALL;
use std.textio.all;

library UNISIM;
use UNISIM.Vcomponents.ALL;

library DesignLab;
use DesignLab.ALL;

entity PSK31 is
  generic (
    pskwidth: integer := 8;
    
    -- Constants associated with the phase shifter.
    IQ_BUS_WIDTH : integer := 8;
    
    NUMBER_OF_SHIFTS : integer := 7;
    PSK_ROM_ADDRESS_WIDTH : integer := 8;   -- Used to map phase to phase shifts
    PSK_ROM_DATA_WIDTH : integer := 8;      -- NUMBER_OF_SHIFTS+1
    
    DDS_ROM_DATA_WIDTH : integer := 8;
    DDS_ROM_ADDRESS_WIDTH : integer := 8;
    DDS_INC_HI_WIDTH : integer := 8;
    
    D2A_DATA_WIDTH : integer := 8
  );
  port ( 
    wishbone_in  : in    std_logic_vector (100 downto 0); 
    wishbone_out : out   std_logic_vector (100 downto 0);
			 
    -- Other required signals.
    d2a_data: out std_logic_vector(D2A_DATA_WIDTH-1 downto 0);
    d2a_clk:  out std_logic
    );
end PSK31;

architecture BEHAVIORAL of PSK31 is
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
  
	--Put your unique register names here
  --
  -- Define the accumulator associated with the NCO
  --
  component zpuino_dds_acc is
  port (
    clk:    in  std_logic;
    reset:  in  std_logic;
    inc_hi: in  std_logic_vector(DDS_INC_HI_WIDTH-1 downto 0);
    inc_lo: in  std_logic_vector(31-DDS_INC_HI_WIDTH downto 0);
    carry:  out std_logic;
    q:      out std_logic_vector(DDS_ROM_ADDRESS_WIDTH-1 downto 0)
  );
  end component zpuino_dds_acc;

  -- 
  -- Define the ROM used to hold the NCO values.
  --
  component zpuino_dds_rom is
  port (
    addr_i    : in  std_logic_vector(DDS_ROM_ADDRESS_WIDTH-1 downto 0); -- 8 bits wide
    data_o    : out signed(DDS_ROM_DATA_WIDTH-1 downto 0) -- 8 bits wide
  );
  end component zpuino_dds_rom;
  
  --
  -- PSK phase accumulator.
  --
  component zpuino_phase_acc is
  port (
    clk:             in  std_logic;
    reset:           in  std_logic;
    serial_data_in:  in  std_logic;
    q:               out unsigned(PSK_ROM_ADDRESS_WIDTH-1 downto 0);
    inversion:       out std_logic;
    uart_clock:      out std_logic
  );
  end component zpuino_phase_acc;
  
  --
  -- PSK phase shifter
  --
  component zpuino_phase_shifter is
  port (
    clk:             in  std_logic;
    reset:           in  std_logic;
    i_data_in:       in  signed(DDS_ROM_DATA_WIDTH-1 downto 0);
    q_data_in:       in  signed(DDS_ROM_DATA_WIDTH-1 downto 0);
    phase_in:        in  std_logic_vector(PSK_ROM_DATA_WIDTH-1 downto 0);
    i_data_out:      out signed(DDS_ROM_DATA_WIDTH-1 downto 0);
    q_data_out:      out signed(DDS_ROM_DATA_WIDTH-1 downto 0);
    phase_out:       out std_logic_vector(PSK_ROM_DATA_WIDTH-1 downto 0)
  );
  end component zpuino_phase_shifter;

  --
  -- Simple D2A converter
  --
  component simple_sigmadelta is
  generic (
    BITS: integer := 8
  );
  port (
    clk:      in std_logic;
    rst:      in std_logic;
    data_in:  in std_logic_vector(BITS-1 downto 0);
    data_out: out std_logic
    );
  end component simple_sigmadelta;
  
  -- Signals associated with the DDS NCO accumulator.
  signal dds_acc_reg_o    : std_logic_vector(DDS_ROM_ADDRESS_WIDTH-1 downto 0); -- register to hold accumulator value
  signal dds_acc_inc_hi_i : std_logic_vector(DDS_INC_HI_WIDTH-1 downto 0);      -- upper accumulator increment.
  signal dds_acc_inc_lo_i : std_logic_vector(31-DDS_INC_HI_WIDTH downto 0);     -- lower accumulator increment.

  -- Signals associated with the DDS rom.
  signal dds_rom_addr_i   : std_logic_vector(DDS_ROM_ADDRESS_WIDTH-1 downto 0); -- psk rom address
  signal dds_rom_o        : signed(DDS_ROM_DATA_WIDTH-1 downto 0);              -- rom output

  -- Signals associated with the phase accumulator.
  signal psk_phase_acc_count  : unsigned(PSK_ROM_ADDRESS_WIDTH-1 downto 0);     -- phase accumulator output.
  signal psk_phase_inversion  : std_logic;
  signal psk_serial_data_in   : std_logic;
  
  -- Signals associated with the phase shifter.
  signal i_data_in        : signed(IQ_BUS_WIDTH-1 downto 0);
  signal q_data_in        : signed(IQ_BUS_WIDTH-1 downto 0);
  signal phase_in         : std_logic_vector(PSK_ROM_DATA_WIDTH-1 downto 0);
  signal i_data_out       : signed(IQ_BUS_WIDTH-1 downto 0);
  signal q_data_out       : signed(IQ_BUS_WIDTH-1 downto 0);
  signal phase_out        : std_logic_vector(PSK_ROM_DATA_WIDTH-1 downto 0);
  
  -- Signals associated with the signal out
  signal i_audio_out      : std_logic_vector(IQ_BUS_WIDTH-1 downto 0);
  signal q_audio_out      : std_logic_vector(IQ_BUS_WIDTH-1 downto 0);
  
  -- Signals associated with the phase shift ROM.
  signal phase_shift_index: unsigned(PSK_ROM_ADDRESS_WIDTH-1 downto 0);
  
  -- Connecting signals.
  signal psk_dat_o        : std_logic_vector(pskwidth - 1 downto 0);  -- psk output signal
  
  -- PSK transmit data
  signal uart_clock         : std_logic;
  signal psk_xmit_data      : std_logic_vector(15 downto 0);
  signal psk_xmit_data_flag : std_logic;
  signal psk_xmit_reg       : std_logic_vector(15 downto 0);
  signal psk_xmit_reg_flag  : std_logic;
  signal psk_xmit_reg_empty : std_logic;
  signal psk_output_enable  : std_logic;
  
  --
  -- Declarations used to define the array of ROM data.
  --
  type rom_array is array(2**PSK_ROM_ADDRESS_WIDTH-1 downto 0) 
      of std_logic_vector(PSK_ROM_DATA_WIDTH-1 downto 0);
      
  impure function rom_init(filename : string) return rom_array is
    file rom_file : text open read_mode is filename;
    variable rom_line : line;
    variable rom_value : bit_vector(PSK_ROM_DATA_WIDTH-1 downto 0);
    variable temp : rom_array;
  begin
    for rom_index in 0 to 2**PSK_ROM_ADDRESS_WIDTH-1 loop
      readline(rom_file, rom_line);
      read(rom_line, rom_value);
      temp(rom_index) := to_stdlogicvector(rom_value);
    end loop;
    return temp;
  end function;
  
  constant phase_shift_rom_array : rom_array := rom_init(filename =>
      "/home/joseph/Papilio/ZPUino_PSK/zpu/hdl/zpuino/contrib/PSK/phase_shift_rom.txt");    
  
begin
  --
  -- Declare component instances.
  --
  -- REGION  DDS NCO
  --
  -- Instance of the NCO accumulator
  --
  dds_acc: zpuino_dds_acc
  port map (
    clk     => wb_clk_i,            -- wishbone clock signal
    reset   => wb_rst_i,            -- wishbone reset signal
    inc_hi  => dds_acc_inc_hi_i,    -- 7 downto 0
    inc_lo  => dds_acc_inc_lo_i,    -- 23 downto 0
    carry   => open,
    q       => dds_acc_reg_o        -- 7 downto 0
  );
  
  --
  -- Instance of the NCO rom.
  --
  dds_rom: zpuino_dds_rom
  port map (
    addr_i  => dds_rom_addr_i,      -- 7 downto 0
    data_o  => dds_rom_o            -- 7 downto 0
  );
  --
  -- END DDS NCO
  --
  
  --
  -- REGION PSK PHASE ACCUMULATOR
  --
  -- Instance of the phase accumulator.
  --
  psk_phase_acc: zpuino_phase_acc
  port map (
    clk => wb_clk_i,                      -- wishbone clock signal
    reset => wb_rst_i,                    -- wishbone reset signal
    serial_data_in => psk_serial_data_in, -- serial data in
    q => psk_phase_acc_count,             -- phase acc output
    inversion => psk_phase_inversion,     -- phase inversion output
    uart_clock => uart_clock              -- uart clock from the phase acc
  );
  --
  -- END PSK PHASE ACCUMULATOR
  --
  
  --
  -- REGION CORDIC PHASE SHIFTER 
  --
  -- Instance of the phase shifter.
  --
  phase_shifter: zpuino_phase_shifter
  port map (
    clk => wb_clk_i,                -- wishbone clock signal
    reset => wb_rst_i,              -- wishbone reset signal
    i_data_in => i_data_in,         -- in-phase data in
    q_data_in => q_data_in,         -- quadrature data in
    phase_in => phase_in,           -- phase shift in
    i_data_out => i_data_out,       -- in-phase data out
    q_data_out => q_data_out,       -- quadrature data out
    phase_out => phase_out          -- phase shift out
  );
  --
  -- END CORDIC PHASE SHIFTER
  -- 
      
  --
  -- REGION ARCHITECTURE CODE
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
  q_data_in <= X"00";
  i_data_in <= dds_rom_o;
  
  --
  -- Wrap the clock back out to serve as the D2A clock
  --
  d2a_clk <= wb_clk_i;
  
  --
  -- DDS processing loop.
  --
  process(wb_clk_i, wb_rst_i)
    variable address      : unsigned(PSK_ROM_ADDRESS_WIDTH-1 downto 0);
    variable mapped_phase : std_logic_vector(NUMBER_OF_SHIFTS downto 0); 
  begin
    if (wb_rst_i = '1') then
      --
      -- Reset signal is set.
      --
      phase_in  <= (others => '0');
      dds_acc_inc_hi_i <= (others => '0');
      dds_acc_inc_lo_i <= (others => '0');
      psk_xmit_data_flag <= '0';
      psk_output_enable <= '0';
      
    elsif (rising_edge(wb_clk_i)) then
      --
      -- On the rising edge of the clock...
      --
      if (wb_cyc_i='1' and wb_stb_i='1' and wb_we_i='1') then
        case wb_adr_i(4 downto 2) is
          when "000" =>
            -- 
            -- Store the value to be transmitted.
            -- Only store the value if the flags are the same, indicating
            -- the xmit data has been read.
            --
            if (psk_xmit_data_flag = psk_xmit_reg_flag) then
              psk_xmit_data <= wb_dat_i(15 downto 0);
              psk_xmit_data_flag <= not(psk_xmit_data_flag);
            end if;
          when "001" =>
            --
            -- Update the DDS increment value.
            --
            dds_acc_inc_hi_i <= 
                std_logic_vector(wb_dat_i(31 downto 31-DDS_INC_HI_WIDTH+1));
            dds_acc_inc_lo_i <= 
                std_logic_vector(wb_dat_i(31-DDS_INC_HI_WIDTH downto 0));
          when "010" =>
            --
            -- Status register.
            --
            psk_output_enable <= wb_dat_i(0);
          when others =>
        end case;
      end if;

      -- Load the phase from the accumulator to the phase shifter.
      address := psk_phase_acc_count;
      mapped_phase := phase_shift_rom_array(to_integer(address));     
      phase_in(NUMBER_OF_SHIFTS downto 1) <= 
          mapped_phase(NUMBER_OF_SHIFTS downto 1);
      phase_in(0) <= 
          psk_phase_inversion;
          
    end if;
  end process;
  
  --
  -- Serial data taken from lowest bit of the psk transmit data
  -- Then rotate the transmit data 1 bit to the right.
  --
  process(wb_clk_i, wb_rst_i)
  begin
    if (wb_rst_i = '1') then
      --
      -- Initialize on reset.
      --
      psk_xmit_reg <= (others => '0');
      psk_serial_data_in <= '0';
      psk_xmit_reg_flag <= '0';
    elsif rising_edge(wb_clk_i) then
      --
      -- On the rising edge of the clock...
      --
      if (uart_clock = '1') then
        -- 
        -- It's time to swap in a new bit.
        --
        if (psk_xmit_reg_empty = '1') then
          --
          -- Done transmitting the old value.
          --
          if (psk_xmit_data_flag = psk_xmit_reg_flag) then
            --
            -- New value isn't ready so just send 0.
            --
            psk_serial_data_in <= '0';
            psk_xmit_reg <= (others => '1');
            psk_xmit_reg_flag <= psk_xmit_reg_flag;
          else
            --
            -- New value is ready.  Read it in and send the first bit.
            --
            psk_serial_data_in <= psk_xmit_data(15);
            psk_xmit_reg <= psk_xmit_data(14 downto 0) & '1';
            psk_xmit_reg_flag <= not(psk_xmit_reg_flag);
          end if;
        else
          --
          -- Still transmitting the current value so rotate the new bit in.
          -- 
          psk_serial_data_in <= psk_xmit_reg(15);
          psk_xmit_reg <= psk_xmit_reg(14 downto 0) & '1';
          psk_xmit_reg_flag <= psk_xmit_reg_flag;
        end if;
      end if;
    end if;
  end process;
  psk_xmit_reg_empty <= and_reduce(psk_xmit_reg);
  
  --
  -- Load the output data when address is read.
  --
  process(wb_adr_i, psk_output_enable)
  begin
    case wb_adr_i(4 downto 2) is
      when "010" =>
        -- 
        -- Store the value to be returned.
        --
        wb_dat_o(31 downto 0) <= (others => '0');
        wb_dat_o(1) <= psk_xmit_data_flag xnor psk_xmit_reg_flag;
        wb_dat_o(0) <= psk_output_enable;
      when others =>
        wb_dat_o(31 downto 0) <= (others => '0');
    end case;
  end process;
  
  --
  -- Load the output data.
  --
  process(i_data_out, q_data_out, psk_output_enable)
    --
    -- Temporary variable for signal conversion
    --
    variable temp_data: std_logic_vector(DDS_ROM_DATA_WIDTH-1 downto 0);
    variable sign_bit:  std_logic;
    variable data_bits: std_logic_vector(DDS_ROM_DATA_WIDTH-2 downto 0);
  begin
    if (psk_output_enable = '1') then
      temp_data := std_logic_vector(i_data_out);
      sign_bit := not temp_data(DDS_ROM_DATA_WIDTH-1);
      data_bits := temp_data(DDS_ROM_DATA_WIDTH-2 downto DDS_ROM_DATA_WIDTH-D2A_DATA_WIDTH);
      d2a_data <= sign_bit & data_bits;
    else
      d2a_data <= (others => '0');
    end if;
  end process;  
  
  --
  -- END ARCHITECTURE CODE
  --
end BEHAVIORAL;


