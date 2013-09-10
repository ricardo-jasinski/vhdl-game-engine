use work.sprites_pkg.all;
use work.graphics_types_pkg.all;
use work.resource_handles_pkg.all;
use work.resource_handles_helper_pkg.all;
use work.npc_pkg.all;

package resource_data_pkg is

    -- Here we define all the sprites used in the game
    constant GAME_SPRITES: sprite_init_array_type := (
        (SPRITE_PLAYER_SHIP_1,  bitmap_handle => BITMAP_PLAYER_SHIP_1),
        (SPRITE_PLAYER_SHIP_2,  bitmap_handle => BITMAP_PLAYER_SHIP_2),
        (SPRITE_PLAYER_SHOT,    bitmap_handle => BITMAP_PLAYER_SHOT),
        (SPRITE_ENEMY_SHIP_1,   bitmap_handle => BITMAP_ENEMY_SHIP_1),
        (SPRITE_ENEMY_SHIP_2,   bitmap_handle => BITMAP_ENEMY_SHIP_2),
        (SPRITE_ALIEN_SHIP_1,   bitmap_handle => BITMAP_ALIEN_SHIP),
        (SPRITE_ALIEN_SHIP_2,   bitmap_handle => BITMAP_ALIEN_SHIP),
        (SPRITE_ALIEN_SHIP_3,   bitmap_handle => BITMAP_ALIEN_SHIP)
    );

    constant GAME_COLLISIONS: sprite_collision_init_array_type := (
        ( COLLISION_PLAYER_SHOT_ALIEN_1,    SPRITE_PLAYER_SHOT,     SPRITE_ALIEN_SHIP_1 ),
        ( COLLISION_PLAYER_SHOT_ALIEN_2,    SPRITE_PLAYER_SHOT,     SPRITE_ALIEN_SHIP_2 ),
        ( COLLISION_PLAYER_SHOT_ALIEN_3,    SPRITE_PLAYER_SHOT,     SPRITE_ALIEN_SHIP_3 ),
        ( COLLISION_PLAYER_SHOT_ENEMY_1,    SPRITE_PLAYER_SHOT,     SPRITE_ENEMY_SHIP_1 ),
        ( COLLISION_PLAYER_2_ALIEN_1,       SPRITE_PLAYER_SHIP_2,   SPRITE_ALIEN_SHIP_1 ),
        ( COLLISION_PLAYER_2_ALIEN_2,       SPRITE_PLAYER_SHIP_2,   SPRITE_ALIEN_SHIP_2 ),
        ( COLLISION_PLAYER_2_ALIEN_2,       SPRITE_PLAYER_SHIP_2,   SPRITE_ALIEN_SHIP_3 ),
        ( COLLISION_PLAYER_2_ENEMY_1,       SPRITE_PLAYER_SHIP_2,   SPRITE_ENEMY_SHIP_2 )
    );

    -- Define the Non-Player Characters (NPCs) used in the game. NPCs have
    -- their positions updated automatically; the user logic is responsible for
    -- reading their positions and assigning them to the corresponding sprites
    constant GAME_NPCS: npc_init_array_type := (
        -- Player shot
        (   NPC_PLAYER_SHOT,
            make_npc_projectile(
                initial_position => (48, 152),
                initial_speed => (4, 0),
                allowed_region => (0, 0, 328, 240)
        )),
        -- Enemy ship 1
        (   NPC_ENEMY_SHIP,
            make_npc_bouncer(
                initial_position => (200, 60),
                allowed_region => (200, 60, 300, 180),
                initial_speed => (2, 2)
        )),
        -- Alien ship #1
        (   NPC_ALIEN_SHIP_1,
            make_npc_bouncer(
                initial_position => (400, 100),
                initial_speed => (1, 2)
        )),
        -- Alien ship #2
        (   NPC_ALIEN_SHIP_2,
            make_npc_bouncer(
                initial_position => (410, 120),
                initial_speed => (1, 2)
        )),
        -- Alien ship #3
        (   NPC_ALIEN_SHIP_3,
            make_npc_bouncer(
                initial_position => (420, 140),
                initial_speed => (1, 2)
        ))
    );


    -- Here we define the actual bitmaps for each sprite in the game. This is
    -- the second step to add a new sprite in the game.
    constant GAME_BITMAPS: bitmap_init_array_type := (
        (   handle => BITMAP_PLAYER_SHIP_1,
            bitmap => (
                ( 0, 20, 53, 53, 53, 53, 53, 17),
                ( 0, 55, 24, 20, 20, 20, 20, 53),
                ( 0,  0,  0,  0,  3,  3, 19, 49),
                ( 0, 18, 18, 18, 19, 19,  2, 54),
                (18, 20, 20, 20, 53, 53, 53, 20),
                ( 0, 18, 18, 18, 17, 19, 19, 19),
                (18, 20, 20, 20, 18,  0,  3,  3),
                ( 0, 18, 18, 18,  0,  0,  0,  0)
            )
        ),
        (   handle => BITMAP_PLAYER_SHIP_2,
            bitmap => (
                (33,  0,  0,  0,  0,  0,  0,  0),
                (53, 19,  0,  0,  0,  0,  0,  0),
                ( 5,  7,  7,  5,  5,  0,  0,  0),
                ( 7, 54, 10, 53, 10,  7,  0,  0),
                (35, 54, 10, 10, 10, 52,  7,  0),
                (18, 53, 48, 54, 54, 10, 10,  6),
                ( 3,  3, 18, 53, 53, 54, 54,  5),
                ( 0,  0,  0, 19, 20, 20, 20, 17)
            )
        ),
        (   handle => BITMAP_PLAYER_SHOT,
            bitmap => (
                ( 0,  0,  0,  0,  0,  0,  0,  0),
                ( 0,  0,  0,  0,  0,  0,  0,  0),
                ( 0,  0, 50, 43, 50,  0,  0,  0),
                ( 0, 51, 36, 36, 43, 50,  0,  0),
                ( 0, 51, 36, 36, 43, 50,  0,  0),
                ( 0,  0, 50, 43, 50,  0,  0,  0),
                ( 0,  0,  0,  0,  0,  0,  0,  0),
                ( 0,  0,  0,  0,  0,  0,  0,  0)
            )
        ),
        (   handle => BITMAP_ENEMY_SHIP_1,
            bitmap => (
                ( 0,  0,  0,  0,  0,  0,  0,  0),
                ( 0,  0,  0, 33, 17, 17, 17, 17),
                ( 0, 33, 17, 36, 53, 36,  8,  8),
                (33, 17,  8,  8,  8,  8,  8, 17),
                (17, 17, 17, 17, 17, 17, 17, 20),
                (17, 24, 24, 24, 24, 24, 24, 24),
                (33, 17, 17, 17, 17, 17, 24, 24),
                ( 0,  0,  0,  0,  0, 33, 17, 17)
            )
        ),
        (   handle => BITMAP_ENEMY_SHIP_2,
            bitmap => (
                ( 0,  0,  0,  0,  0,  0,  0,  0),
                (17, 17,  0,  0,  0,  0,  0,  0),
                ( 8, 17, 17,  0, 17, 17,  0,  0),
                (17, 20, 20, 33, 20, 17, 24,  0),
                (20, 19, 19, 19, 19, 17, 40, 26),
                (24, 24, 24, 17, 19, 17, 24,  0),
                (24, 24, 17, 33, 17, 17,  0,  0),
                (17, 17, 17,  0,  0,  0,  0,  0)
            )
        ),
        (   handle => BITMAP_ALIEN_SHIP,
            bitmap => (
                ( 0,  0, 22, 23, 23, 23, 22,  0),
                (22, 23, 23,  0, 17, 19, 23, 22),
                ( 0,  0, 16,  3, 19, 10, 19, 23),
                ( 0, 54, 10, 20, 10, 36, 10,  0),
                ( 0,  0, 16,  3, 19, 10, 19, 23),
                (22, 23, 23,  0, 17, 19, 23, 22),
                ( 0,  0, 22, 23, 23, 23, 22,  0),
                ( 0,  0,  0,  0,  0,  0,  0,  0)
            )
        )
    );

end;
