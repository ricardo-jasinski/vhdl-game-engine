package resource_handles_pkg is

    -- Enumerated type used to reference all bitmaps used in the game. To add
    -- a new bitmap, the first step is to add its bitmap handle here.
    type bitmap_handle_type is (
        SORCERER_BITMAP,   -- player sprite, a sorcerer
        AXE_BITMAP,        -- item, an axe
        ARCHER_BITMAP,     -- friendly NPC, an archer
        CHEST_BITMAP,      -- item_BITMAP, a treasure chest
        GHOST_BITMAP,      -- enemy NPC, a ghost
        SCORPION_BITMAP,   -- enemy NPC, a scorpion
        ORYX_11_BITMAP,    -- enemy NPC, Oryx (sprite 1/4)
        ORYX_12_BITMAP,    -- enemy NPC, Oryx (sprite 2/4)
        ORYX_21_BITMAP,    -- enemy NPC, Oryx (sprite 3/4)
        ORYX_22_BITMAP,    -- enemy NPC, Oryx (sprite 4/4)
        BAT_BITMAP,         -- enemy NPC, a bat
        REAPER_BITMAP,          -- enemy NPC, Grim Reaper
        FOREST_TILE_BITMAP,
        GAME_OVER_TILE_BITMAP,
        GAME_WON_TILE_BITMAP
    );

    -- Enumerated type for referencing all sprites used in the game. To add
    -- a new sprite, the first step is to add a sprite handle here.
    type sprite_handle_type is (
        SORCERER_SPRITE,   -- player sprite, a sorcerer
        AXE_SPRITE,        -- item, an axe
        ARCHER_SPRITE,     -- friendly NPC, an archer
        CHEST_SPRITE,      -- item, a treasure chest
        GHOST_SPRITE,      -- enemy NPC, a ghost
        SCORPION_SPRITE,   -- enemy NPC, a scorpion
        ORYX_11_SPRITE,    -- enemy NPC, Oryx (sprite 1/4)
        ORYX_12_SPRITE,    -- enemy NPC, Oryx (sprite 2/4)
        ORYX_21_SPRITE,    -- enemy NPC, Oryx (sprite 3/4)
        ORYX_22_SPRITE,    -- enemy NPC, Oryx (sprite 4/4)
        BAT_SPRITE,         -- enemy NPC, a bat
        REAPER_SPRITE
    );

end;
