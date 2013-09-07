library ieee;
use ieee.std_logic_1164.all;
use work.graphics_types_pkg.all;
use work.sprites_pkg.all;
use work.game_state_pkg.all;
use work.vga_pkg.all;

-- wanted features:
--   * sprite movement (done!)
--   * sprite animation
--   * sprite collision (done!)
--   * named sprites (done!)
--   * transparency (done!)
--   * background (done!)
--   * scroll
--   * enable/disable each sprite
--   * zoom factor (done!)
--   * user input (done!)
entity game_engine is
    generic (
        SPRITES_INITIAL_VALUES: sprites_array_type;
        SPRITES_COLLISION_QUERY: sprite_collision_query_type
    );
    port (
        -- system clock used for all user logic
        clock_50MHz: in std_logic;
        -- synchronous reset for all user logic
        reset: in std_logic;

        sprites_coordinates: in point_array_type(SPRITES_INITIAL_VALUES'range);
        sprite_collisions_results: out bool_vector;

        elapsed_time: out integer range 0 to 1000;
        time_base_50_ms: out std_logic;

        game_state: in game_state_type;
        background_bitmap: paletted_bitmap_type;

        vga_signals: out vga_signals_type
    );
end;

architecture rtl of game_engine is
begin

    system_timer: entity work.system_timing
        port map(
            clock_50MHz => clock_50MHz,
            reset => reset,
            time_base_50_ms_out => time_base_50_ms,
            elapsed_time_out => elapsed_time
        );

    vdp: entity work.video_engine
        generic map (
            SPRITES_INITIAL_VALUES => SPRITES_INITIAL_VALUES,
            SPRITES_COLLISION_QUERY => SPRITES_COLLISION_QUERY
        ) port map(
            clock_50MHz => clock_50MHz,
            reset => reset,
            vga_signals => vga_signals,
            sprites_coordinates => sprites_coordinates,
            sprite_collisions_results => sprite_collisions_results,
            background_bitmap => background_bitmap
         );
end;