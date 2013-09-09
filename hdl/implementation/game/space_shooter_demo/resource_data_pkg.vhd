use work.sprites_pkg.all;
use work.graphics_types_pkg.all;
use work.resource_handles_pkg.all;
use work.resource_handles_helper_pkg.all;

package resource_data_pkg is

    -- Here we define all the sprites used in the game
    constant GAME_SPRITES: sprite_init_array_type := (
        (PLAYER_SHIP_1_SPRITE, bitmap_handle => PLAYER_SHIP_1_BITMAP),
        (PLAYER_SHIP_2_SPRITE, bitmap_handle => PLAYER_SHIP_2_BITMAP),
        (PLAYER_SHOT_SPRITE,    bitmap_handle => PLAYER_SHOT_BITMAP),
        (ENEMY_SHIP_1_SPRITE, bitmap_handle => ENEMY_SHIP_1_BITMAP),
        (ENEMY_SHIP_2_SPRITE,    bitmap_handle => ENEMY_SHIP_2_BITMAP),
        (ALIEN_SHIP_1_SPRITE,    bitmap_handle => ALIEN_SHIP_BITMAP),
        (ALIEN_SHIP_2_SPRITE,    bitmap_handle => ALIEN_SHIP_BITMAP),
        (ALIEN_SHIP_3_SPRITE,    bitmap_handle => ALIEN_SHIP_BITMAP)
    );

    constant GAME_COLLISIONS: sprite_collision_init_array_type := (
        (PLAYER_1_ALIEN_1_COLLISION,
            sprite_1 => PLAYER_SHIP_1_SPRITE,
            sprite_2 => ALIEN_SHIP_1_SPRITE
        ),
        (PLAYER_2_ALIEN_1_COLLISION,
            sprite_1 => PLAYER_SHIP_2_SPRITE,
            sprite_2 => ALIEN_SHIP_1_SPRITE
        )
    );

    -- Here we define the actual bitmaps for each sprite in the game. This is
    -- the second step to add a new sprite in the game.
    constant GAME_BITMAPS: bitmap_init_array_type := (
        (   handle => PLAYER_SHIP_1_BITMAP,
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
        (   handle => PLAYER_SHIP_2_BITMAP,
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
        (   handle => PLAYER_SHOT_BITMAP,
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
        (   handle => ENEMY_SHIP_1_BITMAP,
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
        (   handle => ENEMY_SHIP_2_BITMAP,
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
        (   handle => ALIEN_SHIP_BITMAP,
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
