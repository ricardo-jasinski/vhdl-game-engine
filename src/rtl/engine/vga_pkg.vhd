library ieee;
use ieee.std_logic_1164.all;


package vga_pkg is

    type vga_output_signals_type is record
        -- This is simply a copy of the input pixel clock used for VGA timing;
        -- it is added to this record because it must be handed over to the video DAC
        vga_clock_out: std_logic;
        blank: std_logic;
        hsync: std_logic;
        vsync: std_logic;
        sync: std_logic;
        red: std_logic_vector(9 downto 0);
        green: std_logic_vector(9 downto 0);
        blue: std_logic_vector(9 downto 0);
    end record;

end;