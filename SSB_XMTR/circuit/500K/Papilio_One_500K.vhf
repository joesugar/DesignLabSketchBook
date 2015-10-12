--------------------------------------------------------------------------------
-- Copyright (c) 1995-2012 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____ 
--  /   /\/   / 
-- /___/  \  /    Vendor: Xilinx 
-- \   \   \/     Version : 14.2
--  \   \         Application : sch2hdl
--  /   /         Filename : Papilio_One_500K.vhf
-- /___/   /\     Timestamp : 10/11/2015 22:44:04
-- \   \  /  \ 
--  \___\/\___\ 
--
--Command: sch2hdl -sympath /home/joseph/DesignLab/libraries/VGA_ZXSpectrum -sympath /home/joseph/DesignLab/libraries/AVR_Wishbone_Bridge -sympath /home/joseph/DesignLab/libraries/Benchy -sympath /home/joseph/DesignLab/libraries/Robot_Control_Library -sympath /home/joseph/DesignLab/libraries/Building_Blocks -sympath /home/joseph/DesignLab/libraries/VGA_ZPUino -sympath /home/joseph/DesignLab/libraries/HQVGA -sympath /home/joseph/DesignLab/libraries/Papilio_Hardware -sympath /home/joseph/DesignLab/libraries/BitCoin_Miner -sympath /home/joseph/DesignLab/libraries/Clocks -sympath /home/joseph/DesignLab/libraries/ZPUino_2 -sympath /home/joseph/DesignLab/libraries/RGB_Matrix -sympath /home/joseph/DesignLab/libraries/Gameduino -sympath /home/joseph/DesignLab/libraries/ZPUino_Wishbone_Peripherals -sympath /home/joseph/DesignLab/libraries/clocks -sympath /home/joseph/DesignLab/sketchbook/libraries/i2c -sympath /home/joseph/DesignLab/sketchbook/libraries/Template_DesignLab_Library -sympath /home/joseph/DesignLab/sketchbook/libraries/PSK31 -sympath /home/joseph/DesignLab/sketchbook/libraries/NCO -sympath /home/joseph/DesignLab/sketchbook/libraries/CORDIC_NCO -sympath /home/joseph/DesignLab/sketchbook/libraries/WM8731 -sympath /home/joseph/DesignLab/sketchbook/SSB_XMTR/circuit/500K -intstyle ise -family spartan3e -flat -suppress -vhdl /home/joseph/DesignLab/sketchbook/SSB_XMTR/circuit/500K/Papilio_One_500K.vhf -w /home/joseph/DesignLab/sketchbook/SSB_XMTR/circuit/Papilio_One_500K.sch
--Design Name: Papilio_One_500K
--Device: spartan3e
--Purpose:
--    This vhdl netlist is translated from an ECS schematic. It can be 
--    synthesized and simulated, but it should not be modified. 
--

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
library UNISIM;
use UNISIM.Vcomponents.ALL;

entity Papilio_One_500K is
   port ( ext_pins_in    : in    std_logic_vector (100 downto 0); 
          WING_AH4       : in    std_logic; 
          WING_AH6       : in    std_logic; 
          ext_pins_out   : out   std_logic_vector (100 downto 0); 
          WING_AH5       : out   std_logic; 
          WING_AH7       : out   std_logic; 
          WING_CH0       : out   std_logic; 
          WING_CH1       : out   std_logic; 
          WING_CH2       : out   std_logic; 
          WING_CH3       : out   std_logic; 
          WING_CH4       : out   std_logic; 
          WING_CH5       : out   std_logic; 
          WING_CH6       : out   std_logic; 
          WING_CH7       : out   std_logic; 
          ext_pins_inout : inout std_logic_vector (100 downto 0); 
          WING_AH0       : inout std_logic; 
          WING_AH1       : inout std_logic; 
          WING_AH2       : inout std_logic; 
          WING_AH3       : inout std_logic; 
          WING_AL0       : inout std_logic; 
          WING_AL1       : inout std_logic; 
          WING_AL2       : inout std_logic; 
          WING_AL3       : inout std_logic; 
          WING_AL4       : inout std_logic; 
          WING_AL5       : inout std_logic; 
          WING_AL6       : inout std_logic; 
          WING_AL7       : inout std_logic; 
          WING_BH0       : inout std_logic; 
          WING_BH1       : inout std_logic; 
          WING_BH2       : inout std_logic; 
          WING_BH3       : inout std_logic; 
          WING_BH4       : inout std_logic; 
          WING_BH5       : inout std_logic; 
          WING_BH6       : inout std_logic; 
          WING_BH7       : inout std_logic; 
          WING_BL0       : inout std_logic; 
          WING_BL1       : inout std_logic; 
          WING_BL2       : inout std_logic; 
          WING_BL3       : inout std_logic; 
          WING_BL4       : inout std_logic; 
          WING_BL5       : inout std_logic; 
          WING_BL6       : inout std_logic; 
          WING_BL7       : inout std_logic; 
          WING_CL0       : inout std_logic; 
          WING_CL1       : inout std_logic; 
          WING_CL2       : inout std_logic; 
          WING_CL3       : inout std_logic; 
          WING_CL4       : inout std_logic; 
          WING_CL5       : inout std_logic; 
          WING_CL6       : inout std_logic; 
          WING_CL7       : inout std_logic);
end Papilio_One_500K;

architecture BEHAVIORAL of Papilio_One_500K is
   signal XLXN_325                                  : std_logic_vector (7 
         downto 0);
   signal XLXN_326                                  : std_logic_vector (7 
         downto 0);
   signal XLXN_327                                  : std_logic_vector (7 
         downto 0);
   signal XLXN_328                                  : std_logic_vector (7 
         downto 0);
   signal XLXN_329                                  : std_logic_vector (7 
         downto 0);
   signal XLXN_330                                  : std_logic_vector (7 
         downto 0);
   signal XLXN_331                                  : std_logic_vector (7 
         downto 0);
   signal XLXN_332                                  : std_logic_vector (7 
         downto 0);
   signal XLXN_333                                  : std_logic_vector (7 
         downto 0);
   signal XLXN_334                                  : std_logic_vector (7 
         downto 0);
   signal XLXN_335                                  : std_logic_vector (7 
         downto 0);
   signal XLXN_336                                  : std_logic_vector (7 
         downto 0);
   signal XLXN_408                                  : std_logic_vector (200 
         downto 0);
   signal XLXN_409                                  : std_logic_vector (200 
         downto 0);
   signal XLXN_410                                  : std_logic_vector (100 
         downto 0);
   signal XLXN_411                                  : std_logic_vector (100 
         downto 0);
   signal XLXN_412                                  : std_logic_vector (7 
         downto 0);
   signal XLXN_436                                  : std_logic_vector (100 
         downto 0);
   signal XLXN_437                                  : std_logic_vector (100 
         downto 0);
   signal XLXN_439                                  : std_logic_vector (100 
         downto 0);
   signal XLXN_440                                  : std_logic_vector (100 
         downto 0);
   signal XLXI_47_Flex_Pin_out_0_openSignal         : std_logic;
   signal XLXI_47_Flex_Pin_out_1_openSignal         : std_logic;
   signal XLXI_47_Flex_Pin_out_2_openSignal         : std_logic;
   signal XLXI_47_Flex_Pin_out_3_openSignal         : std_logic;
   signal XLXI_47_Flex_Pin_out_4_openSignal         : std_logic;
   signal XLXI_47_Flex_Pin_out_5_openSignal         : std_logic;
   signal XLXI_48_wishbone_slot_video_in_openSignal : std_logic_vector (100 
         downto 0);
   signal XLXI_48_wishbone_slot_9_out_openSignal    : std_logic_vector (100 
         downto 0);
   signal XLXI_48_wishbone_slot_10_out_openSignal   : std_logic_vector (100 
         downto 0);
   signal XLXI_48_wishbone_slot_11_out_openSignal   : std_logic_vector (100 
         downto 0);
   signal XLXI_48_wishbone_slot_12_out_openSignal   : std_logic_vector (100 
         downto 0);
   signal XLXI_48_wishbone_slot_13_out_openSignal   : std_logic_vector (100 
         downto 0);
   signal XLXI_48_wishbone_slot_14_out_openSignal   : std_logic_vector (100 
         downto 0);
   signal XLXI_55_wm_adcdat_i_openSignal            : std_logic;
   signal XLXI_55_wm_clk_i_openSignal               : std_logic;
   signal XLXI_55_wm_rst_i_openSignal               : std_logic;
   component Wing_GPIO
      port ( wt_miso : inout std_logic_vector (7 downto 0); 
             wt_mosi : inout std_logic_vector (7 downto 0));
   end component;
   
   component Papilio_Default_Wing_Pinout
      port ( WING_AH0         : inout std_logic; 
             WING_AH1         : inout std_logic; 
             WING_AH2         : inout std_logic; 
             WING_AH3         : inout std_logic; 
             WING_AH4         : inout std_logic; 
             WING_AH5         : inout std_logic; 
             WING_AH6         : inout std_logic; 
             WING_AH7         : inout std_logic; 
             WING_AL0         : inout std_logic; 
             WING_AL1         : inout std_logic; 
             WING_AL2         : inout std_logic; 
             WING_AL3         : inout std_logic; 
             WING_AL4         : inout std_logic; 
             WING_AL5         : inout std_logic; 
             WING_AL6         : inout std_logic; 
             WING_AL7         : inout std_logic; 
             WING_BH0         : inout std_logic; 
             WING_BH1         : inout std_logic; 
             WING_BH2         : inout std_logic; 
             WING_BH3         : inout std_logic; 
             WING_BH4         : inout std_logic; 
             WING_BH5         : inout std_logic; 
             WING_BH6         : inout std_logic; 
             WING_BH7         : inout std_logic; 
             WING_BL0         : inout std_logic; 
             WING_BL1         : inout std_logic; 
             WING_BL2         : inout std_logic; 
             WING_BL3         : inout std_logic; 
             WING_BL4         : inout std_logic; 
             WING_BL5         : inout std_logic; 
             WING_BL6         : inout std_logic; 
             WING_BL7         : inout std_logic; 
             WING_CL0         : inout std_logic; 
             WING_CL1         : inout std_logic; 
             WING_CL2         : inout std_logic; 
             WING_CL3         : inout std_logic; 
             WING_CL4         : inout std_logic; 
             WING_CL5         : inout std_logic; 
             WING_CL6         : inout std_logic; 
             WING_CL7         : inout std_logic; 
             WING_CH0         : inout std_logic; 
             WING_CH1         : inout std_logic; 
             WING_CH2         : inout std_logic; 
             WING_CH3         : inout std_logic; 
             WING_CH4         : inout std_logic; 
             WING_CH5         : inout std_logic; 
             WING_CH6         : inout std_logic; 
             WING_CH7         : inout std_logic; 
             gpio_bus_out     : in    std_logic_vector (200 downto 0); 
             gpio_bus_in      : out   std_logic_vector (200 downto 0); 
             WingType_miso_BH : inout std_logic_vector (7 downto 0); 
             WingType_miso_BL : inout std_logic_vector (7 downto 0); 
             WingType_miso_AH : inout std_logic_vector (7 downto 0); 
             WingType_mosi_BL : inout std_logic_vector (7 downto 0); 
             WingType_mosi_BH : inout std_logic_vector (7 downto 0); 
             WingType_mosi_CL : inout std_logic_vector (7 downto 0); 
             WingType_mosi_AH : inout std_logic_vector (7 downto 0); 
             WingType_miso_CL : inout std_logic_vector (7 downto 0); 
             WingType_miso_CH : inout std_logic_vector (7 downto 0); 
             WingType_mosi_CH : inout std_logic_vector (7 downto 0); 
             WingType_mosi_AL : inout std_logic_vector (7 downto 0); 
             WingType_miso_AL : inout std_logic_vector (7 downto 0); 
             Flex_Pin_out_0   : in    std_logic; 
             Flex_Pin_out_1   : in    std_logic; 
             Flex_Pin_out_2   : in    std_logic; 
             Flex_Pin_out_3   : in    std_logic; 
             Flex_Pin_out_4   : in    std_logic; 
             Flex_Pin_out_5   : in    std_logic; 
             Flex_Pin_in_0    : out   std_logic; 
             Flex_Pin_in_1    : out   std_logic; 
             Flex_Pin_in_2    : out   std_logic; 
             Flex_Pin_in_3    : out   std_logic; 
             Flex_Pin_in_4    : out   std_logic; 
             Flex_Pin_in_5    : out   std_logic);
   end component;
   
   component ZPUino_Papilio_One_500K_V2
      port ( clk_96Mhz               : out   std_logic; 
             clk_1Mhz                : out   std_logic; 
             clk_osc_32Mhz           : out   std_logic; 
             ext_pins_in             : in    std_logic_vector (100 downto 0); 
             ext_pins_out            : out   std_logic_vector (100 downto 0); 
             ext_pins_inout          : inout std_logic_vector (100 downto 0); 
             gpio_bus_out            : out   std_logic_vector (200 downto 0); 
             gpio_bus_in             : in    std_logic_vector (200 downto 0); 
             wishbone_slot_5_out     : in    std_logic_vector (100 downto 0); 
             wishbone_slot_5_in      : out   std_logic_vector (100 downto 0); 
             wishbone_slot_6_in      : out   std_logic_vector (100 downto 0); 
             wishbone_slot_6_out     : in    std_logic_vector (100 downto 0); 
             wishbone_slot_8_in      : out   std_logic_vector (100 downto 0); 
             wishbone_slot_8_out     : in    std_logic_vector (100 downto 0); 
             wishbone_slot_9_in      : out   std_logic_vector (100 downto 0); 
             wishbone_slot_9_out     : in    std_logic_vector (100 downto 0); 
             wishbone_slot_10_in     : out   std_logic_vector (100 downto 0); 
             wishbone_slot_10_out    : in    std_logic_vector (100 downto 0); 
             wishbone_slot_11_in     : out   std_logic_vector (100 downto 0); 
             wishbone_slot_11_out    : in    std_logic_vector (100 downto 0); 
             wishbone_slot_12_in     : out   std_logic_vector (100 downto 0); 
             wishbone_slot_12_out    : in    std_logic_vector (100 downto 0); 
             wishbone_slot_13_in     : out   std_logic_vector (100 downto 0); 
             wishbone_slot_13_out    : in    std_logic_vector (100 downto 0); 
             wishbone_slot_14_in     : out   std_logic_vector (100 downto 0); 
             wishbone_slot_14_out    : in    std_logic_vector (100 downto 0); 
             wishbone_slot_video_in  : in    std_logic_vector (100 downto 0); 
             wishbone_slot_video_out : out   std_logic_vector (100 downto 0); 
             vgaclkout               : out   std_logic);
   end component;
   
   component CORDIC_NCO
      port ( wishbone_in  : in    std_logic_vector (100 downto 0); 
             d2a_data     : out   std_logic_vector (7 downto 0); 
             wishbone_out : out   std_logic_vector (100 downto 0); 
             d2a_clk      : out   std_logic);
   end component;
   
   component bus8
      port ( bus8 : in    std_logic_vector (7 downto 0); 
             bus0 : out   std_logic; 
             bus1 : out   std_logic; 
             bus2 : out   std_logic; 
             bus3 : out   std_logic; 
             bus4 : out   std_logic; 
             bus5 : out   std_logic; 
             bus6 : out   std_logic; 
             bus7 : out   std_logic);
   end component;
   
   component WM8731
      port ( wm_clk_i     : in    std_logic; 
             wm_rst_i     : in    std_logic; 
             wm_adcdat_i  : in    std_logic; 
             wishbone_in  : in    std_logic_vector (100 downto 0); 
             wm_bclk_o    : out   std_logic; 
             wm_lrc_o     : out   std_logic; 
             wm_dacdat_o  : out   std_logic; 
             wishbone_out : out   std_logic_vector (100 downto 0));
   end component;
   
   component i2c
      port ( scl_pad_i    : in    std_logic; 
             sda_pad_i    : in    std_logic; 
             wishbone_in  : in    std_logic_vector (100 downto 0); 
             scl_pad_o    : out   std_logic; 
             scl_padoen_o : out   std_logic; 
             sda_pad_o    : out   std_logic; 
             sda_padoen_o : out   std_logic; 
             wishbone_out : out   std_logic_vector (100 downto 0); 
             debug        : out   std_logic);
   end component;
   
begin
   XLXI_22 : Wing_GPIO
      port map (wt_miso(7 downto 0)=>XLXN_325(7 downto 0),
                wt_mosi(7 downto 0)=>XLXN_326(7 downto 0));
   
   XLXI_23 : Wing_GPIO
      port map (wt_miso(7 downto 0)=>XLXN_327(7 downto 0),
                wt_mosi(7 downto 0)=>XLXN_328(7 downto 0));
   
   XLXI_24 : Wing_GPIO
      port map (wt_miso(7 downto 0)=>XLXN_329(7 downto 0),
                wt_mosi(7 downto 0)=>XLXN_330(7 downto 0));
   
   XLXI_25 : Wing_GPIO
      port map (wt_miso(7 downto 0)=>XLXN_331(7 downto 0),
                wt_mosi(7 downto 0)=>XLXN_332(7 downto 0));
   
   XLXI_26 : Wing_GPIO
      port map (wt_miso(7 downto 0)=>XLXN_333(7 downto 0),
                wt_mosi(7 downto 0)=>XLXN_334(7 downto 0));
   
   XLXI_27 : Wing_GPIO
      port map (wt_miso(7 downto 0)=>XLXN_335(7 downto 0),
                wt_mosi(7 downto 0)=>XLXN_336(7 downto 0));
   
   XLXI_47 : Papilio_Default_Wing_Pinout
      port map (Flex_Pin_out_0=>XLXI_47_Flex_Pin_out_0_openSignal,
                Flex_Pin_out_1=>XLXI_47_Flex_Pin_out_1_openSignal,
                Flex_Pin_out_2=>XLXI_47_Flex_Pin_out_2_openSignal,
                Flex_Pin_out_3=>XLXI_47_Flex_Pin_out_3_openSignal,
                Flex_Pin_out_4=>XLXI_47_Flex_Pin_out_4_openSignal,
                Flex_Pin_out_5=>XLXI_47_Flex_Pin_out_5_openSignal,
                gpio_bus_out(200 downto 0)=>XLXN_408(200 downto 0),
                Flex_Pin_in_0=>open,
                Flex_Pin_in_1=>open,
                Flex_Pin_in_2=>open,
                Flex_Pin_in_3=>open,
                Flex_Pin_in_4=>open,
                Flex_Pin_in_5=>open,
                gpio_bus_in(200 downto 0)=>XLXN_409(200 downto 0),
                WingType_miso_AH(7 downto 0)=>XLXN_333(7 downto 0),
                WingType_miso_AL(7 downto 0)=>XLXN_335(7 downto 0),
                WingType_miso_BH(7 downto 0)=>XLXN_329(7 downto 0),
                WingType_miso_BL(7 downto 0)=>XLXN_331(7 downto 0),
                WingType_miso_CH(7 downto 0)=>XLXN_325(7 downto 0),
                WingType_miso_CL(7 downto 0)=>XLXN_327(7 downto 0),
                WingType_mosi_AH(7 downto 0)=>XLXN_334(7 downto 0),
                WingType_mosi_AL(7 downto 0)=>XLXN_336(7 downto 0),
                WingType_mosi_BH(7 downto 0)=>XLXN_330(7 downto 0),
                WingType_mosi_BL(7 downto 0)=>XLXN_332(7 downto 0),
                WingType_mosi_CH(7 downto 0)=>XLXN_326(7 downto 0),
                WingType_mosi_CL(7 downto 0)=>XLXN_328(7 downto 0),
                WING_AH0=>WING_AH0,
                WING_AH1=>WING_AH1,
                WING_AH2=>WING_AH2,
                WING_AH3=>WING_AH3,
                WING_AH4=>open,
                WING_AH5=>open,
                WING_AH6=>open,
                WING_AH7=>open,
                WING_AL0=>WING_AL0,
                WING_AL1=>WING_AL1,
                WING_AL2=>WING_AL2,
                WING_AL3=>WING_AL3,
                WING_AL4=>WING_AL4,
                WING_AL5=>WING_AL5,
                WING_AL6=>WING_AL6,
                WING_AL7=>WING_AL7,
                WING_BH0=>WING_BH0,
                WING_BH1=>WING_BH1,
                WING_BH2=>WING_BH2,
                WING_BH3=>WING_BH3,
                WING_BH4=>WING_BH4,
                WING_BH5=>WING_BH5,
                WING_BH6=>WING_BH6,
                WING_BH7=>WING_BH7,
                WING_BL0=>WING_BL0,
                WING_BL1=>WING_BL1,
                WING_BL2=>WING_BL2,
                WING_BL3=>WING_BL3,
                WING_BL4=>WING_BL4,
                WING_BL5=>WING_BL5,
                WING_BL6=>WING_BL6,
                WING_BL7=>WING_BL7,
                WING_CH0=>open,
                WING_CH1=>open,
                WING_CH2=>open,
                WING_CH3=>open,
                WING_CH4=>open,
                WING_CH5=>open,
                WING_CH6=>open,
                WING_CH7=>open,
                WING_CL0=>WING_CL0,
                WING_CL1=>WING_CL1,
                WING_CL2=>WING_CL2,
                WING_CL3=>WING_CL3,
                WING_CL4=>WING_CL4,
                WING_CL5=>WING_CL5,
                WING_CL6=>WING_CL6,
                WING_CL7=>WING_CL7);
   
   XLXI_48 : ZPUino_Papilio_One_500K_V2
      port map (ext_pins_in(100 downto 0)=>ext_pins_in(100 downto 0),
                gpio_bus_in(200 downto 0)=>XLXN_409(200 downto 0),
                wishbone_slot_video_in(100 downto 
            0)=>XLXI_48_wishbone_slot_video_in_openSignal(100 downto 0),
                wishbone_slot_5_out(100 downto 0)=>XLXN_411(100 downto 0),
                wishbone_slot_6_out(100 downto 0)=>XLXN_440(100 downto 0),
                wishbone_slot_8_out(100 downto 0)=>XLXN_437(100 downto 0),
                wishbone_slot_9_out(100 downto 
            0)=>XLXI_48_wishbone_slot_9_out_openSignal(100 downto 0),
                wishbone_slot_10_out(100 downto 
            0)=>XLXI_48_wishbone_slot_10_out_openSignal(100 downto 0),
                wishbone_slot_11_out(100 downto 
            0)=>XLXI_48_wishbone_slot_11_out_openSignal(100 downto 0),
                wishbone_slot_12_out(100 downto 
            0)=>XLXI_48_wishbone_slot_12_out_openSignal(100 downto 0),
                wishbone_slot_13_out(100 downto 
            0)=>XLXI_48_wishbone_slot_13_out_openSignal(100 downto 0),
                wishbone_slot_14_out(100 downto 
            0)=>XLXI_48_wishbone_slot_14_out_openSignal(100 downto 0),
                clk_osc_32Mhz=>open,
                clk_1Mhz=>open,
                clk_96Mhz=>open,
                ext_pins_out(100 downto 0)=>ext_pins_out(100 downto 0),
                gpio_bus_out(200 downto 0)=>XLXN_408(200 downto 0),
                vgaclkout=>open,
                wishbone_slot_video_out=>open,
                wishbone_slot_5_in(100 downto 0)=>XLXN_410(100 downto 0),
                wishbone_slot_6_in(100 downto 0)=>XLXN_439(100 downto 0),
                wishbone_slot_8_in(100 downto 0)=>XLXN_436(100 downto 0),
                wishbone_slot_9_in=>open,
                wishbone_slot_10_in=>open,
                wishbone_slot_11_in=>open,
                wishbone_slot_12_in=>open,
                wishbone_slot_13_in=>open,
                wishbone_slot_14_in=>open,
                ext_pins_inout(100 downto 0)=>ext_pins_inout(100 downto 0));
   
   XLXI_49 : CORDIC_NCO
      port map (wishbone_in(100 downto 0)=>XLXN_410(100 downto 0),
                d2a_clk=>WING_CH0,
                d2a_data(7 downto 0)=>XLXN_412(7 downto 0),
                wishbone_out(100 downto 0)=>XLXN_411(100 downto 0));
   
   XLXI_50 : bus8
      port map (bus8(7 downto 0)=>XLXN_412(7 downto 0),
                bus0=>open,
                bus1=>WING_CH1,
                bus2=>WING_CH2,
                bus3=>WING_CH3,
                bus4=>WING_CH4,
                bus5=>WING_CH5,
                bus6=>WING_CH6,
                bus7=>WING_CH7);
   
   XLXI_55 : WM8731
      port map (wishbone_in(100 downto 0)=>XLXN_436(100 downto 0),
                wm_adcdat_i=>XLXI_55_wm_adcdat_i_openSignal,
                wm_clk_i=>XLXI_55_wm_clk_i_openSignal,
                wm_rst_i=>XLXI_55_wm_rst_i_openSignal,
                wishbone_out(100 downto 0)=>XLXN_437(100 downto 0),
                wm_bclk_o=>open,
                wm_dacdat_o=>open,
                wm_lrc_o=>open);
   
   XLXI_56 : i2c
      port map (scl_pad_i=>WING_AH6,
                sda_pad_i=>WING_AH4,
                wishbone_in(100 downto 0)=>XLXN_439(100 downto 0),
                debug=>open,
                scl_padoen_o=>WING_AH7,
                scl_pad_o=>open,
                sda_padoen_o=>WING_AH5,
                sda_pad_o=>open,
                wishbone_out(100 downto 0)=>XLXN_440(100 downto 0));
   
end BEHAVIORAL;


