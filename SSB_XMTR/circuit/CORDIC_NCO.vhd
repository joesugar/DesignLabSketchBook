---------------------------------------------------------------------
----                                                             ----
----  CORDIC NCO Wishbone Core                                   ----
----                                                             ----                                                          ----
----  Author: J. Consugar                                        ----
----                                                             ----
---------------------------------------------------------------------
----                                                             ----
---- Copyright (C) 2014 J. Consugar                              ----
----                                                             ----
---- This source file may be used and distributed without        ----
---- restriction provided that this copyright statement is not   ----
---- removed from the file and that any derivative work contains ----
---- the original copyright notice and the associated disclaimer.----
----                                                             ----
----     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ----
---- EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ----
---- TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ----
---- FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ----
---- OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ----
---- INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ----
---- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ----
---- GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ----
---- BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ----
---- LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ----
---- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ----
---- OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ----
---- POSSIBILITY OF SUCH DAMAGE.                                 ----
----                                                             ----
---------------------------------------------------------------------
--
-- Change History:
--               Revision 0.1 - J. Consugar
--               Initial coding for use with the DesignLab IDE
--
-- This is a numerically controlled oscillator (NCO) based upon
-- the CORDIC algorithm.
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

entity CORDIC_NCO is
  generic (
    -- Constants associated with the audio
    AUDIO_SAMPLE_WIDTH : integer := 16;       -- Audio sample width.
    IQ_BUS_WIDTH : integer := 8;              -- Phase shifter channel data width.
    
    -- Constants associated with the phase shifter.
    NUMBER_OF_SHIFTS : integer := 7;
    CORDIC_ROM_ADDRESS_WIDTH : integer := 8;  -- Used to map phase to phase shifts.
    CORDIC_ROM_DATA_WIDTH : integer := 8;     -- NUMBER_OF_SHIFTS+1.
    
    -- Constants associated with the NCO
    PHASE_ACC_HI_WIDTH : integer := 8;        -- Width of the upper portion of
                                              -- the phase accumulator.  This is the
                                              -- portion that will feed the phase
                                              -- shifter.
    PHASE_ACC_OUT_WIDTH : integer := 8;       -- Phase accumulator output width.
    
    -- Constants associated with the FT232H
    FT232H_BUS_WIDTH : integer := 8;          -- FT232H data bus width.
    
    -- FIFO constants.
    FIFO_ADDRESS_WIDTH : integer := 4;        -- I/Q FIFO address width
    FIFO_DATA_WIDTH : integer := 32;          -- I/Q FIFO data width
    
    -- D2A constants.
    D2A_DATA_WIDTH : integer := 8             -- D2A data bus width.

  );    
  port ( 
    -- Wishbone signals
    wishbone_in : in    std_logic_vector (100 downto 0); 
    wishbone_out: out   std_logic_vector (100 downto 0);
    
    -- D2A signals
    d2a_data    : out   std_logic_vector(D2A_DATA_WIDTH-1 downto 0);
    d2a_clk     : out   std_logic
	);
end CORDIC_NCO;

architecture BEHAVIORAL of CORDIC_NCO is
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

  --
  -- NCO accumulator
  --
  component zpuino_dds_acc is
  port (
    clk:    in  std_logic;
    reset:  in  std_logic;
    inc_hi: in  std_logic_vector(PHASE_ACC_HI_WIDTH-1 downto 0);
    inc_lo: in  std_logic_vector(31-PHASE_ACC_HI_WIDTH downto 0);
    carry:  out std_logic;
    q:      out std_logic_vector(PHASE_ACC_OUT_WIDTH-1 downto 0)
  );
  end component zpuino_dds_acc;
  signal phase_acc_reg_o    : std_logic_vector(PHASE_ACC_OUT_WIDTH-1 downto 0);   -- register to hold accumulator value
  signal phase_acc_inc_hi_i : std_logic_vector(PHASE_ACC_HI_WIDTH-1 downto 0);    -- upper accumulator increment.
  signal phase_acc_inc_lo_i : std_logic_vector(31-PHASE_ACC_HI_WIDTH downto 0);   -- lower accumulator increment.
  
  --
  -- CORDIC phase shifter
  --
  component zpuino_phase_shifter is
  port (
    clk:        in  std_logic;
    reset:      in  std_logic;
    i_data_in:  in  signed(IQ_BUS_WIDTH-1 downto 0);
    q_data_in:  in  signed(IQ_BUS_WIDTH-1 downto 0);
    phase_in:   in  std_logic_vector(CORDIC_ROM_DATA_WIDTH-1 downto 0);
    i_data_out: out signed(IQ_BUS_WIDTH-1 downto 0);
    q_data_out: out signed(IQ_BUS_WIDTH-1 downto 0);
    phase_out:  out std_logic_vector(CORDIC_ROM_DATA_WIDTH-1 downto 0)
  );
  end component zpuino_phase_shifter;
  signal i_data_in   : signed(IQ_BUS_WIDTH-1 downto 0);
  signal q_data_in   : signed(IQ_BUS_WIDTH-1 downto 0);
  signal phase_in    : std_logic_vector(CORDIC_ROM_DATA_WIDTH-1 downto 0);
  signal i_data_out  : signed(IQ_BUS_WIDTH-1 downto 0);
  signal q_data_out  : signed(IQ_BUS_WIDTH-1 downto 0);
  signal phase_out   : std_logic_vector(CORDIC_ROM_DATA_WIDTH-1 downto 0);
  
  -- 
  -- FIFO for incoming data.
  --
  component fifo is
  generic (
    ADDRESS_WIDTH : integer := FIFO_ADDRESS_WIDTH;-- FIFO address width in bits
    DATA_WIDTH    : integer := FIFO_DATA_WIDTH    -- FIFO data width in bits
  );  
  port (
    clk:      in std_logic;                       -- FIFO clock
    rst:      in std_logic;                       -- FIFO reset
    wr:       in std_logic;                       -- write flag
    rd:       in std_logic;                       -- read flag
    write:    in std_logic_vector(FIFO_DATA_WIDTH-1 downto 0);   -- write data
    read :    out std_logic_vector(FIFO_DATA_WIDTH-1 downto 0);  -- read data
    full:     out std_logic;                      -- full when '1'
    empty:    out std_logic                       -- empty when '1'  
  );
  end component fifo;
  signal iq_fifo_data_in    : std_logic_vector(FIFO_DATA_WIDTH-1 downto 0);
  signal iq_fifo_data_out   : std_logic_vector(FIFO_DATA_WIDTH-1 downto 0);
  signal iq_fifo_full       : std_logic;
  signal iq_fifo_empty      : std_logic;
  signal iq_fifo_data_write : std_logic;
  signal iq_fifo_data_read  : std_logic;
  signal iq_fifo_read_flag  : std_logic;
        
  -- Control signals
  signal nco_output_enable : std_logic;
  signal iack_o            : std_logic;
  
  --
  -- Declarations used to define the array of ROM data.
  --
  type rom_array is array(2**CORDIC_ROM_ADDRESS_WIDTH-1 downto 0) 
      of std_logic_vector(CORDIC_ROM_DATA_WIDTH-1 downto 0);
      
  impure function rom_init(filename : string) return rom_array is
    file rom_file : text open read_mode is filename;
    variable rom_line : line;
    variable rom_value : bit_vector(CORDIC_ROM_DATA_WIDTH-1 downto 0);
    variable temp : rom_array;
  begin
    for rom_index in 0 to 2**CORDIC_ROM_ADDRESS_WIDTH-1 loop
      readline(rom_file, rom_line);
      read(rom_line, rom_value);
      temp(rom_index) := to_stdlogicvector(rom_value);
    end loop;
    return temp;
  end function;
  
  constant phase_shift_rom_array : rom_array := rom_init(filename =>
      "/home/joseph/DesignLab/sketchbook/libraries/CORDIC_NCO/phase_shift_rom.txt");  
  
begin
  --
  -- INSTANCE DECLARATIONS
  --
  -- Instance of the NCO accumulator
  --
  dds_acc: zpuino_dds_acc
  port map (
    -- system signals
    clk     => wb_clk_i,            -- wishbone clock signal
    reset   => wb_rst_i,            -- wishbone reset signal
    -- signals into the accumulator
    inc_hi  => phase_acc_inc_hi_i,  -- 7 downto 0
    inc_lo  => phase_acc_inc_lo_i,  -- 23 downto 0
    carry   => open,
    -- signals out of the accumulator
    q       => phase_acc_reg_o      -- 7 downto 0
  );

  --
  -- Instance of the phase shifter.
  --
  phase_shifter: zpuino_phase_shifter
  port map (
    -- system signals
    clk         => wb_clk_i,        -- wishbone clock signal
    reset       => wb_rst_i,        -- wishbone reset signal
    -- signals into the phase shifter
    i_data_in   => i_data_in,       -- in-phase data in
    q_data_in   => q_data_in,       -- quadrature data in
    phase_in    => phase_in,        -- phase shift in
    -- signals out of the phase shifter
    i_data_out  => i_data_out,      -- in-phase data out
    q_data_out  => q_data_out,      -- quadrature data out
    phase_out   => phase_out        -- phase shift out
  );
  
  iq_fifo: fifo
  generic map (
    ADDRESS_WIDTH => FIFO_ADDRESS_WIDTH,  -- FIFO address width
    DATA_WIDTH    => FIFO_DATA_WIDTH      -- FIFO data width
  )
  port map (
    clk     => wb_clk_i,
    rst     => wb_rst_i,
    wr      => iq_fifo_data_write,
    rd      => iq_fifo_data_read,
    write   => iq_fifo_data_in,
    read    => iq_fifo_data_out,
    full    => iq_fifo_full,
    empty   => iq_fifo_empty
  );
     
  --
  -- ARCHITECTURE CODE
  --
  -- Acknowledge all tranfers per the wishbone spec.
  --
  iack_o <= wb_stb_i and wb_cyc_i; 
  wb_ack_o <= iack_o;
  
  -- 
  -- Tie interrupt to '0', we never interrupt .
  --
  wb_inta_o <= '0';  
  
  --
  -- Wrap the system clock back out to serve as the D2A clock.
  --
  d2a_clk  <= wb_clk_i;  
  
  --
  -- Wishbone write processing process.  Also includes handling of the
  -- phase shift accumulator signals.
  --
  process(wb_clk_i, wb_rst_i)
    variable phase_address  : unsigned(CORDIC_ROM_ADDRESS_WIDTH-1 downto 0);
    variable mapped_phase   : std_logic_vector(NUMBER_OF_SHIFTS downto 0); 
  begin
    if (wb_rst_i = '1') then
      --
      -- Reset signal is set.
      --
      phase_in            <= (others => '0');
      phase_acc_inc_hi_i  <= (others => '0');
      phase_acc_inc_lo_i  <= (others => '0');
      
      iq_fifo_data_in     <= (others => '0');
      iq_fifo_data_write  <= '0';
      
      nco_output_enable <= '1';   -- Always enabled for now.
      
    elsif (rising_edge(wb_clk_i)) then
      --
      -- On the rising edge of the clock...
      --
      iq_fifo_data_in     <= (others => '0');
      iq_fifo_data_write  <= '0';
      
      if (wb_cyc_i='1' and wb_stb_i='1' and wb_we_i='1') then
        case wb_adr_i(4 downto 2) is
          when "000" =>
            --
            -- Incoming amplitude is a 32 bit value, 16 bit I, 16 bit Q.
            -- Write it to the FIFO.
            --
            -- All this does is load the value into the FIFO.  We have
            -- not yet loaded it into the NCO. 
            --
            if (iq_fifo_full = '0') then
              iq_fifo_data_in     <= wb_dat_i(FIFO_DATA_WIDTH-1 downto 0);
              iq_fifo_data_write  <= '1';
            end if;
          when "001" =>
            --
            -- Update the phase acc increment value.  This determines the
            -- NCO output frequency.
            --
            phase_acc_inc_hi_i <= 
                std_logic_vector(wb_dat_i(31 downto 32-PHASE_ACC_HI_WIDTH));
            phase_acc_inc_lo_i <= 
                std_logic_vector(wb_dat_i(31-PHASE_ACC_HI_WIDTH downto 0));
          when "010" =>
            --
            -- Control register.  The only flag available right now
            -- the the enable flag.
            --
            nco_output_enable <= wb_dat_i(0);
          when others =>
        end case;
      end if;

      -- Load the phase from the accumulator to the phase shifter.
      -- The phase accumulator goes from -90 to +90 (1/2 of a total
      -- rotation).  To get a full rotation base the address on the
      -- lower bits of the address and use the hi bit as the inversion
      -- bit.
      phase_address := 2 * unsigned(phase_acc_reg_o(PHASE_ACC_HI_WIDTH-2 downto 0));
      mapped_phase := phase_shift_rom_array(to_integer(phase_address));     
      phase_in(NUMBER_OF_SHIFTS downto 1) <= 
          mapped_phase(NUMBER_OF_SHIFTS downto 1);
      phase_in(0) <= 
          phase_acc_reg_o(PHASE_ACC_HI_WIDTH-1);
          
    end if;
  end process;   
    
  --
  -- Load the output data when address is read.
  --
  iq_fifo_read_flag <= iack_o and not(wb_we_i);
  process(iq_fifo_read_flag)
  begin
    if (iq_fifo_read_flag = '0') then
      --
      -- Reset the flag.
      --
      iq_fifo_data_read <= '0';
    else
      --
      -- Process the different address reads.
      --
      case wb_adr_i(4 downto 2) is
        when "000" =>
          -- 
          -- Return the value at the head of the FIFO.
          -- Set the data read flag to increment the read counter
          -- to the next value.
          --
          wb_dat_o <= (others => '0');
          wb_dat_o(FIFO_DATA_WIDTH-1 downto 0) <= iq_fifo_data_out;
          iq_fifo_data_read <= '1';
        when "001" =>
          -- 
          -- Return the phase increment (frequency).
          --
          wb_dat_o(31 downto 31-PHASE_ACC_HI_WIDTH+1) <=
              phase_acc_inc_hi_i;
          wb_dat_o(31-PHASE_ACC_HI_WIDTH downto 0) <=
              phase_acc_inc_lo_i;
          iq_fifo_data_read <= '0';              
        when "010" =>
          -- 
          -- Return the status flags.
          --
          wb_dat_o(31 downto 0) <= (others => '0');
          wb_dat_o(2) <= iq_fifo_full;
          wb_dat_o(1) <= iq_fifo_empty;
          wb_dat_o(0) <= nco_output_enable;
          iq_fifo_data_read <= '0'; 
        when others =>
          --
          -- All others.
          --
          report ("Illegal read address, setting all values to unknown.");
          wb_dat_o <= (others => 'X');
          iq_fifo_data_read <= '0'; 
      end case;
    end if;
  end process;
  
  --
  -- Move the D2A data to the output port.
  -- When doing this need to convert the signed i/q 
  -- data to unsigned.
  --
  process(i_data_out, q_data_out, nco_output_enable)
    --
    -- Temporary variable for signal conversion
    --
    variable data_bits: std_logic_vector(D2A_DATA_WIDTH-1 downto 0);
    variable xor_mask:  std_logic_vector(D2A_DATA_WIDTH-1 downto 0);
  begin
    if (nco_output_enable = '1') then
      --  
      -- Output enabled.  Take the highst bits of the i/q data
      -- and flip the highest bit to convert from signed to
      -- unsigned.
      --
      data_bits := std_logic_vector(
          i_data_out(IQ_BUS_WIDTH-1 downto IQ_BUS_WIDTH-D2A_DATA_WIDTH));
      xor_mask := '1' & std_logic_vector(to_signed(0, D2A_DATA_WIDTH-1));
      d2a_data <= data_bits xor xor_mask;
    else
      --
      -- Output disabled.  Just put out 0.
      --
      d2a_data <= (others => '0');
      d2a_data(D2A_DATA_WIDTH-1) <= '1';
    end if;
  end process;   
end BEHAVIORAL;  

