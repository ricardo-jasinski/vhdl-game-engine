library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.graphics_types_pkg.all;
use work.sprites_pkg.all;
use work.game_state_pkg.all;
use work.colors_pkg.all;
use work.vga_pkg.all;

-- The video engine produces the signals to drive a VGA display from the game
-- data provided. Its main functions are:
--   1) To draw the game background on the screen
--   2) To draw the game sprites (performed in the sprites engine subblock)
--   3) To check for collisions between the game sprites (performed in the
--      sprites engine subblock)
entity video_engine is
    generic (
        SPRITES_INITIAL_VALUES: sprites_array_type;
        SPRITES_COLLISION_QUERY: sprite_collision_query_type
    );
    port (
        -- system clock used for all user logic
        clock_50MHz: in std_logic;
        -- synchronous reset for all user logic
        reset: in std_logic;
        -- bundle with all signals required to drive the VGA display
        vga_signals: out vga_signals_type;
        sprites_coordinates: in point_array_type(SPRITES_INITIAL_VALUES'range);
        sprite_collisions_results: out bool_vector;
        background_bitmap: paletted_bitmap_type
    );
end;

architecture rtl of video_engine is

    -- interface signals for sprites_engine
    signal sprite_pixel: palette_color_type;
    -- true when output pixel from sprite engine should be drawn on the screen
    signal sprite_pixel_is_valid: boolean;

    signal vga_hsync, vga_vsync: std_logic;
    signal video_on: std_logic;
    signal raster_position: point_type;

    -- 25MHz pixel clock generated at top level from DE2 50MHz clock
    signal pixel_clock: std_logic;

    -- Component declaration for the PLL used to generate the 25 MHz pixel
    -- clock from the board 50 MHz system clock
    component video_pll
        port(
            inclk0: in std_logic := '0';
            c0: out std_logic
        );
    end component;

begin

    vga_timing: entity work.vga_timing_generator
        port map(
            pixel_clock    => pixel_clock,
            horiz_sync_out => vga_hsync,
            vert_sync_out  => vga_vsync,
            video_on       => video_on,
            pixel_row      => raster_position.y,
            pixel_column   => raster_position.x
        );

    sprites_engine: entity work.sprites_engine
        generic map (
            SPRITES_INITIAL_VALUES => SPRITES_INITIAL_VALUES,
            SPRITES_COLLISION_QUERY => SPRITES_COLLISION_QUERY
        )
        port map(
            clock => pixel_clock,
            reset => reset,
            raster_position => raster_position / ZOOM_FACTOR,
            sprites_coordinates => sprites_coordinates,
            sprite_pixel => sprite_pixel,
            sprite_pixel_is_valid => sprite_pixel_is_valid,
            sprite_collisions_results => sprite_collisions_results
        );

    -- PLL below is used to generate the pixel clock frequency
    -- Uses DE2 50Mhz clock for PLL's input clock
    video_PLL_inst : video_PLL port map (
        inclk0 => clock_50MHz,
        c0 => pixel_clock
    );

    vga_signals.hsync <= vga_hsync;
    vga_signals.vsync <= vga_vsync;
    vga_signals.sync <= '1';
    vga_signals.blank <= '1'; -- looks like this one is active low...
    vga_signals.pixel_clk <= pixel_clock;

    process (all) is
        variable palette_pixel: palette_color_type;
        variable output_pixel: output_pixel_type;

        variable background_point: point_type;
    begin
        if not video_on then
            palette_pixel := PC_BLACK;
        elsif sprite_pixel_is_valid then
            palette_pixel := sprite_pixel;
        else
            background_point.x := (raster_position.x / ZOOM_FACTOR) mod background_bitmap'length(1);
            background_point.y := (raster_position.y / ZOOM_FACTOR) mod background_bitmap'length(2);
            palette_pixel := background_bitmap(background_point.y, background_point.x);
        end if;

        output_pixel := output_pixel_from_palette_color(palette_pixel);
        vga_signals.red <= output_pixel.r;
        vga_signals.green <= output_pixel.g;
        vga_signals.blue <= output_pixel.b;
    end process;
end;