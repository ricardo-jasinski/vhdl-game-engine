library ieee;
use ieee.std_logic_1164.all;
use work.basic_types_pkg.all;
use work.input_types_pkg.all;
use work.graphics_types_pkg.all;
use work.text_mode_pkg.all;
use work.resource_data_helper_pkg.all;
use work.resource_handles_pkg.all;
use work.resource_handles_helper_pkg.all;
use work.game_state_pkg.all;

entity game_logic is
    port (
        clock: in std_logic;
        reset: in std_logic;
        time_base_50_ms: in std_logic;
        npc_positions: in point_array_type;
        npc_target_positions: out point_array_type;

        -- Each element is 'true' while the two corresponding sprites are colliding.
        sprite_collisions: in bool_vector;
        sprites_positions: out point_array_type;
        
        -- Text strings displayed on the screen
        text_mode_strings: out text_mode_strings_type;
        
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
    constant CHEST_POSITION: point_type := (144, 80);
    constant AXE_POSITION: point_type := (8, 8);

    -- Signals to help us keep track of the game state.
    signal game_state_signal: game_state_type;
    signal game_over, game_won: boolean;

    -- Aliases to help us work with the NPC positions
    alias scorpion_position: point_type is npc_positions(get_id(NPC_SCORPION));
    alias ghost_position: point_type is npc_positions(get_id(NPC_GHOST));
    alias bat_position: point_type is npc_positions(get_id(NPC_BAT));
    alias oryx_position: point_type is npc_positions(get_id(NPC_ORYX));
    alias archer_position: point_type is npc_positions(get_id(NPC_ARCHER));
    alias reaper_position: point_type is npc_positions(get_id(NPC_REAPER));

    -- Aliases to help us monitor the game state. The player dies when an
    -- enemy is touched.
    alias death_by_ghost: boolean is sprite_collisions(get_id(COLLISION_PLAYER_GHOST));
    alias death_by_scorpion: boolean is sprite_collisions(get_id(COLLISION_PLAYER_SCORPION));
    alias death_by_oryx: boolean is sprite_collisions(get_id(COLLISION_PLAYER_ORYX));
    alias treasure_found: boolean is sprite_collisions(get_id(COLLISION_PLAYER_CHEST));

begin

    ----------------------------------------------------------------------------
    -- Overall architecture description:
    --   1) Update player position
    --   2) Update NPC inputs (target positions)
    --   3) Provide a screen position for each sprite
    --   4) Update text strings displayed on the screen
    --   5) Update game state
    ----------------------------------------------------------------------------

    ----------------------------------------------------------------------------
    -- Section 1: Update player position based on input buttons
    ----------------------------------------------------------------------------
    update_player_position: process (clock, reset) begin
        if reset then
            player_position <= (128, 128);
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
    ----------------------------------------------------------------------------

    -- We only need to assign the values correspoding to followers
    npc_target_positions( get_id(NPC_ORYX) ) <= player_position;
    npc_target_positions( get_id(NPC_ARCHER) ) <= player_position + (-12,0);
    npc_target_positions( get_id(NPC_REAPER) ) <= player_position + (12, -4);

    ----------------------------------------------------------------------------
    -- Section 3) Provide a screen position for each sprite. For static objects,
    -- we can use constants or hardcoded values. For moving objects and NPCs,
    -- we use signals.
    ----------------------------------------------------------------------------

    sprites_positions <= make_sprite_positions((
        (SPRITE_PLAYER,    player_position),
        (SPRITE_AXE,       AXE_POSITION),
        (SPRITE_ARCHER,    archer_position),
        (SPRITE_CHEST,     CHEST_POSITION),
        (SPRITE_GHOST,     ghost_position),
        (SPRITE_SCORPION,  scorpion_position),
        (SPRITE_ORYX_11,   oryx_position),
        (SPRITE_ORYX_12,   oryx_position + point_type'(8,0)),
        (SPRITE_ORYX_21,   oryx_position + point_type'(0,8)),
        (SPRITE_ORYX_22,   oryx_position + point_type'(8,8)),
        (SPRITE_BAT,       bat_position),
        (SPRITE_REAPER,    reaper_position)
    ));

    ----------------------------------------------------------------------------
    -- Section 4) Update text strings displayed on the screen.
    text_mode_strings <= (
        (   x => 30,
            y => 0,
            text => "Mighty Heroes   ",
            visible => true
        ),
        (   x => 1,
            y => 24,
            text => " HP:64  MP:23   ",
            visible => true
        )
    );

    ----------------------------------------------------------------------------
    -- Section 5) Update game state. This game has a very simple state logic:
    -- RESET --> PLAY --> GAME_WON or GAME_OVER
    ----------------------------------------------------------------------------
    game_won <= treasure_found;
    game_over <= death_by_ghost or death_by_scorpion or death_by_oryx;
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

    -- Connect debug signals
    debug_bits(0) <= '1' when death_by_scorpion else '0';
    debug_bits(1) <= '1' when death_by_ghost else '0';
    debug_bits(2) <= '1' when death_by_oryx else '0';
    debug_bits(3) <= '1' when game_state_signal = GS_RESET else '0';
    debug_bits(4) <= '1' when game_state_signal = GS_PLAY else '0';
    debug_bits(5) <= '1' when game_state_signal = GS_GAME_OVER else '0';
    debug_bits(6) <= '1' when game_state_signal = GS_GAME_WON else '0';
    debug_bits(7) <= '0';
end;