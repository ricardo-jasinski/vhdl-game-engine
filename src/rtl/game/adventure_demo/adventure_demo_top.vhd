library ieee;
use ieee.std_logic_1164.all;
use work.graphics_types_pkg.all;
use work.sprites_pkg.all;
use work.game_state_pkg.all;
use work.resource_handles_pkg.all;
use work.resource_data_pkg.all;
use work.resource_data_helper_pkg.all;
use work.npc_pkg.all;
use work.vga_pkg.all;

-- Top-level entity for the "Adventure" game demo using VAGE. On top of this
-- entity, there should be only a very simple wrapper intantiating this entity
-- and connecting its ports to the board used. It should be fairly easy to use
-- this entity in other hardware platforms, without any modifications.
entity adventure_demo_top is
    port (
        -- synchronous reset, used by all user logic
        reset: in std_logic;
        -- system clock used for all user logic
        clock_50_Mhz: in std_logic;
        -- VGA clock used by the video renderer; should be approximately
        -- 25.715 MHz (25 MHz is acceptable)
        vga_clock_in: in std_logic;
        -- Same as VGA input clock, must be passed along to the video DAC chip
        vga_clock_out: out std_logic;
        -- VGA blank, low during horizontal or vertical retrace (pixels should be blank)
        vga_blank: out std_logic;
        -- VGA Hsync, low during horizontal synchronism pulse
        vga_n_hsync: out std_logic;
        -- VGA Vsync, low during vertical synchronism pulse
        vga_n_vsync: out std_logic;
        -- Composite sync for the ADV7123; if this feature is not used, should
        -- be tied to '0'
        vga_n_sync: out std_logic;
        vga_red: out std_logic_vector(9 downto 0);
        vga_green: out std_logic_vector(9 downto 0);
        vga_blue: out std_logic_vector(9 downto 0);

        input_switches: in std_logic_vector(1 downto 0);
        input_buttons: in std_logic_vector(3 downto 0);

        -- debug pins to help debug game logic (e.g., connecting to board leds)
        debug_bits: out std_logic_vector(7 downto 0)
    );
end;

architecture rtl of adventure_demo_top is

    -- Medium-resolution time base (used for game state updates and
    -- reading the inputs switches)
    signal time_base_50_ms: std_logic;
    -- Maximum value for the game time counter
    constant GAME_TIMER_50_MS_MAX: integer := 1000;
    -- Monotonic game time counter, updated every 50 ms. Can be used by
    -- the game logic (eg., to animate or move sprites)
    signal elapsed_time: integer range 0 to GAME_TIMER_50_MS_MAX;

    signal vga_output_signals: vga_output_signals_type;

    -- Each sprite must have a position, which may be constant or changeable.
    -- For static items (chest, axe) we may use a constant or a hardcoded value
    -- in the sprite positions array. For the player and NPC sprites, we declare
    -- signals and update them in the game logic to make them move.
    signal player_position: point_type;
    constant CHEST_POSITION: point_type := (144, 80);
    constant AXE_POSITION: point_type := (8, 8);

    -- Array containing the position of each sprite on the screen;
    -- required by the sprites engine.
    signal sprites_coordinates: point_array_type(GAME_SPRITES'range);

    -- We need to tell the sprites engine which sprites we want to monitor for
    -- collisions. The query array helps us do it neatly.
    constant SPRITES_COLLISION_QUERY: sprite_collision_query_type := make_sprites_collision_query((
        (SORCERER_SPRITE, GHOST_SPRITE),
        (SORCERER_SPRITE, SCORPION_SPRITE),
        (SORCERER_SPRITE, ORYX_11_SPRITE),
        (SORCERER_SPRITE, CHEST_SPRITE)
    ));

    -- Each element is 'true' while the two corresponding sprites are colliding.
    signal sprite_collisions_results: bool_vector(SPRITES_COLLISION_QUERY'range);

    -- Aliases to help us monitor the game state. The player dies when an
    -- enemy is touched.
    alias death_by_ghost: boolean is sprite_collisions_results(0);
    alias death_by_scorpion: boolean is sprite_collisions_results(1);
    alias death_by_oryx: boolean is sprite_collisions_results(2);
    alias treasure_found: boolean is sprite_collisions_results(3);

    -- Signals to help us keep track of the game state.
    signal game_state: game_state_type;
    signal game_over, game_won: boolean;

    -- We need to initialize the sprites engine with the game sprites. This
    -- initialization array helps us do it neatly. The helper function will
    -- fetch user-provided data from the GAME_SPRITES array and return an
    -- array of sprites ready to be assigned to sprite engine upon reset.
    constant SPRITES_INITIAL_VALUES: sprites_array_type := make_sprites_initial_values(GAME_SPRITES);

    -- Background image to be used by the video engine (currently, the user game
    -- logic is responsible for providing the video engine with background tile).
    signal background_bitmap: paletted_bitmap_type(0 to 7, 0 to 7);

    alias button_up: std_logic is input_buttons(3);
    alias button_down: std_logic is input_buttons(2);
    alias button_left: std_logic is input_buttons(1);
    alias button_right: std_logic is input_buttons(0);

    constant NPCS: npc_array_type := (
        -- Ghost moves around the chest in a diamond-shaped path
        make_npc_bouncer(
            initial_position => (144, 64),
            allowed_region => (128, 64, 160, 96),
            initial_speed => (1, 1)
        ),
        -- Scorpion moves horizontally accross the screen
        make_npc_bouncer(
            initial_position => (0, 128),
            initial_speed => (1, 0)
        ),
        -- Bat, moves horizontally
        make_npc_bouncer(
            initial_position => (160, 160),
            allowed_region => (0, 160, 300, 164),
            initial_speed => (1, 1)
        ),
        -- Oryx tries to kill the player with its sword
        make_npc_follower(
            initial_position => (300, 220),
            slowdown_factor => 2
        ),
        -- Archer tries to hide behind the player
        make_npc_follower(
            initial_position => (0, 0),
            slowdown_factor => 1
        ),
        -- reaper
        make_npc_follower(
            initial_position => (300, 64),
            slowdown_factor => 4
        )
    );

    signal npc_positions: point_array_type(NPCS'range);
    alias ghost_position: point_type is npc_positions(0);
    alias scorpion_position: point_type is npc_positions(1);
    alias bat_position: point_type is npc_positions(2);
    alias oryx_position: point_type is npc_positions(3);
    alias archer_position: point_type is npc_positions(4);
    alias reaper_position: point_type is npc_positions(5);

    signal npc_target_positions: point_array_type(NPCS'range);

begin

    ----------------------------------------------------------------------------
    -- Overall architecture description:
    --   1) Update player position based on input buttons
    --   2) Update NPC positions
    --   3) Define sprite positions
    --   4) Update game state (play, game over, etc.)
    --   5) Instantiante the game engine and other auxiliary entities
    ----------------------------------------------------------------------------

    ----------------------------------------------------------------------------
    -- Section 1: Update player position based on input buttons
    update_player_position: process (clock_50_Mhz, reset) begin
        if reset then
            player_position <= (128, 128);
        elsif rising_edge(clock_50_Mhz) then
            if time_base_50_ms then
                if button_right then
                    player_position.x <= player_position.x + 1;
                elsif button_left then
                    player_position.x <= player_position.x - 1;
                end if;

                if button_down then
                    player_position.y <= player_position.y + 1;
                elsif button_up then
                    player_position.y <= player_position.y - 1;
                end if;
            end if;
        end if;
    end process;

    ----------------------------------------------------------------------------
    -- Section 2) Update NPC positions.

    -- We only need to assign the values correspoding to followers
    npc_target_positions(3) <= player_position;
    npc_target_positions(4) <= player_position + (-12,0);
    npc_target_positions(5) <= player_position + (12, -4);

    npcs_movement: entity work.npcs_engine
        generic map (
            NPC_DEFINITIONS => NPCS
        ) port map (
            clock => clock_50_Mhz,
            reset => reset,
            time_base => time_base_50_ms,
            target_positions => npc_target_positions,
            npc_positions => npc_positions
        );

    ----------------------------------------------------------------------------
    -- Section 3) Provide a screen position for each sprite. For static objects,
    -- we can use constants or hardcoded values. For moving objects and NPCs,
    -- we use signals.

    sprites_coordinates <= make_sprite_positions((
        (SORCERER_SPRITE,  player_position),
        (AXE_SPRITE,       AXE_POSITION),
        (ARCHER_SPRITE,    archer_position),
        (CHEST_SPRITE,     CHEST_POSITION),
        (GHOST_SPRITE,     ghost_position),
        (SCORPION_SPRITE,  scorpion_position),
        (ORYX_11_SPRITE,   oryx_position),
        (ORYX_12_SPRITE,   oryx_position + point_type'(8,0)),
        (ORYX_21_SPRITE,   oryx_position + point_type'(0,8)),
        (ORYX_22_SPRITE,   oryx_position + point_type'(8,8)),
        (BAT_SPRITE,       bat_position),
        (REAPER_SPRITE,    reaper_position)
    ));

    ----------------------------------------------------------------------------
    -- Section 4) Update game state. This game has a very simple state logic:
    -- RESET --> PLAY --> GAME_WON or GAME_OVER
    game_won <= treasure_found;
    game_over <= death_by_ghost or death_by_scorpion or death_by_oryx;
    process (clock_50_Mhz, reset) begin
        if reset then
            game_state <= GS_RESET;
        elsif rising_edge(clock_50_Mhz) then
            case game_state is
                when GS_RESET =>
                    if input_buttons /= "0000" then
                        game_state <= GS_PLAY;
                    end if;
                when GS_PLAY =>
                    if game_won then
                        game_state <= GS_GAME_WON;
                    elsif game_over then
                        game_state <= GS_GAME_OVER;
                    end if;
                when others =>
                    null;
            end case;
        end if;
    end process;

    -- Select a background bitmap based on current game state (currently, this
    -- is the only feedback we provide the player with)
    with game_state select background_bitmap <=
        get_bitmap_from_handle(GAME_OVER_TILE_BITMAP) when GS_GAME_OVER,
        get_bitmap_from_handle(GAME_WON_TILE_BITMAP) when GS_GAME_WON,
        get_bitmap_from_handle(FOREST_TILE_BITMAP) when others;

    ----------------------------------------------------------------------------
    -- Section 5) Instantiate the game engine and other entities. We use some
    -- auxiliary entities to calculate NPC positions according to predefined
    -- behavior patterns (to give the NPCs an "artificial intelligence").

    engine: entity work.game_engine
        generic map (
            SPRITES_INITIAL_VALUES => SPRITES_INITIAL_VALUES,
            SPRITES_COLLISION_QUERY => SPRITES_COLLISION_QUERY
        ) port map (
            clock_50MHz => clock_50_Mhz,
            reset => reset,
            sprites_coordinates => sprites_coordinates,
            sprite_collisions_results => sprite_collisions_results,
            elapsed_time => elapsed_time,
            time_base_50_ms => time_base_50_ms,
            game_state => game_state,
            background_bitmap => background_bitmap,
            vga_clock_in => vga_clock_in,
            vga_signals => vga_output_signals
        );

    vga_clock_out <= vga_output_signals.vga_clock_out;
    vga_blank <= vga_output_signals.blank;
    vga_n_hsync <= vga_output_signals.hsync;
    vga_n_vsync <= vga_output_signals.vsync;
    vga_n_sync <= vga_output_signals.sync;
    vga_red <= vga_output_signals.red;
    vga_green <= vga_output_signals.green;
    vga_blue <= vga_output_signals.blue;

    debug_bits(0) <= '1' when death_by_scorpion else '0';
    debug_bits(1) <= '1' when death_by_ghost else '0';
    debug_bits(2) <= '1' when death_by_oryx else '0';
    debug_bits(3) <= '1' when game_state = GS_RESET else '0';
    debug_bits(4) <= '1' when game_state = GS_PLAY else '0';
    debug_bits(5) <= '1' when game_state = GS_GAME_OVER else '0';
    debug_bits(6) <= '1' when game_state = GS_GAME_WON else '0';
    debug_bits(7) <= '0';
end;