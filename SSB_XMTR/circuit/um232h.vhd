----------------------------------------------------------------------------------
-- Company:  CAAMS
-- Engineer: FANHX
-- 
-- Create Date:    10:12:13 10/05/2014 
-- Design Name: 
-- Module Name:    UM232H - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--    Obtained from 
--    https://github.com/zpcaams/nir_usb/blob/master/VHDL/FT232H.txt
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity um232h is
  generic(
    xmit_data_len:INTEGER :=8;
    recv_data_len :INTEGER :=8
  );
  port( 
    -- system signals
    clk           : in    std_logic;
    reset         : in    std_logic;
    -- FT232H signals
    data          : inout std_logic_vector(7 downto 0);
    rxf           : in    std_logic;
    txe           : in    std_logic;
    rd            : out   std_logic;
    wr            : out   std_logic;
    usb_clock     : in    std_logic;
    oe            : out   std_logic;
    -- FIFO signals
    rx_data       : out   std_logic_vector(7 downto 0);
    rx_data_ready : out   std_logic
  );
end um232h;

architecture behavioral of um232h is
  -- Define the allowed states for the transmit
  -- and receive state machines.
  type R_STATES is (
    R_ST0, R_ST1, R_ST2, R_ST3
  );
  type T_STATES is (
    T_ST0, T_ST1, T_ST2, T_ST3
  );
  
  --
  -- Flag going from clock domain A to clock domain B with ack.
  --
  component async_flagack is
  port (
    clkA        : in std_logic;
    FlagIn_clkA : in std_logic;
    Busy_clkA   : out std_logic;
    clkB        : in std_logic;
    FlagOut_clkB: out std_logic
  );
  end component async_flagack;
  signal rx_data_flag:std_logic;      -- connects to flag in
  signal rx_data_busy:std_logic;      -- connects to the busy flag
  
  signal t_buffer:std_logic_vector(7 downto 0);
  
  signal curr_recv_state:R_STATES;    -- current read state
  signal next_recv_state:R_STATES;    -- next read state
  signal curr_xmit_state:T_STATES;    -- current transmit state
  signal next_xmit_state:T_STATES;    -- next transmit state

begin
  --
  -- Instance of the async flag
  -- Flag goes from the FT232H clock domain to the
  -- system clock domain
  --
  sample_flag: async_flagack
  port map (
    clkA         => usb_clock,
    FlagIn_clkA  => rx_data_flag,
    Busy_clkA    => rx_data_busy,
    clkB         => clk,
    FlagOut_clkB => rx_data_ready
  );
  
  --
  -- Process to read data from the interface.
  --
  process(reset, usb_clock)
  begin
    if (reset = '1') then
      --
      -- Reset the receive state machine.
      --
      oe <= '1';
      rd <= '1';
      next_recv_state <= R_ST0;      
    elsif (rising_edge(usb_clock)) then
      --
      -- Normal processing.
      --
      rx_data_flag <= '0';
      if (rxf = '0') then
        --
        -- RXF is low, indicating data is ready to be read.
        -- Required processing depends on the current state.
        --
        case curr_recv_state is
          when R_ST0 =>
            -- 1. RXF is low so you can pull OE low.
            -- 2. You can't pull RD low for another clock cycle so
            --    RD should be high.
            -- 3. Move to the next state.
            oe <= '0';
            rd <= '1';
            next_recv_state <= R_ST1;
          when R_ST1 =>
            -- 1. OE is low.  Keep it low and pull RD low as low.
            -- 2. The data will be placed on the bus and can be
            --    read on the next clock rising edge.
            -- 3. Move to the next state.
            oe <= '0';
            rd <= '0';
            next_recv_state <= R_ST2;
          when R_ST2 =>
            -- 1. Read data from the bus and put it in the FIFO.
            -- 2. Set the flag indicating data is read for reading.
            -- You'll continue reading data from the bus on each
            -- rising clock edge.
            oe <= '0';
            wr <= '0';
            if (rx_data_busy = '0') then
              rx_data <= data;
              rx_data_flag <= '1';
            end if;
          when others =>
        end case;
      else
        -- 
        -- RXF has gone back high so reset the signal levels
        -- and state.
        --
        oe <= '1';
        wr <= '1';
        next_recv_state <= R_ST0;
      end if;
    end if;
  end process;
  curr_recv_state <= next_recv_state;

end behavioral;