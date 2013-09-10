-- Define enumerated types for all game objects (bitmaps, sprites, collisions,
-- and NPCs). With these types, it is easy to reference any game object by name.
-- We can't simply create a constant for each object because we want to
package resource_handles_pkg is

    -- Enumerated type used for referencing all bitmaps used in the game.
    type bitmap_handle_type is (
        BITMAP_PLAYER_SHIP_1,   -- player ship (bitmap 1/2)
        BITMAP_PLAYER_SHIP_2,   -- player ship (bitmap 2/2)
        BITMAP_PLAYER_SHOT,     -- shot fired from player ship
        BITMAP_ENEMY_SHIP_1,    -- enemy ship (bitmap 1/2)
        BITMAP_ENEMY_SHIP_2,    -- enemy ship (bitmap 2/2)
        BITMAP_ALIEN_SHIP       -- alien ship bitmap
    );

    -- Enumerated type for referencing all the sprites used in the game.
    type sprite_handle_type is (
        SPRITE_PLAYER_SHIP_1,   -- player ship (sprite 1/2)
        SPRITE_PLAYER_SHIP_2,   -- player ship (sprite 2/2)
        SPRITE_PLAYER_SHOT,     -- shot fired from player ship
        SPRITE_ENEMY_SHIP_1,    -- enemy ship (sprite 1/2)
        SPRITE_ENEMY_SHIP_2,    -- enemy ship (sprite 2/2)
        SPRITE_ALIEN_SHIP_1,    -- alien ship sprite
        SPRITE_ALIEN_SHIP_2,    -- alien ship sprite
        SPRITE_ALIEN_SHIP_3     -- alien ship sprite
    );

    -- Enumerated type for referencing all sprite collisions that must be
    -- monitored in the game.
    type sprite_collision_handle_type is (
        COLLISION_PLAYER_SHOT_ALIEN_1,
        COLLISION_PLAYER_SHOT_ALIEN_2,
        COLLISION_PLAYER_SHOT_ALIEN_3,
        COLLISION_PLAYER_SHOT_ENEMY_1,
        COLLISION_PLAYER_2_ALIEN_1,
        COLLISION_PLAYER_2_ALIEN_2,
        COLLISION_PLAYER_2_ALIEN_3,
        COLLISION_PLAYER_2_ENEMY_1
    );

    -- Enumerated type for referencing all the NPCs (non-player characters) used
    -- in the game.
    type npc_handle_type is (
        NPC_PLAYER_SHOT,
        NPC_ENEMY_SHIP,
        NPC_ALIEN_SHIP_1,
        NPC_ALIEN_SHIP_2,
        NPC_ALIEN_SHIP_3
    );

end;
