
-- This file described an I2S interface with Wishbone interface.
--
-- Left channel data is returned in the upper 16 bits of the returned data.

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
library UNISIM;
use UNISIM.Vcomponents.ALL;

library DesignLab;
use DesignLab.ALL;

entity I2S is
  generic (
    CHANNEL_STATE_LENGTH : integer := 6;
    AUDIO_DATA_WIDTH : integer := 16
  );
  port (
    wishbone_in  : in    std_logic_vector (100 downto 0);
    wishbone_out : out   std_logic_vector (100 downto 0);

    -- Put your external connections here
	  sclk_in  : in  std_logic;
	  lrclk_in : in  std_logic;
    audio_in : in  std_logic;
    left_channel_out  : out std_logic_vector(15 downto 0);

	  sclk_out : out std_logic;
	  lrclk_out: out std_logic
  );
end I2S;

architecture BEHAVIORAL of I2S is

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
  -- Simple register to hold contents of a Wishbone read/write.
  --
  signal register0: std_logic_vector(31 downto 0);

  -- Positive/negative edge of the i2s bit clock.
  signal sclk_neg_edge            : std_logic;
  signal sclk_pos_edge            : std_logic;
  signal zsclk, zzsclk, zzzsclk   : std_logic;

  -- Positive/negative edge of the lr clock
  signal lrclk_neg_edge           : std_logic;
  signal lrclk_pos_edge           : std_logic;
  signal zlrclk, zzlrclk, zzzlrclk: std_logic;

  -- Clocks to define a data frame
  signal left_channel_clock       : std_logic;

  -- State clocks
  signal left_channel_state       : unsigned(CHANNEL_STATE_LENGTH-1 downto 0);

  -- Registers to hold the left/right channel data.
  signal left_channel_data        : std_logic_vector(AUDIO_DATA_WIDTH-1 downto 0);
  signal left_channel_reg         : std_logic_vector(AUDIO_DATA_WIDTH-1 downto 0);

begin

  -- Begin the architecture code.
  --
  -- REGION - WISHBONE PROCESSES
  --
  -- Acknowledge all tranfers per the wishbone spec.
  --
  wb_ack_o <= wb_stb_i and wb_cyc_i;

  --
  -- Tie interrupt to '0', we never interrupt
  --
  wb_inta_o <= '0';

  --
  -- Wishbone write process.
  -- Write register processing loop.
  --
  process(wb_clk_i, wb_rst_i)
  begin
    if (wb_rst_i = '1') then
      --
      -- Circuit reset.
      --
      register0 <= (others => '0');   -- Initialize register to all '0'

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
            --
            register0 <= wb_dat_i;
          when others =>
        end case;
      end if;
    end if;
  end process;

  --
  -- Wishbone read process.
  -- Load the output data when address is read.
  --
  process(wb_adr_i, register0, left_channel_reg)
  begin
    case wb_adr_i(4 downto 2) is
      when "000" =>
        --
        -- Store the value to be returned.
        --
        wb_dat_o(31 downto 0) <= (others => '0');
        wb_dat_o(31 downto 0) <= register0;
      when "001" =>
        -- Put out the sound data.
        wb_dat_o(31 downto 0) <= (others => '0');
        wb_dat_o(31 downto AUDIO_DATA_WIDTH) <= left_channel_reg;
        wb_dat_o(AUDIO_DATA_WIDTH-1 downto 0) <= (others => '0');
      when others =>
        wb_dat_o(31 downto 0) <= (others => '0');
    end case;
  end process;

  -- END WISHBONE PROCESSES

  -- REGION HARDWARE PROCESSES
  --
  -- Process to detect the positive and negative edges of the sclk.
  -- This process syncs the sclk into the FPGA clock domain.
  -- For a description of how this works, see
  -- https://www.doulos.com/knowhow/fpga/synchronisation/
  -- These edge signals are only valid for a single system clock.
  --
  detect_sclk_edge : process(wb_rst_i, wb_clk_i)
  begin
    if wb_rst_i = '1' then
      zsclk <= '0';
      zzsclk <= '0';
      zzzsclk <= '0';
      sclk_pos_edge <= '0';
      sclk_neg_edge <= '0';
    elsif rising_edge(wb_clk_i) then
      zsclk   <= sclk_in;
      zzsclk  <= zsclk;
      zzzsclk <= zzsclk;
      if zzsclk = '1' and zzzsclk = '0' then
        sclk_pos_edge <= '1';
        sclk_neg_edge <= '0';
      elsif zzsclk = '0' and zzzsclk = '1' then
        sclk_pos_edge <= '0';
        sclk_neg_edge <= '1';
      else
        sclk_pos_edge <= '0';
        sclk_neg_edge <= '0';
      end if;
    end if;
  end process;

  --
  -- Process to detect the positive and negative edges of the lrclk.
  -- This process syncs the lrclk into the FPGA clock domain.
  -- For a description of how this works, see
  -- https://www.doulos.com/knowhow/fpga/synchronisation/
  -- These edge signals are only valid for a single system clock.
  --
  detect_lrclk_edge : process(wb_rst_i, wb_clk_i)
  begin
    if wb_rst_i = '1' then
      zlrclk <= '0';
      zzlrclk <= '0';
      zzzlrclk <= '0';
      lrclk_pos_edge <= '0';
      lrclk_neg_edge <= '0';
      left_channel_clock <= '0';
    elsif rising_edge(wb_clk_i) then
      zlrclk   <= lrclk_in;
      zzlrclk  <= zlrclk;
      zzzlrclk <= zzlrclk;
      if zzlrclk = '1' and zzzlrclk = '0' then
        lrclk_pos_edge <= '1';
        lrclk_neg_edge <= '0';
        left_channel_clock <= '0';
      elsif zzlrclk = '0' and zzzlrclk = '1' then
        lrclk_pos_edge <= '0';
        lrclk_neg_edge <= '1';
			  left_channel_clock <= '1';
      else
        lrclk_pos_edge <= '0';
        lrclk_neg_edge <= '0';
      end if;
    end if;
  end process;

  --
  -- Process to create state counter for the left channel.
  -- and sample the incoming left channel data.
  --
  process(wb_rst_i, wb_clk_i)
    variable left_state : integer := 0;
  begin
    if wb_rst_i = '1' then
      --
      -- Initialize.
      --
      left_channel_state <= (others => '0');
      left_channel_data  <= (others => '0');
      left_channel_reg   <= (others => '0');
    elsif rising_edge(wb_clk_i) then
      --
      -- Only process on the rising edge of the sclk.
      --
      if sclk_pos_edge = '1' then
        --
        -- Set state to a local variable to make things
        -- easier later.
        --
        left_state := to_integer(left_channel_state);

        --
        -- Processing for the left channel.
        --
        if left_channel_clock = '1' then
          --
          -- Update the channel state
          --
          left_channel_state <= to_unsigned(to_integer(left_channel_state) + 1, CHANNEL_STATE_LENGTH);

          --
          -- Update the channel and output data.
          --
          if left_state = 0 then
            left_channel_data <= (others => '0');
          elsif left_state < AUDIO_DATA_WIDTH then
            left_channel_data <= left_channel_data(AUDIO_DATA_WIDTH-2 downto 0) & audio_in;
          end if;

          --
          -- Move data to the output.
          --
          if left_state = 0 then
            left_channel_reg <= left_channel_data(AUDIO_DATA_WIDTH-2 downto 0) & '0';
          end if;
        else
          left_channel_state <= (others => '0');
        end if;
      end if;
    end if;
  end process;
  left_channel_out <= left_channel_reg;

  lrclk_out <= left_channel_clock;       -- debug signal
  sclk_out <= audio_in;                  -- debug signal

end BEHAVIORAL;
