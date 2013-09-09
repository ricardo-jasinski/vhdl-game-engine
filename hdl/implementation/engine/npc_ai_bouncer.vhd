library ieee;
use ieee.std_logic_1164.all;
use work.graphics_types_pkg.all;
use work.game_state_pkg.all;

-- "Artifical intelligence" (for lack of a better name) for moving NPCs
-- (non-player characters, such as enemies) around the screen. The "bouncer"
-- strategy consists in moving the NPC within a square area, and inverting the
-- direction when it reaches the limits.
entity npc_ai_bouncer is
    port (
        reset, clock: in std_logic;
        -- time base pulse, NPC state gets updated when high (tipically every 100 ms)
        time_base: in std_logic;
        -- starting point for the NPC
        initial_position: in point_type;
        -- start velocity for the NPC
        initial_speed: in point_type;
        -- limits for NPC movement
        allowed_region: in rectangle_type;
        -- calculated NPC position
        npc_position: out point_type
    );
end;

architecture rtl of npc_ai_bouncer is
    -- current NPC position
    signal position: point_type;
    -- current NPC speed
    signal speed: point_type;

begin

--    process (clock, reset) is
    process (clock, reset, initial_position, initial_speed, time_base) is
        variable new_position: point_type;
    begin
        if reset then
            position <= initial_position;
            speed <= initial_speed;

        elsif rising_edge(clock) and time_base = '1' then
            new_position := position + speed;

            -- make sure x position is within limits; invert horizontal speed
            -- when NPC reaches an edge
            if new_position.x <= allowed_region.left then
                new_position.x := allowed_region.left;
                speed.x <= - speed.x;
            elsif new_position.x >= allowed_region.right then
                new_position.x := allowed_region.right;
                speed.x <= - speed.x;
            end if;

            -- make sure y position is within limits; invert vertical speed
            -- when NPC reaches an edge
            if new_position.y <= allowed_region.top then
                new_position.y := allowed_region.top;
                speed.y <= - speed.y;
            elsif new_position.y >= allowed_region.bottom then
                new_position.y := allowed_region.bottom;
                speed.y <= - speed.y;
            end if;

            position <= new_position;
        end if;
    end process;

    npc_position <= position;

end;