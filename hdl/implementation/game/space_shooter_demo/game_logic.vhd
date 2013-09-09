library ieee;
use ieee.std_logic_1164.all;
use work.basic_types_pkg.all;
use work.input_types_pkg.all;
use work.graphics_types_pkg.all;
use work.resource_data_helper_pkg.all;
use work.resource_handles_pkg.all;
use work.resource_handles_helper_pkg.all;
use work.game_state_pkg.all;
use work.sprites_pkg.all;

-- Define all high-level game behavior.
entity game_logic is
    port (
        -- Synchronous reset, used by all user logic
        reset: in std_logic;
        -- System clock used for all user logic
        clock: in std_logic;
        -- Medium-resolution time base for game state updates and input reading
        time_base_50_ms: in std_logic;
        -- Game logic and game engine cooperate to calculate the NPC positions.
        -- The game logic tells where the NPCs *should be* (their intended positions)
        npc_target_positions: out point_array_type;
        -- Game logic and game engine cooperate to calculate the NPC positions.
        -- The game engine calculates where the NPCs *actually are*
        npc_positions: in point_array_type;
        -- Game logic and game engine cooperate to draw sprites, calculate their
        -- positions and checking for collisions. The game logic defines where
        -- the sprites *are drawn* on the screen.
        sprites_positions: out point_array_type;


        sprites_enabled: out bool_vector;

        -- Each element is 'true' while the two corresponding sprites are colliding.
        sprite_collisions: in bool_vector;
        input_buttons: in input_buttons_type;
        game_state: out game_state_type;
        -- debug pins to help debug game logic (e.g., connecting to board leds)
        debug_bits: out std_logic_vector(7 downto 0)
    );
end;

architecture rtl of game_logic is

    -- Each sprite must have a position, which may be constant or changeable.
    -- For static items (chest, axe) we may use a constant or a hardcoded value
    -- in the sprite positions array. For the player and NPC sprites, we declare
    -- signals and update them in the game logic to make them move.
    signal player_position: point_type;

    -- Signals to help us keep track of the game state.
    signal game_state_signal: game_state_type;
    signal game_over, game_won: boolean;

    -- Aliases to help us work with the NPC positions
    alias player_shot_position: point_type is npc_positions(0);
    alias enemy_ship_position: point_type is npc_positions(1);
    alias alien_ship_1_position: point_type is npc_positions(2);
    alias alien_ship_2_position: point_type is npc_positions(3);
    alias alien_ship_3_position: point_type is npc_positions(4);

    -- Aliases to help us monitor the game state. The player dies when an
    -- enemy is touched.
    alias enemy_ship_collision_1: boolean is sprite_collisions(0);
    alias enemy_ship_collision_2: boolean is sprite_collisions(1);

    signal sprites_enabled_signal: bool_vector(sprites_enabled'range);


begin

    ----------------------------------------------------------------------------
    -- Overall architecture description:
    --   1) Update player position
    --   2) Update NPC inputs (target positions)
    --   3) Provide a screen position for each sprite
    --   4) Update game state
    ----------------------------------------------------------------------------

    ----------------------------------------------------------------------------
    -- Section 1: Update player position based on input buttons
    update_player_position: process (clock, reset) begin
        if reset then
            player_position <= (64, 152);
        elsif rising_edge(clock) then
            if time_base_50_ms then
                if input_buttons.right then
                    player_position.x <= player_position.x + 1;
                elsif input_buttons.left then
                    player_position.x <= player_position.x - 1;
                end if;

                if input_buttons.down then
                    player_position.y <= player_position.y + 1;
                elsif input_buttons.up then
                    player_position.y <= player_position.y - 1;
                end if;
            end if;
        end if;
    end process;

    ----------------------------------------------------------------------------
    -- Section 2) Update NPC positions.

    -- We only need to assign the values correspoding to followers
--    npc_target_positions(3) <= player_position;
--    npc_target_positions(4) <= player_position + (-12,0);
    npc_target_positions(1) <= player_position + (24, -4);

    ----------------------------------------------------------------------------
    -- Section 3) Provide a screen position for each sprite. For static objects,
    -- we can use constants or hardcoded values. For moving objects and NPCs,
    -- we use signals.

    sprites_positions <= make_sprite_positions((
        (PLAYER_SHIP_1_SPRITE, player_position),
        (PLAYER_SHIP_2_SPRITE, player_position + point_type'(8,0)),
        (PLAYER_SHOT_SPRITE, player_shot_position),
        (ENEMY_SHIP_1_SPRITE, enemy_ship_position),
        (ENEMY_SHIP_2_SPRITE, enemy_ship_position + point_type'(8,0)),
        (ALIEN_SHIP_1_SPRITE, alien_ship_1_position ),
        (ALIEN_SHIP_2_SPRITE, alien_ship_2_position ),
        (ALIEN_SHIP_3_SPRITE, alien_ship_3_position )
    ));


    update_sprites_enabled: process (clock, reset) is
        variable enabled: bool_vector(sprites_enabled'range) := (others => true);
    begin
        if reset then
            enabled := (others => true);
        elsif rising_edge(clock) then
            if game_state_signal = GS_PLAY then
                if sprite_collisions( get_collision_id_from_handle( PLAYER_SHOT_ALIEN_1_COLLISION ) ) then
                    enabled( get_sprite_id_from_handle( ALIEN_SHIP_1_SPRITE ) ) := false;
                end if;
                if sprite_collisions( get_collision_id_from_handle( PLAYER_SHOT_ALIEN_2_COLLISION ) ) then
                    enabled( get_sprite_id_from_handle( ALIEN_SHIP_2_SPRITE ) ) := false;
                end if;
                if sprite_collisions( get_collision_id_from_handle( PLAYER_SHOT_ALIEN_3_COLLISION ) ) then
                    enabled( get_sprite_id_from_handle( ALIEN_SHIP_3_SPRITE ) ) := false;
                end if;
                if sprite_collisions( get_collision_id_from_handle( PLAYER_SHOT_ENEMY_1_COLLISION ) ) then
                    enabled( get_sprite_id_from_handle( ENEMY_SHIP_1_SPRITE ) ) := false;
                    enabled( get_sprite_id_from_handle( ENEMY_SHIP_2_SPRITE ) ) := false;
                end if;
            end if;
        end if;
        sprites_enabled <= enabled;
    end process;

--        PLAYER_SHIP_1_SPRITE,   -- player ship (sprite 1/2)
--        PLAYER_SHIP_2_SPRITE,   -- player ship (sprite 2/2)
--        PLAYER_SHOT_SPRITE,     -- shot fired from player ship
--        ENEMY_SHIP_1_SPRITE,    -- enemy ship (sprite 1/2)
--        ENEMY_SHIP_2_SPRITE,    -- enemy ship (sprite 2/2)
--        ALIEN_SHIP_1_SPRITE,    -- alien ship sprite
--        ALIEN_SHIP_2_SPRITE,    -- alien ship sprite
--        ALIEN_SHIP_3_SPRITE     -- alien ship sprite
--
--        PLAYER_SHOT_ENEMY_1_COLLISION,
--        PLAYER_1_ALIEN_1_COLLISION,
--        PLAYER_2_ALIEN_1_COLLISION,
--        PLAYER_1_ENEMY_1_COLLISION,
--        PLAYER_2_ENEMY_1_COLLISION

--    update_sprites_enabled: process (clock, reset) begin
--        if reset then
--            sprites_enabled_signal <= (others => true);
--        elsif rising_edge(clock) then
----            if sprite_collisions then
----                sprites_enabled_signal(1) <= false;
----                sprites_enabled_signal(4) <= false;
----            end if;
----            if enemy_ship_collision_2 then
----                sprites_enabled_signal(3) <= false;
----                sprites_enabled_signal(5) <= false;
----            end if;
--            if game_state_signal = GS_PLAY then
--                if enemy_ship_collision_1 then
--                    sprites_enabled_signal(1) <= false;
--                    sprites_enabled_signal(4) <= false;
--                end if;
--                if enemy_ship_collision_2 then
--                    sprites_enabled_signal(3) <= false;
--                    sprites_enabled_signal(5) <= false;
--                end if;
--            end if;
--        end if;
----        sprites_enabled <= sprites_enabled_signal;
--    end process;

--sprites_enabled <= sprites_enabled_signal;

    ----------------------------------------------------------------------------
    -- Section 4) Update game state. This game has a very simple state logic:
    -- RESET --> PLAY --> GAME_WON or GAME_OVER
    game_won <= false; -- treasure_found;
    game_over <= enemy_ship_collision_1 or enemy_ship_collision_2;
    process (clock, reset) begin
        if reset then
            game_state_signal <= GS_RESET;
        elsif rising_edge(clock) then
            case game_state_signal is
                when GS_RESET =>
                    if input_buttons /= (others => '0') then
                        game_state_signal <= GS_PLAY;
                    end if;
                when GS_PLAY =>
                    if game_won then
                        game_state_signal <= GS_GAME_WON;
                    elsif game_over then
                        game_state_signal <= GS_GAME_OVER;
                    end if;
                when others =>
                    null;
            end case;
        end if;
    end process;

    game_state <= game_state_signal;

--    debug_bits(7 downto 0) <= std_logic_vector_from_bool_vector(sprite_collisions);
    debug_bits(7 downto 0) <= std_logic_vector_from_bool_vector(sprites_enabled_signal)(0 to 7);

--    debug_bits(0) <= '1' when enemy_ship_collision_2 else '0';
--    debug_bits(1) <= '1' when enemy_ship_collision_1 else '0';
--    debug_bits(2) <= '1';-- when death_by_oryx else '0';
--    debug_bits(3) <= '1' when game_logic_state = GS_RESET else '0';
--    debug_bits(4) <= '1' when game_logic_state = GS_PLAY else '0';
--    debug_bits(5) <= '1' when game_logic_state = GS_GAME_OVER else '0';
--    debug_bits(6) <= '1' when game_logic_state = GS_GAME_WON else '0';
--    debug_bits(7) <= '0';
end;