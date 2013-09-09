library ieee;
use ieee.std_logic_1164.all;
use work.graphics_types_pkg.all;
use work.sprites_pkg.all;
use work.colors_pkg.all;
use work.basic_types_pkg.all;

-- It is worth noting that the sprites engine should not (and does not) access
-- any game-specific constants or code. Therefore, it can be readily reused
-- accross games without any modification. The only game-dependent values are
-- given as generics when the module is instantiated.
entity sprites_engine is
    generic (
        SPRITES_INITIAL_VALUES: sprites_array_type;
        SPRITES_COLLISION_QUERY: sprite_collision_query_type
    );
    port (
        clock: in std_logic;
        reset: in std_logic;
        raster_position: point_type;
        sprites_coordinates: in point_array_type(SPRITES_INITIAL_VALUES'range);
        sprites_enabled: in bool_vector(SPRITES_INITIAL_VALUES'range);
        sprite_pixel: out palette_color_type;
        sprite_pixel_is_valid: out boolean;
        sprite_collisions_results: out bool_vector
    );
end;

architecture rtl of sprites_engine is
    signal sprites: sprites_array_type(SPRITES_INITIAL_VALUES'range);

begin

    sprite_collisions_results <= get_sprites_collisions(sprites, SPRITES_COLLISION_QUERY);

    update_sprites: process (clock, reset) begin
        for i in sprites'range loop
            if reset then
                sprites(i) <= SPRITES_INITIAL_VALUES(i);
            elsif rising_edge(clock) then
                sprites(i) <= update_sprite(
                    sprites(i),
                    raster_position,
                    sprites_coordinates(i),
                    sprites_enabled(i)
                );
            end if;
        end loop;
    end process;

    generate_output_pixel: process (clock, reset) is
        variable pixel_is_valid: boolean := false;
        variable pixel_color: palette_color_type;
    begin
        if reset then
            sprite_pixel <= PC_TRANSPARENT;
            sprite_pixel_is_valid <= false;
        elsif rising_edge(clock) then
            sprite_pixel <= PC_TRANSPARENT;
            pixel_is_valid := false;
            for i in sprites'range loop
--                if sprite_contains_coordinate(sprites(i), raster_position) then
                -- only enabled sprites are drawn
                if sprites(i).enabled and sprite_contains_coordinate(sprites(i), raster_position) then
                    pixel_color := get_sprite_pixel(sprites(i), raster_position);
                    if pixel_color /= PC_TRANSPARENT then
                        sprite_pixel <= get_sprite_pixel(sprites(i), raster_position);
                        pixel_is_valid := true;
                    end if;
                end if;
            end loop;
            sprite_pixel_is_valid <= pixel_is_valid;
        end if;
    end process;

end;
