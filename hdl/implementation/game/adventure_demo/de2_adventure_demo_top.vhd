library ieee;
use ieee.std_logic_1164.all;

-- VAGE (VHDL Advanced Game Engine) demo using the 'Adventure' game demo and
-- the Altera DE2 board as a hardware platform. The purpose of this file is
-- simply to instantiate the game top entity. It should not contain any game-
-- related code. This is also a perfect place for vendor-specific and board-
-- specific code, such as PLLs.
entity de2_adventure_demo_top is
    -- Port names as defined in the standard DE2 settings file.
    port (
        -- 50 MHz clock provided by the DE2  board
        clock_50: in std_logic;
        -- Input toggle switches
        sw: in std_logic_vector(17 downto 0);
        -- Input push-button switches, active low
        key: in std_logic_vector(3 downto 0);
        -- Green leds
        ledg: out std_logic_vector(7 downto 0);
        -- Pixel clock for the ADV7123 video DAC
        vga_clk: out std_logic;
        -- VGA blank signal, high outside of active area
        vga_blank: out std_logic;
        -- VGA horizontal sync, pulsed low between lines
        vga_hs: out std_logic;
        -- VGA vertical sync, pulsed low between frames
        vga_vs: out std_logic;
        -- Composite sync for the ADV7123; if not used, should be tied low
        vga_sync: out std_logic;
        -- VGA red channel output
        vga_r: out std_logic_vector(9 downto 0);
        -- VGA green channel output
        vga_g: out std_logic_vector(9 downto 0);
        -- VGA blue channel output
        vga_b: out std_logic_vector(9 downto 0)
    );
end;

architecture rtl of de2_adventure_demo_top is

    -- Component declaration for the PLL used to generate the 25 MHz pixel
    -- clock from the board 50 MHz system clock
    component video_pll
        port(
            inclk0: in std_logic := '0';
            c0: out std_logic
        );
    end component;

    signal vga_pll_clock_out: std_logic;

begin

    game: entity work.adventure_demo_top
        port map(
            clock_50_Mhz  => clock_50,
            reset => sw(17),
            debug_bits => ledg,
            vga_clock_in => vga_pll_clock_out,
            vga_clock_out => vga_clk,
            vga_blank => vga_blank,
            vga_n_hsync => vga_hs,
            vga_n_vsync => vga_vs,
            vga_n_sync => vga_sync,
            vga_red => vga_r,
            vga_green => vga_g,
            vga_blue => vga_b,
            input_switches => sw(1 downto 0),
            input_buttons  => not key
        );

    -- Instantiate a PLL to generate the pixel clock frequency (~25 MHZ),
    -- using the DE2 50Mhz clock as input
    video_PLL_inst : video_PLL port map (
        inclk0 => clock_50,
        c0 => vga_pll_clock_out
    );

end;