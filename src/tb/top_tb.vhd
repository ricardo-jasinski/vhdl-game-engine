library ieee;
use ieee.std_logic_1164.all;
use work.graphics_types_pkg.all;
use work.colors_pkg.all;
use work.sprites_pkg.all;
use std.textio.all;
use std.env.all;
use work.resource_data_pkg.all;

entity top_tb is
end;

architecture testbench of top_tb is

    signal clock, reset: std_logic := '0';
    signal raster_position: point_type;
    signal sprite_pixel: palette_color_type;
    signal sprite_pixel_is_valid: boolean;
    signal sprite_collisions_results: bool_vector(0 downto 0);
    signal sprites_coordinates: point_array_type(GAME_SPRITES'range) := (
        --(elapsed_time, 0),
        (0, 0),
        (16, 0),
        (32, 0),
        (8, 16),
        (24, 16),
        (48, 24),
        (56, 24),
        (48, 32),
        (56, 32)
    );

    procedure wait_clock_cycles(cycles_count: integer) is
    begin
        for i in 1 to cycles_count loop
            --report "waiting clock pulse...";
            wait until clock'event and clock = '1';
        end loop;
    end;

begin

    uut: entity work.sprites_engine
        generic map (
            SPRITES_COLLISION_QUERY => ((0,1), (0,2))
        )
        port map(
            clock                 => clock,
            reset                 => reset,
            raster_position => raster_position,
            sprites_coordinates   => sprites_coordinates,
            sprite_pixel          => sprite_pixel,
            sprite_pixel_is_valid => sprite_pixel_is_valid,
            sprite_collisions_results => sprite_collisions_results
        );

    clock <= not clock after 10 ns;

    process
        variable row: line;
    begin
        report "starting...";

        reset <= '1';
        wait_clock_cycles(2);
        reset <= '0';

        report "looping...";
        for y in 0 to 15 loop
            for x in 0 to 15 loop
                raster_position <= (x, y);
                wait_clock_cycles(1);
                write(row, sprite_pixel, field => 3);
            end loop;
            writeline(output, row);
        end loop;

        finish;
    end process;

end;