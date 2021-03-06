use work.sprites_pkg.all;
use work.graphics_types_pkg.all;
use work.resource_handles_pkg.all;
use work.resource_handles_helper_pkg.all;
use work.npc_pkg.all;

package resource_data_pkg is

    -- Here we define all the sprites used in the game
    constant GAME_SPRITES: sprite_init_array_type := (
        (SPRITE_PLAYER, bitmap_handle => BITMAP_SORCERER),
        (SPRITE_AXE,      bitmap_handle => BITMAP_AXE     ),
        (SPRITE_ARCHER,   bitmap_handle => BITMAP_ARCHER  ),
        (SPRITE_CHEST,    bitmap_handle => BITMAP_CHEST   ),
        (SPRITE_GHOST,    bitmap_handle => BITMAP_GHOST   ),
        (SPRITE_SCORPION, bitmap_handle => BITMAP_SCORPION),
        (SPRITE_ORYX_11,  bitmap_handle => BITMAP_ORYX_11 ),
        (SPRITE_ORYX_12,  bitmap_handle => BITMAP_ORYX_12 ),
        (SPRITE_ORYX_21,  bitmap_handle => BITMAP_ORYX_21 ),
        (SPRITE_ORYX_22,  bitmap_handle => BITMAP_ORYX_22 ),
        (SPRITE_BAT,      bitmap_handle => BITMAP_BAT     ),
        (SPRITE_REAPER,   bitmap_handle => BITMAP_REAPER  )
    );

    constant GAME_COLLISIONS: sprite_collision_init_array_type := (
        ( COLLISION_PLAYER_GHOST,           SPRITE_PLAYER,     SPRITE_GHOST    ),
        ( COLLISION_PLAYER_SCORPION,        SPRITE_PLAYER,     SPRITE_SCORPION ),
        ( COLLISION_PLAYER_ORYX,            SPRITE_PLAYER,     SPRITE_ORYX_11  ),
        ( COLLISION_PLAYER_CHEST,           SPRITE_PLAYER,     SPRITE_CHEST    ),
        ( COLLISION_PLAYER_REAPER,          SPRITE_PLAYER,     SPRITE_REAPER   )
    );

    -- Define the Non-Player Characters (NPCs) used in the game. NPCs have
    -- their positions updated automatically; the user logic is responsible for
    -- reading their positions and assigning them to the corresponding sprites
    constant GAME_NPCS: npc_init_array_type := (
        -- Ghost, moves around the chest in a diamond-shaped path
        (   NPC_GHOST,
            make_npc_bouncer(
                initial_position => (144, 64),
                allowed_region => (128, 64, 160, 96),
                initial_speed => (1, 1)
        )),
        -- Scorpion, moves horizontally accross the screen
        (   NPC_SCORPION,
            make_npc_bouncer(
                initial_position => (0, 128),
                initial_speed => (1, 0)
        )),
        -- Bat, moves horizontally
        (   NPC_BAT,
            make_npc_bouncer(
                initial_position => (160, 160),
                allowed_region => (0, 160, 300, 164),
                initial_speed => (1, 1)
        )),
        -- Oryx, tries to kill the player with its sword
        (   NPC_ORYX,
            make_npc_follower(
                initial_position => (300, 220),
                slowdown_factor => 2
        )),
        -- Archer, tries to hide behind the player
        (   NPC_ARCHER,
            make_npc_follower(
                initial_position => (0, 0),
                slowdown_factor => 1
        )),
        -- Reaper, stays near the player
        (   NPC_REAPER,
            make_npc_follower(
                initial_position => (300, 64),
                slowdown_factor => 4
        ))
    );


    -- Here we define the actual bitmaps for each sprite in the game. This is
    -- the second step to add a new sprite in the game.
    constant GAME_BITMAPS: bitmap_init_array_type := (
        (
            handle => BITMAP_SORCERER,
            bitmap => (
                (23, 23, 24, 24, 23,  0, 20, 20),
                ( 0, 23, 24, 24, 23, 23,  0, 20),
                (23, 23, 57, 34, 57, 34,  0, 61),
                ( 0, 23, 23, 57, 57, 57,  0, 20),
                (23, 23, 24, 24, 24, 23, 23, 57),
                (57, 20, 20, 20, 19, 20,  0, 20),
                ( 0, 23, 23, 23, 23, 23,  0, 20),
                (23, 19, 23, 23, 23, 19,  0, 19)
            )
        ),
        (
            handle => BITMAP_AXE,
            bitmap => (
                ( 0,  0,  0,  0,  0,  0,  0,  0),
                ( 0,  0,  0, 18,  0,  0, 37,  0),
                ( 0,  0,  0,  0, 18, 18,  0,  0),
                ( 0,  0,  0,  0, 18, 18, 18, 19),
                ( 0,  0,  0, 37,  0, 18, 19, 19),
                ( 0,  0, 37,  0,  0, 19, 19,  0),
                ( 0, 37,  0,  0,  0,  0,  0,  0),
                (37,  0,  0,  0,  0,  0,  0,  0)
            )
        ),
        (
            handle => BITMAP_ARCHER,
            bitmap => (
                (29, 29, 30, 30, 29,  0, 25,  0),
                ( 0, 29, 30, 30, 30, 29,  0, 25),
                ( 0, 29, 57, 34, 57, 34,  0, 25),
                ( 0,  3, 57, 57, 57, 57,  0, 25),
                (44, 29, 30, 30, 30, 29, 29, 57),
                (57, 37, 38, 38, 19, 37,  0, 41),
                ( 0, 29, 29, 29, 29, 29,  0, 25),
                ( 0, 37,  0,  0,  0, 37, 38,  0)
            )
        ),
        (
            handle => BITMAP_CHEST,
            bitmap => (
                ( 0,  0,  0,  0,  0,  0,  0,  0),
                ( 0, 38, 38, 38, 38, 38, 38,  0),
                (38,  2,  2,  2,  2, 38,  2, 38),
                (38, 38, 38, 38, 38, 38, 38, 38),
                (38,  1, 46,  1, 22, 38, 22, 38),
                (38, 21, 21,  1, 22, 37, 22, 38),
                (37, 37, 37, 37, 37, 37, 37, 37),
                ( 0,  0,  0,  0,  0,  0,  0,  0)
            )
        ),
        (
            handle => BITMAP_GHOST,
            bitmap => (
                ( 0,  0,  0, 53, 53, 53, 20,  0),
                ( 0,  0, 53, 53, 24, 53, 24,  0),
                ( 0,  0, 53, 53, 53, 53, 53,  0),
                ( 0, 53, 53, 53, 53, 34, 53, 53),
                ( 0,  0, 53, 53, 53, 34, 20,  0),
                (53,  0, 53, 53, 53, 53, 20,  0),
                ( 0, 53, 53, 53, 53, 53, 20,  0),
                ( 0,  0, 53, 53, 53, 20,  0,  0)
            )
        ),
        (
            handle => BITMAP_SCORPION,
            bitmap => (
                ( 0, 18, 18, 18,  0,  0,  0,  0),
                (18,  0,  0, 17, 17,  0,  0,  0),
                (18,  0,  0,  0, 17,  0,  0,  0),
                (18,  0,  0,  0,  0,  0,  0,  0),
                (18, 18,  0,  0,  0,  0,  0,  0),
                (17, 18, 18, 18, 18, 24, 18, 24),
                ( 0, 17, 18, 18, 18, 18, 18, 18),
                (17,  0, 17,  0, 17,  0, 17,  0)
            )
        ),
        (
            handle => BITMAP_ORYX_11,
            bitmap => (
                ( 0, 20,  0,  0, 20,  0,  0,  0),
                (20, 20,  0, 20,  0,  0, 34, 34),
                (20, 20,  0, 20,  0, 34, 17, 17),
                (20, 20,  0,  0, 20, 34, 17, 17),
                (20, 20,  0,  0,  0, 33, 24, 34),
                (20, 20,  0,  0, 34, 33, 33, 34),
                (34, 34,  0, 34, 33, 34, 33, 34),
                (17, 34, 17, 34, 17, 33, 34, 33)
            )
        ),
        (
            handle => BITMAP_ORYX_12,
            bitmap => (
                ( 0,  0,  0, 20,  0,  0,  0,  0),
                (34, 34,  0,  0, 20,  0,  0,  0),
                (33, 33, 34,  0, 20,  0,  0,  0),
                (34, 33, 34, 20,  0,  0,  0,  0),
                (34, 24, 33,  0,  0,  0,  0,  0),
                (34, 33, 33, 34,  0,  0,  0,  0),
                (34, 33, 34, 34, 34, 34, 34, 34),
                (33, 34, 17, 34, 18, 18, 18, 34)
            )
        ),
        (
            handle => BITMAP_ORYX_21,
            bitmap => (
                (17, 34, 17, 34, 33, 17, 17, 34),
                (34, 34,  0,  0, 34, 34, 34, 33),
                (34,  0,  0,  0,  0, 34, 33, 33),
                ( 0,  0,  0,  0, 34, 17, 34, 34),
                ( 0,  0,  0, 34, 17, 34, 34, 17),
                ( 0,  0,  0, 34, 34, 34,  0, 33),
                ( 0,  0,  0, 34, 34, 34,  0,  0),
                ( 0,  0, 34, 34, 34, 34,  0,  0)
            )
        ),
        (
            handle => BITMAP_ORYX_22,
            bitmap => (
                (34, 17, 17, 34, 18, 18, 20, 34),
                (33, 34, 34, 34, 18, 20, 20, 34),
                (33, 33, 34, 34, 18, 18, 20, 34),
                (34, 34, 17, 34, 18, 18, 20, 34),
                (17, 34, 34, 17, 34, 18, 18, 34),
                (33,  0, 34, 34, 34, 34, 34, 34),
                ( 0,  0, 34, 34, 34,  0,  0,  0),
                ( 0,  0, 34, 34, 34, 34,  0,  0)
            )
        ),
        (
            handle => BITMAP_BAT,
            bitmap => (
                ( 0,  0,  0, 17,  0, 17,  0,  0),
                ( 0, 17,  0, 17, 17, 17,  0, 17),
                (17, 17,  0, 46, 17, 46,  0, 17),
                (17, 17, 17, 17, 17, 17, 17, 17),
                (17, 17, 17, 17, 17, 17, 17, 17),
                (17, 17,  0, 17, 17,  0, 17, 17),
                (17,  0,  0, 17,  0,  0,  0, 17),
                ( 0,  0,  0,  0,  0,  0,  0,  0)
            )
        ),
       (    handle => BITMAP_REAPER,
            bitmap => (
                (34, 34, 34, 19, 19, 19, 19, 19),
                ( 0, 34, 19, 33, 33, 33,  0, 38),
                ( 0, 34, 34, 23, 53, 23,  0, 38),
                ( 0, 34, 34, 53, 53, 53,  0, 38),
                (34, 34, 34, 34, 34, 34, 34, 53),
                (53, 34, 34, 34, 34, 34,  0, 38),
                ( 0, 34, 34, 34, 34, 34,  0, 38),
                (34, 34, 34, 34, 34, 34, 34, 38)
        )),
        (   handle => BITMAP_FOREST_TILE,
            bitmap => (
                (11, 11, 11, 11, 12,  1, 11, 11),
                (12,  1, 11, 11, 11, 12, 11, 11),
                (11, 12, 11, 11, 11, 11, 11, 11),
                (11, 11, 11, 12, 11, 11, 11, 11),
                (11, 11, 11, 11, 12, 11, 11, 11),
                (11, 11, 11, 11, 11, 11,  1, 11),
                (11, 12, 11, 11, 11, 11, 12, 11),
                (11, 11, 12, 11, 11, 11, 11, 11)
        )),
        (
            handle => BITMAP_GAME_OVER_TILE,
            bitmap => (
                (22, 46, 22, 46, 22, 46, 22, 22),
                (22, 22, 46, 26, 26, 26, 46, 22),
                (22, 46, 26, 53, 53, 53, 25, 22),
                (22, 26, 53, 53, 53, 53, 53, 42),
                (22, 42, 53, 53, 34, 53, 34, 23),
                (22, 22, 23, 36, 53, 34, 53, 23),
                (22, 22, 22, 23, 36, 36, 36, 23),
                (22, 22, 22, 22, 24, 23, 23, 22)
            )
        ),
        (
            handle => BITMAP_GAME_WON_TILE,
            bitmap => (
                ( 7,  7, 38, 38, 38, 38, 38,  7),
                ( 7,  7, 38, 46, 46,  1, 38, 17),
                ( 7,  7, 46, 26, 46, 46, 38, 17),
                ( 7, 46, 26, 46, 26, 46, 38,  7),
                (38, 38, 38, 38, 38, 38, 38,  7),
                (38,  1, 46,  2, 38,  2, 38,  7),
                (38,  2,  1,  2, 38,  2, 38,  7),
                (38, 38, 38, 38, 38, 38,  7,  7)
            )
        )
    );

end;
