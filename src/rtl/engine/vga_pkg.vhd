library ieee;
use ieee.std_logic_1164.all;


package vga_pkg is

    type vga_signals_type is record
        pixel_clk: std_logic;
        blank: std_logic;
        hsync: std_logic;
        vsync: std_logic;
        sync: std_logic;
        red: std_logic_vector(9 downto 0);
        green: std_logic_vector(9 downto 0);
        blue: std_logic_vector(9 downto 0);
    end record;

end;