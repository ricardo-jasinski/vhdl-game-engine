use work.colors_pkg.all;
use work.graphics_types_pkg.all;
use work.basic_types_pkg.all;

-- Data types and functions for working with sprites in a high level of
-- abstraction.
package sprites_pkg is

    -- VHDL won't allow sprites of different sizes in the same array, so we
    -- simplify everything by making all sprites and bitmaps have the same size
    constant BITMAP_WIDTH: integer := 8;
    constant BITMAP_HEIGHT: integer := 8;
    constant SPRITE_WIDTH: integer := BITMAP_WIDTH;
    constant SPRITE_HEIGHT: integer := BITMAP_HEIGHT;

    type sprite_type is record
        x: integer;
        y: integer;
        enabled: boolean;
        bitmap: paletted_bitmap_type(0 to SPRITE_WIDTH-1, 0 to SPRITE_HEIGHT-1);
    end record;

    type sprites_array_type is array (natural range <>) of sprite_type;

    function sprite_contains_coordinate(sprite: sprite_type; coordinate: point_type) return boolean;
    function update_sprite(sprite: sprite_type; raster_position: point_type; position: point_type; enabled: boolean) return sprite_type;
    function get_sprite_pixel(sprite: sprite_type; raster_position: point_type) return palette_color_type;

    -- A pair of sprites; used to define elements in the collision query array.
    type sprite_id_pair is array (0 to 1) of integer;
    -- We need to tell the sprites engine which sprites we want to monitor for
    -- collisions. The query array helps us do it neatly.
    type sprite_collision_query_type is array (natural range <>) of sprite_id_pair;

    function check_collision(sprite_1, sprite_2: sprite_type) return boolean;
    function get_sprites_collisions(sprites: sprites_array_type; collisions_query: sprite_collision_query_type) return bool_vector;

end;

package body sprites_pkg is

    function get_sprites_collisions(sprites: sprites_array_type; collisions_query: sprite_collision_query_type) return bool_vector is
        variable collisions: bool_vector(collisions_query'range);
        variable sprite_1, sprite_2: sprite_type;
    begin
        for i in collisions_query'range loop
            sprite_1 := sprites( collisions_query(i)(0) );
            sprite_2 := sprites( collisions_query(i)(1) );
            collisions(i) := check_collision(sprite_1, sprite_2);
        end loop;
        return collisions;
    end;

    function sprite_contains_coordinate(sprite: sprite_type; coordinate: point_type) return boolean is
    begin
        return
            (coordinate.x >= sprite.x) and
            (coordinate.x < (sprite.x + SPRITE_WIDTH)) and
            (coordinate.y >= sprite.y) and
            (coordinate.y < (sprite.y + SPRITE_HEIGHT));
    end;

    function update_sprite(sprite: sprite_type; raster_position: point_type; position: point_type; enabled: boolean) return sprite_type is
        variable updated_sprite: sprite_type;
    begin
        updated_sprite := sprite;

        updated_sprite.enabled := enabled;

        if (raster_position.x = GAME_VIEWPORT_WIDTH-1 and
            raster_position.y = GAME_VIEWPORT_HEIGHT-1)
        then
            updated_sprite.x := position.x;
            updated_sprite.y := position.y;
        end if;

        return updated_sprite;
    end;

    function get_sprite_pixel(sprite: sprite_type; raster_position: point_type) return palette_color_type is
        variable offset: point_type;
    begin
        offset.x := raster_position.x - sprite.x;
        offset.y := raster_position.y - sprite.y;
        return sprite.bitmap(offset.y, offset.x);
    end;

    function check_collision(sprite_1, sprite_2: sprite_type) return boolean is
        variable positions_intersect: boolean;
    begin
        positions_intersect := not (
            (sprite_1.y + SPRITE_HEIGHT < sprite_2.y) or
            (sprite_1.y > sprite_2.y + SPRITE_HEIGHT) or
            (sprite_1.x > sprite_2.x + SPRITE_WIDTH) or
            (sprite_1.x + SPRITE_WIDTH < sprite_2.x)
        );
        return sprite_1.enabled and sprite_2.enabled and positions_intersect;
    end;

end;


