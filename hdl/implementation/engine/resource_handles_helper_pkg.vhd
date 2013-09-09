use work.graphics_types_pkg.all;
use work.sprites_pkg.all;
use work.resource_handles_pkg.all;
use work.npc_pkg.all;

package resource_handles_helper_pkg is

    function get_sprite_id_from_handle(sprite_handle: sprite_handle_type) return natural;
    function get_bitmap_id_from_handle(handle: bitmap_handle_type) return natural;

    type sprite_handles_pair_type is array (0 to 1) of sprite_handle_type;
    type sprite_collision_query_initialization_type is array (natural range <>) of sprite_handles_pair_type;
    type sprite_position_pair is record
        id: sprite_handle_type;
        position: point_type;
    end record;
    type sprite_positions_init_array is array (natural range<>) of sprite_position_pair;

    -- Data type relating a bitmap handle with the bitmap data. With this
    -- structure, we can create an initializer function that takes in several
    -- bitmap handles and data, and creates the array of bitmaps used in the
    -- game. To customize a game, the user needs only to edit that array.
    type bitmap_init_type is record
        handle: bitmap_handle_type;
        bitmap: paletted_bitmap_type(0 to BITMAP_WIDTH-1, 0 to BITMAP_HEIGHT-1);
    end record;
    type bitmap_init_array_type is array (natural range<>) of bitmap_init_type;

    -- Data type relating a sprite handle with a sprite bitmap. With this
    -- structure, we can create an initializer that takes in a sprite ID
    -- and a bitmap, and creates the corresponding sprite.
    type sprite_init_type is record
        sprite_handle: sprite_handle_type;
        bitmap_handle: bitmap_handle_type;
    end record;
    type sprite_init_array_type is array (natural range<>) of sprite_init_type;

    type sprite_collision_init_type is record
        collision_handle: sprite_collision_handle_type;
        sprite_1: sprite_handle_type;
        sprite_2: sprite_handle_type;
    end record;
    type sprite_collision_init_array_type is array (natural range<>) of sprite_collision_init_type;

    type npc_init_type is record
        npc_handle: npc_handle_type;
        npc: npc_type;
    end record;
    type npc_init_array_type is array (natural range<>) of npc_init_type;

end;

package body resource_handles_helper_pkg is
    -- Get a sprite ID (an integer non-negative number) associated with the
    -- given sprite handle.
    function get_sprite_id_from_handle(sprite_handle: sprite_handle_type) return natural is begin
        return sprite_handle_type'pos(sprite_handle);
    end;

    function get_bitmap_id_from_handle(handle: bitmap_handle_type) return natural is begin
        return bitmap_handle_type'pos(handle);
    end;
end;
