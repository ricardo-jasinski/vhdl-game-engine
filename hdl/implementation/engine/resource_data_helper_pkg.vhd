use work.resource_handles_pkg.all;
use work.graphics_types_pkg.all;
use work.sprites_pkg.all;
use work.npc_pkg.all;
use work.resource_data_pkg.all;
use work.resource_handles_helper_pkg.all;

package resource_data_helper_pkg is

    function sprite_initial_value_from_id(sprite_id: natural) return sprite_type;
    function get_bitmap_from_handle(handle: bitmap_handle_type) return paletted_bitmap_type;
    function make_sprites_initial_values(sprite_init_array: sprite_init_array_type) return sprites_array_type;
    function make_sprite_positions(pairs: sprite_positions_init_array) return point_array_type;
    function make_sprites_collision_query(collisions: sprite_collision_init_array_type) return sprite_collision_query_type;
    function make_npcs_initial_values(npcs_init_array: npc_init_array_type) return npc_array_type;

end;

package body resource_data_helper_pkg is

    function get_bitmap_from_handle(handle: bitmap_handle_type) return paletted_bitmap_type is
        variable bitmap_init_value: bitmap_init_type;
    begin
        bitmap_init_value := GAME_BITMAPS( get_bitmap_id_from_handle(handle) );
        return bitmap_init_value.bitmap;
    end;

    -- Merges all information provided by the user with the aditional information
    -- required to create a sprite
    function sprite_initial_value_from_id(sprite_id: natural) return sprite_type is
        variable bitmap: paletted_bitmap_type(0 to BITMAP_WIDTH-1, 0 to BITMAP_HEIGHT-1);
        variable bitmap_handle: bitmap_handle_type;
    begin
        bitmap_handle := GAME_SPRITES(sprite_id).bitmap_handle;
        bitmap := get_bitmap_from_handle(bitmap_handle);

        return (bitmap => bitmap, others => 0);
    end;

    -- We need to initialize the sprites engine with the game sprites. This
    -- initialization array helps us do it neatly. The helper function will
    -- fetch user-provided data from the GAME_SPRITES array and return an
    -- array of sprites ready to be assigned to sprite engine upon reset.
    function make_sprites_initial_values(sprite_init_array: sprite_init_array_type) return sprites_array_type is
        variable sprites: sprites_array_type(sprite_init_array'range);
    begin
        for i in sprites'range loop
            sprites(i) := sprite_initial_value_from_id(i);
        end loop;
        return sprites;
    end;

    function make_sprites_collision_query(collisions: sprite_collision_init_array_type) return sprite_collision_query_type is
        variable query: sprite_collision_query_type(collisions'range);
    begin
        for i in query'range loop
            query(i) := (
                get_sprite_id_from_handle( collisions(i).sprite_1 ),
                get_sprite_id_from_handle( collisions(i).sprite_2 )
            );
        end loop;
        return query;
    end;

    function make_npcs_initial_values(npcs_init_array: npc_init_array_type) return npc_array_type is
        variable npcs: npc_array_type(npcs_init_array'range);
    begin
        for i in npcs'range loop
            npcs(i) := npcs_init_array(i).npc;
        end loop;
        return npcs;
    end;

    function make_sprite_positions(pairs: sprite_positions_init_array) return point_array_type is
        variable positions: point_array_type(pairs'range);
    begin
        for i in pairs'range loop
            positions(get_sprite_id_from_handle(pairs(i).id)) := pairs(i).position;
        end loop;
        return positions;
    end;

end;
