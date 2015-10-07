---------------------------------------------------------------------
----                                                             ----
----  WISHBONE Wishbone core; top level                          ----
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
--               Initial coding
--
--               October 2015 - J. Consugar
--               Modified for use with the Papilio DesignLab IDE
--
-- This core interfaces with a WM8731 that has its own crystal.
-- As a result it operates in two clock domains; the FPGA domain
-- and the code domain.
--
-- The clock from the codec board comes in via wm_clk_i.  This
-- clock is used to drive all codec processing.  Communication
-- between the domains is done via an asynchronous fifo.  See
-- that module code for reference on how it works.
--
-- For this driver, the WM8731 is to be configured in slave mode.  
-- The chip should be configured in DSP mode and the data is to 
-- be sent to the chip immediately following that hi bit
-- (see figure 29 in the WM8731 data sheet).
--
-- The chip has to be configured via I2C outside this driver.
-- See the driver code for the specific configuration.
--

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
use ieee.std_logic_misc.all;

library UNISIM;
use UNISIM.Vcomponents.ALL;

library DesignLab;
use DesignLab.ALL;

entity WM8731 is
  port ( 
    -- Wishbone signals.
    wishbone_in  : in    std_logic_vector (100 downto 0); 
    wishbone_out : out   std_logic_vector (100 downto 0);

    -- wm8731 signals.
    wm_clk_i     : in  std_logic;    -- codec clock signal
    wm_rst_i     : in  std_logic;    -- codec reset signal
    wm_bclk_o    : out std_logic;    -- codec bclk signal
    wm_lrc_o     : out std_logic;    -- codec left/right channel
    wm_dacdat_o  : out std_logic;    -- codec DAC data
    wm_adcdat_i  : in  std_logic     -- codec ADC data    
  );
end WM8731;

architecture BEHAVIORAL of WM8731 is
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
  
  -- COMPONENTS
  
  -- 
  -- Asynchronous FIFO used to cross domains between the ZPUino and WM8731 codec.
  --
  component async_fifo is
  generic (
    DATA_WIDTH :integer := 32;  -- 32 bit words
    ADDR_WIDTH :integer := 3
  );
  port (
    -- Reading port.
    Data_out    :out std_logic_vector (DATA_WIDTH-1 downto 0);
    Empty_out   :out std_logic;
    ReadEn_in   :in  std_logic;
    RClk        :in  std_logic;
    
    -- Writing port.
    Data_in     :in  std_logic_vector (DATA_WIDTH-1 downto 0);
    Full_out    :out std_logic;
    WriteEn_in  :in  std_logic;
    WClk        :in  std_logic;

    Clear_in    :in  std_logic    -- active hi
  );
  end component;
  
  -- END COMPONENTS
  -- SIGNALS
  
  signal codec_sample_clock_counter : unsigned(7 downto 0);   -- 8-bit counter to create codec clock
  signal codec_sample_clock : std_logic;                      -- codec clock
  signal codec_bclk : std_logic;                              -- codec bclk signal
  
  signal iack_o : std_logic;                                  -- internal acknowledgement signal.
  
  signal d2a_fifo_full : std_logic;                           -- fifo full flag
  signal d2a_fifo_empty : std_logic;                          -- fifo empty flag
  signal d2a_fifo_data_in : std_logic_vector(31 downto 0);    -- fifo write data
  signal d2a_fifo_write_enable : std_logic;                   -- fifo write enable
  signal d2a_fifo_write_clear : std_logic;                    -- fifo write address clear
  signal d2a_fifo_data_out : std_logic_vector(31 downto 0);   -- fifo data out
  signal d2a_fifo_read_enable : std_logic;                    -- fifo read enable
  signal d2a_fifo_read_clear : std_logic;                     -- fifo read address clear
  signal d2a_fifo_clear : std_logic;                          -- fifo clear signal
  signal d2a_fifo_read_flag : std_logic;                      -- fifo read flag

  signal a2d_fifo_full : std_logic;                           -- fifo full flag
  signal a2d_fifo_empty : std_logic;                          -- fifo empty flag
  signal a2d_fifo_data_in : std_logic_vector(31 downto 0);    -- fifo write data
  signal a2d_fifo_write_enable : std_logic;                   -- fifo write enable
  signal a2d_fifo_write_clear : std_logic;                    -- fifo write address clear
  signal a2d_fifo_data_out : std_logic_vector(31 downto 0);   -- fifo read data
  signal a2d_fifo_read_enable : std_logic;                    -- fifo read enable
  signal a2d_fifo_read_clear : std_logic;                     -- fifo read address clear
  signal a2d_fifo_clear : std_logic;                          -- fifo clear signal
  signal a2d_fifo_read_flag : std_logic;                      -- fifo read flag
  signal a2d_read_address_inc : std_logic;                    -- read address gets incremented when set
  
  signal data_to_codec_buffer : std_logic_vector(31 downto 0);  -- buffer to hold data to be sent to codec
  signal data_to_codec : std_logic_vector(31 downto 0);         -- data to be sent to codec
  signal data_from_codec : std_logic_vector(31 downto 0);       -- data read from the codec
  signal data_from_codec_mask : std_logic_vector(31 downto 0);  -- mask used to read data from the codec.
  
  -- END SIGNALS
begin
  -- PORT MAPPING
  
  -- 
  -- Hook up A2D/D2A FIFOs
  --
  -- This is the port used to send data to the codec.
  --
  fifo_d2a : async_fifo
  port map (
    -- Reading port.
    Data_out    => d2a_fifo_data_out,       -- Data that goes to the codec.
    Empty_out   => d2a_fifo_empty,          -- Flag indicating if fifo is empty.
    ReadEn_in   => d2a_fifo_read_enable,    -- 
    RClk        => wm_clk_i,                -- Clock for reading data from the fifo.
    
    -- Writing port.
    Data_in     => d2a_fifo_data_in,        -- Data written to the fifo.
    Full_out    => d2a_fifo_full,           -- Flag indicating if fifo is full.
    WriteEn_in  => d2a_fifo_write_enable,   --
    WClk        => wb_clk_i,                -- Clock for writing data to the fifo.

    Clear_in    => d2a_fifo_clear           -- Flag to clear the fifo.
  );

  fifo_a2d : async_fifo
  port map (
    -- Reading port.
    Data_out    => a2d_fifo_data_out,       -- Data that goes back to the core.
    Empty_out   => a2d_fifo_empty,          -- Flag indicating if fifo is empty.
    ReadEn_in   => a2d_fifo_read_enable,    --
    RClk        => wb_clk_i,                -- Flag for reading data from the fifo.
    
    -- Writing port.
    Data_in     => a2d_fifo_data_in,        -- Data written to the fifo.
    Full_out    => a2d_fifo_full,           -- Flag indicating if the fifo is full.
    WriteEn_in  => a2d_fifo_write_enable,   --
    WClk        => wm_clk_i,                -- Clock for writing data to the fifol

    Clear_in    => a2d_fifo_clear           -- Flag to clear the fifo.
  );
  
  -- END PORT MAPPING
  -- PROCESSING
  
  -- 
  -- Tie interrupt to '0', we never interrupt 
  --
  wb_inta_o <= '0';
  
  --
  -- Acknowledge all transfers per the wishbone spec.
  --
  iack_o <= wb_stb_i and wb_cyc_i; 
  wb_ack_o <= iack_o;

  -- 
  -- Initial clear signal for the fifo
  -- 
  -- Clearing fifos on the wishbone side.
  -- Set the flag on reset.  Clear the flag on rising edge of 
  -- the wishbone clock.
  --
  process(wb_clk_i, wb_rst_i)
  begin
    if (wb_rst_i = '1') then
      d2a_fifo_write_clear <= '1';
      a2d_fifo_read_clear  <= '1';
    elsif rising_edge(wb_clk_i) then
      d2a_fifo_write_clear <= '0';
      a2d_fifo_read_clear  <= '0';
    end if;
  end process;

  --
  -- Clearing fifos on the codec side.
  -- Set the flag on reset.  Clear the flag on rising edge of
  -- the codec clock.
  --
  process(wm_clk_i, wb_rst_i)
  begin
    if (wb_rst_i = '1') then
      d2a_fifo_read_clear  <= '1';
      a2d_fifo_write_clear <= '1';
    elsif rising_edge(wm_clk_i) then
      d2a_fifo_read_clear  <= '0';
      a2d_fifo_write_clear <= '0';
    end if;
  end process;
  
  --
  -- The fifo clear flags will stay high as long as one of
  -- the flags is high.  This ensures an asynchronous clear.
  --  
  d2a_fifo_clear <= d2a_fifo_write_clear or d2a_fifo_read_clear;
  a2d_fifo_clear <= a2d_fifo_write_clear or a2d_fifo_read_clear;
  
  -- 
  -- Write data to the D2A FIFO so it can be sent to the codec.
  --
  write_d2a_data: process(wb_rst_i, wb_clk_i)
  begin
    -- 
    -- Reset
    --
    if (wb_rst_i = '1') then
      d2a_fifo_write_enable <= '0';
      d2a_fifo_data_in <= (others => '0');
    
    -- 
    -- Prepare data for writing.
    --
    elsif rising_edge(wb_clk_i) then
      --
      -- Initialize
      --
      d2a_fifo_write_enable <= '0';
      d2a_fifo_data_in <= (others => '0');
      
      -- 
      -- Process the different addresses on write
      --
      if (wb_cyc_i='1' and wb_stb_i='1' and wb_we_i='1') then
        case wb_adr_i(4 downto 2) is
          -- 
          -- write data register.
          --
          when "000" => 
            if (d2a_fifo_full = '0') then
              d2a_fifo_data_in <= wb_dat_i;
              d2a_fifo_write_enable <= '1';
            end if;
          
          --
          -- Status register.  On write no action.
          --
          when "001" => null;
          
          -- 
          -- Illegal cases, for simulation only
          --
          when others =>
            report ("Illegal write address, setting all registers to unknown.");
            d2a_fifo_data_in <= (others => 'X');
            
        end case;
      end if;
    end if;
  end process;
  
  -- 
  -- Read data from the A2D FIFO so it can be sent to the controller
  --
  -- You should load the output data when address is read.
  --
  a2d_fifo_read_flag <= iack_o and not(wb_we_i);
  read_a2d_data: process(a2d_fifo_read_flag)
  begin
    --
    -- Reset 
    --
    if (a2d_fifo_read_flag = '0') then
      a2d_read_address_inc <= '0';
      
    --
    -- Read data from the codec.
    --
    else
      --
      -- Process the different addresses.
      --
      case wb_adr_i(4 downto 2) is
        --
        -- Read data from the async fifo
        --
        when "000" =>
          wb_dat_o <= a2d_fifo_data_out;
          a2d_read_address_inc <= '1';
          
        -- 
        -- Read status flags.
        -- 
        when "001" =>
          wb_dat_o <= (others => '0');
          wb_dat_o(0) <= d2a_fifo_empty;
          wb_dat_o(1) <= d2a_fifo_full;
          wb_dat_o(2) <= a2d_fifo_empty;
          wb_dat_o(3) <= a2d_fifo_full;
          a2d_read_address_inc <= '0';
          
        --
        -- Illegal cases.
        --
        when others =>
          report ("Illegal read address, setting all values to unknown.");
          wb_dat_o <= (others => 'X');
          a2d_read_address_inc <= '0';
          
      end case;
    end if;
  end process;
  
  --
  -- Process to update the A2D FIFO read address.
  -- The read enable flag should be set when you want the data 
  -- coming out of the fifo to be updated on the next clock edge.
  --
  process(wb_rst_i, wb_clk_i)
  begin
    if (wb_rst_i = '1') then
      a2d_fifo_read_enable <= '0';
    elsif rising_edge(wb_clk_i) then
      a2d_fifo_read_enable <= '0';
      if ((a2d_fifo_read_flag = '1') and (a2d_read_address_inc = '1')) then
        a2d_fifo_read_enable <= '1';
      end if;
    end if;
  end process;

  -- 
  -- Create the clocks used to drive the codec.
  --
  -- The BCLK will be the codec clock / 2.
  -- The sample clock will be the codec clock / 256 but
  -- it's width has to match that of the BLCK.
  -- Created using an 8 bit counter.
  --
  process(wm_clk_i, wb_rst_i)
  begin
    if (wb_rst_i = '1') then
      codec_sample_clock_counter <= (others => '0');
    elsif rising_edge(wm_clk_i) then
      codec_sample_clock_counter <= codec_sample_clock_counter + 1;
    end if;
  end  process;
  
  codec_sample_clock <= and_reduce(std_logic_vector(
    codec_sample_clock_counter(7 downto 1)));
  codec_bclk <= std_logic(
    codec_sample_clock_counter(0));
    
  --
  -- Read data from the D2A FIFO so it can be sent to the codec.
  --
  -- The clock produces a single hi pulse every 256 pulses.
  -- It is expected the chip will be configured in DSP mode and
  -- the data is to be sent to the chip immediately following that hi bit
  -- (see figure 29 in the WM8731 data sheet).
  --
  read_d2a_data: process(wm_clk_i, wb_rst_i)
  begin
    --
    -- Initialization
    --  
    if (wb_rst_i = '1') then
      data_to_codec_buffer <= (others => '0');
      data_to_codec <= (others => '0');
      d2a_fifo_read_enable <= '0';
      
    --
    -- Processing
    --
    elsif rising_edge(wm_clk_i) then
      --
      -- Initialize
      --
      d2a_fifo_read_enable <= '0';
      
      --
      -- Load the data on the falling edge so it can be 
      -- read by the codec on the rising edge.
      -- 
      if (codec_bclk = '1') then
        --
        -- Load new data on the falling edge of the sample
        -- clock.  This is mode A of the WM8731.
        --
        if (codec_sample_clock = '1') then
          --
          -- Load data from the FIFO.  If the FIFO is not
          -- empty increment to the next value.
          --
          data_to_codec <= data_to_codec_buffer;        
          if (d2a_fifo_empty = '0') then
            data_to_codec_buffer <= d2a_fifo_data_out;
            d2a_fifo_read_enable <= '1';
          end if;
          
        --
        -- If you're not on the falling edge of the sample
        -- clock data has already been loaded and you just
        -- shift a new bit into place.
        --
        else
          data_to_codec <= data_to_codec(30 downto 0) & '1';
        end if;
      end if;
    end if;
  end process;

  --
  -- Process to read data from the codec and send it to the A2D FIFO.
  --
  write_a2d_data: process(wm_rst_i, wm_clk_i)
  begin
    --
    -- Initialization
    --
    if (wm_rst_i = '1') then
      data_from_codec <= (others => '0');
      data_from_codec_mask <= (others => '0');
      a2d_fifo_data_in <= (others => '0');
      a2d_fifo_write_enable <= '0';
    --
    -- Processing
    --
    elsif rising_edge(wm_clk_i) then
      -- 
      -- Initialize
      --
      a2d_fifo_write_enable <= '0';
      
      --
      -- Data from the codec is stable on the rising edge of
      -- the bclk (when bclk = '0')
      -- 
      if (codec_bclk = '0') then
        --
        -- When the sample clock is '1' prepare to read data
        -- from the codec.
        --
        if (codec_sample_clock = '1') then
          --
          -- There should be a sample from the codec waiting.
          -- Write it into the FIFO and prepare the register
          -- for the next sample.  If the FIFO is full the
          -- sample is going to be lost.
          --
          if (a2d_fifo_full = '0') then
            a2d_fifo_data_in <= data_from_codec;
            a2d_fifo_write_enable <= '1';
          end if;
          data_from_codec <= (others => '0');
          data_from_codec_mask <= (others => '1');            

        --
        -- If the sample clock is '0' you are reading data
        -- from the codec.
        --
        else
          --
          -- Read as long as one of the bits in the data codec mask
          -- is '1'.
          --
          if or_reduce(data_from_codec_mask) = '1' then
            data_from_codec <= data_from_codec(30 downto 0) & wm_adcdat_i;
          end if;
          
          -- 
          -- Shift the mask along with the data.
          --
          data_from_codec_mask <= data_from_codec_mask(30 downto 0) & '0';
        end if;
      end if;
    end if;
  end process;

  -- 
  -- Outgoing signals to the WM8731
  -- 
  wm_bclk_o <= codec_bclk;
  wm_lrc_o  <= codec_sample_clock;
  wm_dacdat_o <= data_to_codec(31);
  
  -- END PROCESSING
    
end BEHAVIORAL;


