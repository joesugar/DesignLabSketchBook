---------------------------------------------------------------------
----                                                             ----
---- Copyright (C) 2016 Joseph A. Consugar                       ----                       ----
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
-- This file is a Wishbone interface for the simple DAC included
-- as part of the Papilio Design Lab software.
--

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
library UNISIM;
use UNISIM.Vcomponents.ALL;

library DesignLab;
use DesignLab.ALL;

entity Simple_Dac is
  generic (
    AUDIO_DATA_WIDTH : integer := 16
  );
  port (
    wishbone_in  : in    std_logic_vector (100 downto 0);
    wishbone_out : out   std_logic_vector (100 downto 0);

    -- Put your external connections here
	  left_audio_out   : out   std_logic;
    right_audio_out  : out   std_logic
  );
end Simple_Dac;

architecture BEHAVIORAL of Simple_Dac is

  -- Put your unique register names here
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
  -- Internal components.
  --
  component dac_simplesd is
    generic (
      nbits : integer := AUDIO_DATA_WIDTH       -- Number of DAC bits.
    );
    port (
      din     : in  signed((nbits-1) downto 0); -- incoming data
      dout    : out std_logic;                  -- outgoing audio
      clk     : in  std_logic;                  -- system clock
      clk_ena : in  std_logic;                  -- clock enable
      rst     : in  std_logic                   -- system reset
    );
  end component;

  --
  -- Simple register to hold contents of a Wishbone read/write.
  --
  signal left_channel_in  : signed(AUDIO_DATA_WIDTH-1 downto 0);
  signal right_channel_in : signed(AUDIO_DATA_WIDTH-1 downto 0);

begin
  --
  -- Instance of the simple DAC
  --
  left_channel: dac_simplesd
  port map (
    din     => left_channel_in,
	  dout    => left_audio_out,
	  clk     => wb_clk_i,
	  clk_ena => '1',
	  rst     => wb_rst_i
  );

  right_channel: dac_simplesd
  port map (
    din     => right_channel_in,
	  dout    => right_audio_out,
	  clk     => wb_clk_i,
	  clk_ena => '1',
	  rst     => wb_rst_i
  );

  --
  -- Begin the architecture code.
  --
  -- Acknowledge all transfers per the wishbone spec.
  --
  wb_ack_o <= wb_stb_i and wb_cyc_i;

  --
  -- Tie interrupt to '0', we never interrupt
  --
  wb_inta_o <= '0';

  --
  -- Write data processing loop.
  --
  process(wb_clk_i, wb_rst_i)
  begin
    if (wb_rst_i = '1') then
      --
      -- Circuit reset.
      --
      left_channel_in  <= (others => '0');  -- Initialize register to all '0'
      right_channel_in <= (others => '0');  -- Initialize register to all '0'

    elsif (rising_edge(wb_clk_i)) then
      --
      -- On the rising edge of the clock...
      --
      if (wb_cyc_i='1' and wb_stb_i='1' and wb_we_i='1') then
        --
        -- Decoded as a write signal.
        --
        case wb_adr_i(4 downto 2) is
          when "000" =>
            --
            -- Accessing register 000
            -- Save the written value.
            -- We're only interested in 16 bits interpreted
            -- as a signed value.
            --
            left_channel_in  <= signed(wb_dat_i(31 downto 32-AUDIO_DATA_WIDTH));
            right_channel_in <= signed(wb_dat_i(15 downto 16-AUDIO_DATA_WIDTH));
          when others =>
        end case;
      end if;
    end if;
  end process;

  --
  -- Load the output data when address is read.
  --
  process(wb_adr_i, left_channel_in)
  begin
    case wb_adr_i(4 downto 2) is
      when "000" =>
        --
        -- Store the value to be returned.
        -- Put the last written value back into the lowest 16 bits of
        -- the return register.
        --
        wb_dat_o(31 downto 0) <= (others => '0');
        wb_dat_o(31 downto 32-AUDIO_DATA_WIDTH) <= std_logic_vector(left_channel_in);
        wb_dat_o(15 downto 16-AUDIO_DATA_WIDTH) <= std_logic_vector(right_channel_in);
      when others =>
        wb_dat_o(31 downto 0) <= (others => '0');
    end case;
  end process;
end BEHAVIORAL;
