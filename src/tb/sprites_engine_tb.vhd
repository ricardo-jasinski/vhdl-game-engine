library ieee;
use ieee.std_logic_1164.all;
use work.graphics_types_pkg.all;
use work.colors_pkg.all;
use work.sprites_pkg.all;
use std.textio.all;
use std.env.all;
--use work.resource_data_pkg.all;

entity sprites_engine_tb is
end;

architecture testbench of sprites_engine_tb is

    signal clock, reset: std_logic := '0';
    signal raster_position: point_type;
    signal sprite_pixel: palette_color_type;
    signal sprite_pixel_is_valid: boolean;

    procedure wait_clock_cycles(cycles_count: integer) is
    begin
        for i in 1 to cycles_count loop
            wait until clock'event and clock = '1';
        end loop;
    end;

    constant TOP_LEFT_SQUARE_BITMAP: paletted_bitmap_type := (
        (1, 1, 1, 1, 1, 1, 1, 1),
        (1, 2, 2, 2, 0, 0, 0, 1),
        (1, 2, 2, 2, 0, 0, 0, 1),
        (1, 2, 2, 2, 0, 0, 0, 1),
        (1, 0, 0, 0, 0, 0, 0, 1),
        (1, 0, 0, 0, 0, 0, 0, 1),
        (1, 0, 0, 0, 0, 0, 0, 1),
        (1, 1, 1, 1, 1, 1, 1, 1)
    );

    constant BOTTOM_RIGHT_TRIANGLE_BITMAP: paletted_bitmap_type := (
        (1, 1, 1, 1, 1, 1, 1, 1),
        (1, 0, 0, 0, 0, 0, 0, 1),
        (1, 0, 0, 0, 0, 0, 2, 1),
        (1, 0, 0, 0, 0, 2, 2, 1),
        (1, 0, 0, 2, 2, 2, 2, 1),
        (1, 0, 2, 2, 2, 2, 2, 1),
        (1, 2, 2, 2, 2, 2, 2, 1),
        (1, 1, 1, 1, 1, 1, 1, 1)
    );

    constant SPRITES: sprites_array_type := (
        (x => 1, y => 1, bitmap => TOP_LEFT_SQUARE_BITMAP),
        (x => 1, y => 1, bitmap => BOTTOM_RIGHT_TRIANGLE_BITMAP)
    );

    constant SPRITES_COORDINATES: point_array_type(SPRITES'range) := (
        (0, 0),
        (16, 0)
    );

    constant SPRITES_COLLISION_QUERY: sprite_collision_query_type := ( (0,1), (0,1) );

    signal sprite_collisions_results: bool_vector(SPRITES_COLLISION_QUERY'range);


begin

    uut: entity work.sprites_engine
        generic map (
            SPRITES_INITIAL_VALUES => (
                (x => 1, y => 1, bitmap => TOP_LEFT_SQUARE_BITMAP),
                (x => 5, y => 5, bitmap => BOTTOM_RIGHT_TRIANGLE_BITMAP)
            ),
            SPRITES_COLLISION_QUERY => ( (0,1), (0,1) )
        )
        port map(
            clock => clock,
            reset => reset,
            raster_position => raster_position,
            sprites_coordinates => SPRITES_COORDINATES,
            sprite_pixel => sprite_pixel,
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