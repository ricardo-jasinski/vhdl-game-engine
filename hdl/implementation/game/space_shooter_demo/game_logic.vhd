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
--
-- Game logic and game engine cooperate to calculate the NPC positions:
--   - The game logic tells whether each NPC is enabled
--   - The game logic tells where the NPCs *should be* (their intended positions)
--   - The game engine calculates where the NPCs *actually are*
--
-- Game logic and game engine cooperate to draw sprites, calculate their
-- positions and checking for collisions:
--   - The game logic defines where the sprites must be drawn on the screen
--   - The game logic defines which sprites must be drawn and monitored for collisions
--   - The game engine draws the sprites and tells if there's been any collision

entity game_logic is
    port (
        -- Synchronous reset, used by all user logic
        reset: in std_logic;
        -- System clock used for all user logic
        clock: in std_logic;
        -- Medium-resolution time base for game state updates and input reading
        time_base_50_ms: in std_logic;
        -- The game logic tells whether each NPC is enabled
        npc_enables: out bool_vector;
        -- The game logic tells where the NPCs *should be* (their intended positions)
        npc_target_positions: out point_array_type;
        -- The game engine calculates where the NPCs *actually are*
        npc_positions: in point_array_type;
        -- The game logic defines where the sprites *must be drawn* on the screen.
        sprites_positions: out point_array_type;
        -- True if sprite must be drawn on the screen and monitored for collisions
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

    constant PLAYER_ABSOLUTE_SPEED: integer := 2;

    -- Signals to help us keep track of the game state.
    signal game_state_signal: game_state_type;
    signal game_over, game_won: boolean;

    -- Aliases to help us work with the NPC positions
    alias player_shot_position: point_type is npc_positions(0);
    alias enemy_ship_position: point_type is npc_positions(1);
    alias alien_ship_1_position: point_type is npc_positions(2);
    alias alien_ship_2_position: point_type is npc_positions(3);
    alias alien_ship_3_position: point_type is npc_positions(4);

    signal player_shot_fired: boolean;

begin

    ----------------------------------------------------------------------------
    -- Overall architecture description:
    --   1) Update player position
    --   2) Generate NPC input data (enables and target positions)
    --   3) Generate sprite input data (enables and screen position)
    --   4) Update game state
    ----------------------------------------------------------------------------

    ----------------------------------------------------------------------------
    -- Section 1: Update player position based on input buttons
    ----------------------------------------------------------------------------
    update_player_position: process (clock, reset) begin
        if reset then
            player_position <= (64, 152);
        elsif rising_edge(clock) then
            if time_base_50_ms then
                if input_buttons.right then
                    player_position.x <= player_position.x + PLAYER_ABSOLUTE_SPEED;
                elsif input_buttons.left then
                    player_position.x <= player_position.x - PLAYER_ABSOLUTE_SPEED;
                end if;

                if input_buttons.down then
                    player_position.y <= player_position.y + PLAYER_ABSOLUTE_SPEED;
                elsif input_buttons.up then
                    player_position.y <= player_position.y - PLAYER_ABSOLUTE_SPEED;
                end if;
            end if;
        end if;
    end process;

    player_shot_state: process (clock, reset) begin
        if reset then
            player_shot_fired <= true;
        elsif rising_edge(clock) then
            if player_shot_fired then
                if not is_in_view(npc_positions(get_id(PLAYER_SHOT_NPC))) then
                    player_shot_fired <= false;
                end if;
            else
                if input_buttons.fire then
                    player_shot_fired <= true;
                end if;
            end if;
        end if;
    end process;


    ----------------------------------------------------------------------------
    -- Section 2) Update NPC NPC input data (enables and target positions)
    ----------------------------------------------------------------------------

    -- We only need to assign the values correspoding to followers
    npc_target_positions(1) <= player_position + (24, -4);

    npc_enables(npc_enables'range) <= (others => true);

    ----------------------------------------------------------------------------
    -- Section 3) Provide a screen position for each sprite. For static objects,
    -- we can use constants or hardcoded values. For moving objects and NPCs,
    -- we use signals.
    ----------------------------------------------------------------------------

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

        impure function collision(handle: sprite_collision_handle_type) return boolean is begin
            return sprite_collisions( get_collision_id_from_handle( handle ) );
        end;

        procedure disable_sprite(enabled: inout bool_vector; handle: in sprite_handle_type) is begin
            enabled( get_sprite_id_from_handle( handle ) ) := false;
        end procedure;

    begin
        if reset then
            enabled := (others => true);
            game_over <= false;
        elsif rising_edge(clock) then
            if game_state_signal = GS_PLAY then
                if collision(PLAYER_SHOT_ALIEN_1_COLLISION) then
                    disable_sprite(enabled, ALIEN_SHIP_1_SPRITE);
                end if;
                if collision(PLAYER_SHOT_ALIEN_2_COLLISION) then
                    disable_sprite(enabled, ALIEN_SHIP_2_SPRITE);
                end if;
                if collision(PLAYER_SHOT_ALIEN_3_COLLISION) then
                    disable_sprite(enabled, ALIEN_SHIP_3_SPRITE);
                end if;
                if collision(PLAYER_SHOT_ENEMY_1_COLLISION) then
                    disable_sprite(enabled, ENEMY_SHIP_1_SPRITE);
                    disable_sprite(enabled, ENEMY_SHIP_2_SPRITE);
                end if;
                if collision(PLAYER_2_ALIEN_1_COLLISION) or
                    collision(PLAYER_2_ALIEN_2_COLLISION) or
                    collision(PLAYER_2_ALIEN_3_COLLISION) or
                    collision(PLAYER_2_ENEMY_1_COLLISION)
                then
                    disable_sprite(enabled, PLAYER_SHIP_1_SPRITE);
                    disable_sprite(enabled, PLAYER_SHIP_2_SPRITE);
                    game_over <= true;
                end if;
            end if;
        end if;
        sprites_enabled <= enabled;
    end process;


    ----------------------------------------------------------------------------
    -- Section 4) Update game state. This game has a very simple state logic:
    -- RESET --> PLAY --> GAME_WON or GAME_OVER
    game_won <= false;
--    game_over <= enemy_ship_collision_1 or enemy_ship_collision_2;
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



    debug_bits(7 downto 0) <= std_logic_vector_from_bool_vector(sprite_collisions);
--    debug_bits(7 downto 0) <= std_logic_vector_from_bool_vector(sprites_enabled_signal)(0 to 7);

--    debug_bits(0) <= '1' when enemy_ship_collision_2 else '0';
--    debug_bits(1) <= '1' when enemy_ship_collision_1 else '0';
--    debug_bits(2) <= '1';-- when death_by_oryx else '0';
--    debug_bits(3) <= '1' when game_logic_state = GS_RESET else '0';
--    debug_bits(4) <= '1' when game_logic_state = GS_PLAY else '0';
--    debug_bits(5) <= '1' when game_logic_state = GS_GAME_OVER else '0';
--    debug_bits(6) <= '1' when game_logic_state = GS_GAME_WON else '0';
--    debug_bits(7) <= '0';
end;