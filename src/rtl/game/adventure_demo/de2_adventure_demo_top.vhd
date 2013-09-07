library ieee;
use ieee.std_logic_1164.all;
use work.graphics_types_pkg.all;

-- VAGE (VHDL Advanced Game Engine) demo using the 'Adventure' game demo and
-- the Altera DE2 board as a hardware platform.
entity de2_adventure_demo_top is
    port (
        -- Port names as defined in the standard DE2 settings file.
        clock_50: in std_logic;
        vga_clk: out std_logic;
        vga_blank: out std_logic;
        vga_hs, vga_vs: out std_logic;
        vga_sync: out std_logic;
        vga_r: out std_logic_vector(9 downto 0);
        vga_g: out std_logic_vector(9 downto 0);
        vga_b: out std_logic_vector(9 downto 0);
        sw: in std_logic_vector(17 downto 0);
        key: in std_logic_vector(3 downto 0);
        ledg: out std_logic_vector(7 downto 0)
    );
end;

architecture rtl of de2_adventure_demo_top is
begin

    game: entity work.adventure_demo_top
        port map(
            clock          => clock_50,
            reset          => sw(17),
            debug_bits     => ledg,
            vga_clk        => vga_clk,
            vga_blank      => vga_blank,
            vga_hs         => vga_hs,
            vga_vs         => vga_vs,
            vga_sync       => vga_sync,
            vga_r          => vga_r,
            vga_g          => vga_g,
            vga_b          => vga_b,
            input_switches => sw(1 downto 0),
            input_buttons  => not key
        );

end;