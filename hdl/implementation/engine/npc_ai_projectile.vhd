library ieee;
use ieee.std_logic_1164.all;
use work.graphics_types_pkg.all;
use work.game_state_pkg.all;

-- "Artifical intelligence" (for lack of a better name) for moving NPCs
-- (non-player characters, such as enemies) around the screen. The "projectile"
-- strategy consists in moving the NPC with a constant speed until it reaches
-- the limits
entity npc_ai_projectile is
    port (
        reset, clock: in std_logic;
        -- time base pulse, NPC state gets updated when high (tipically once every 100 ms)
        time_base: in std_logic;
        -- true if NPC is active in the game and must be updated
        enabled: in boolean;
        -- starting point for the NPC
        initial_position: in point_type;
        -- start velocity for the NPC
        initial_speed: in point_type;
        -- limits for NPC movement
        allowed_region: in rectangle_type;
        -- NPC restarts from this point if it was disabled
        assigned_position: in point_type;
        -- calculated NPC position
        npc_position: out point_type
    );
end;

architecture rtl of npc_ai_projectile is
    -- current NPC position
    signal position: point_type;
    -- current NPC speed
    signal speed: point_type;

    signal previous_enable: boolean;

begin

    process (clock, reset, initial_position, initial_speed, time_base) is
        variable new_position: point_type;
    begin
        if reset then
            position <= initial_position;
            speed <= initial_speed;

        elsif rising_edge(clock) then
            if time_base = '1' then
                if enabled then
                    if previous_enable then
                        new_position := position + speed;
                    else
                        new_position := assigned_position;
                    end if;

                    -- make sure x position is within limits
                    if new_position.x <= allowed_region.left then
                        new_position.x := allowed_region.left;
                    elsif new_position.x >= allowed_region.right then
                        new_position.x := allowed_region.right;
                    end if;

                    -- make sure y position is within limits
                    if new_position.y <= allowed_region.top then
                        new_position.y := allowed_region.top;
                    elsif new_position.y >= allowed_region.bottom then
                        new_position.y := allowed_region.bottom;
                    end if;

                    position <= new_position;
                end if;
                previous_enable <= enabled;
            end if;
        end if;
    end process;

    npc_position <= position;

end;