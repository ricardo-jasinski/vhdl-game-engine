package resource_handles_pkg is

    -- Enumerated type used to reference all bitmaps used in the game. To add
    -- a new bitmap, the first step is to add its bitmap handle here.
    type bitmap_handle_type is (
        BITMAP_SORCERER,   -- player sprite, a sorcerer
        BITMAP_AXE,        -- item, an axe
        BITMAP_ARCHER,     -- friendly NPC, an archer
        BITMAP_CHEST,      -- item_BITMAP, a treasure chest
        BITMAP_GHOST,      -- enemy NPC, a ghost
        BITMAP_SCORPION,   -- enemy NPC, a scorpion
        BITMAP_ORYX_11,    -- enemy NPC, Oryx (sprite 1/4)
        BITMAP_ORYX_12,    -- enemy NPC, Oryx (sprite 2/4)
        BITMAP_ORYX_21,    -- enemy NPC, Oryx (sprite 3/4)
        BITMAP_ORYX_22,    -- enemy NPC, Oryx (sprite 4/4)
        BITMAP_BAT,         -- enemy NPC, a bat
        BITMAP_REAPER,          -- enemy NPC, Grim Reaper
        BITMAP_FOREST_TILE,
        BITMAP_GAME_OVER_TILE,
        BITMAP_GAME_WON_TILE
    );

    -- Enumerated type for referencing all sprites used in the game. To add
    -- a new sprite, the first step is to add a sprite handle here.
    type sprite_handle_type is (
        SPRITE_PLAYER,     -- player sprite, a sorcerer
        SPRITE_AXE,        -- item, an axe
        SPRITE_ARCHER,     -- friendly NPC, an archer
        SPRITE_CHEST,      -- item, a treasure chest
        SPRITE_GHOST,      -- enemy NPC, a ghost
        SPRITE_SCORPION,   -- enemy NPC, a scorpion
        SPRITE_ORYX_11,    -- enemy NPC, Oryx (sprite 1/4)
        SPRITE_ORYX_12,    -- enemy NPC, Oryx (sprite 2/4)
        SPRITE_ORYX_21,    -- enemy NPC, Oryx (sprite 3/4)
        SPRITE_ORYX_22,    -- enemy NPC, Oryx (sprite 4/4)
        SPRITE_BAT,        -- enemy NPC, a bat
        SPRITE_REAPER
    );

    -- Enumerated type for referencing all sprite collisions that must be
    -- monitored in the game.
    type sprite_collision_handle_type is (
        COLLISION_PLAYER_GHOST,
        COLLISION_PLAYER_SCORPION,
        COLLISION_PLAYER_ORYX,
        COLLISION_PLAYER_CHEST,
        COLLISION_PLAYER_REAPER
    );

    -- Enumerated type for referencing all the NPCs (non-player characters) used
    -- in the game.
    type npc_handle_type is (
        NPC_ARCHER,
        NPC_GHOST,
        NPC_SCORPION,
        NPC_ORYX,
        NPC_BAT,
        NPC_REAPER
    );
    
    -- Enumerated type for referencing all the text strings used in the game.
    type string_handle_type is (
        STRING_GAME_TITLE,
        STRING_PLAYER_STATS
    );
    
end;
