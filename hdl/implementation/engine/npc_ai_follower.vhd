library ieee;
use ieee.std_logic_1164.all;
use work.graphics_types_pkg.all;
use work.game_state_pkg.all;
use work.npc_pkg.all;

-- "Artifical intelligence" (for lack of a better name) for moving NPCs
-- (non-player characters, such as enemies) around the screen. The "follower"
-- strategy consists in moving the NPC in the direction of a given point on
-- the screen, which may be variable.
entity npc_ai_follower is
    port (
        reset, clock: in std_logic;
        -- time base pulse, NPC state gets updated when high (tipically every 100 ms)
        time_base: in std_logic;
        -- true if NPC is active in the game and must be updated
        enabled: in boolean;
        -- limits for NPC movement
        allowed_region: in rectangle_type;
        -- starting point for the NPC
        initial_position: in point_type;
        -- start velocity for the NPC
        absolute_speed: in integer range 0 to NPC_SPEED_MAX;
        slowdown_factor: in integer range 0 to NPC_SPEED_MAX;
        -- goal position, NPC moves towards this point
        target_position: in point_type;
        -- calculated NPC position
        npc_position: out point_type
    );
end;

architecture rtl of npc_ai_follower is
    -- current NPC position
    signal position: point_type;

    signal slowdown_counter: integer range 0 to NPC_SPEED_MAX;
    signal scaled_time_base: std_logic;

begin

    process (clock, reset) begin
        if reset then
            slowdown_counter <= 0;
            scaled_time_base <= '0';
        elsif rising_edge(clock) then
            scaled_time_base <= '0';
            if time_base = '1' then
                if slowdown_counter < slowdown_factor then
                    slowdown_counter <= slowdown_counter + 1;
                else
                    slowdown_counter <= 0;
                    scaled_time_base <= '1';
                end if;
            end if;
        end if;
    end process;

    process (clock, reset, initial_position) is
        variable new_position: point_type;
    begin
        if reset then
            position <= initial_position;

        elsif rising_edge(clock) then
--            if scaled_time_base then
            if enabled and scaled_time_base = '1' then
                if position.x < target_position.x then
                    new_position.x := position.x + absolute_speed;
                elsif position.x > target_position.x then
                    new_position.x := position.x - absolute_speed;
                end if;

                if new_position.y < target_position.y then
                    new_position.y := position.y + absolute_speed;
                elsif new_position.y > target_position.y then
                    new_position.y := position.y - absolute_speed;
                end if;

                -- make sure x position is within limits; invert horizontal speed
                -- when NPC touches an edge
                if new_position.x < allowed_region.left then
                    new_position.x := allowed_region.left;
                elsif new_position.x > allowed_region.right then
                    new_position.x := allowed_region.right;
                end if;

                -- make sure y position is within limits
                if new_position.y < allowed_region.top then
                    new_position.y := allowed_region.top;
                elsif new_position.y > allowed_region.bottom then
                    new_position.y := allowed_region.bottom;
                end if;

                position <= new_position;
            end if;
        end if;
    end process;

    npc_position <= position;

end;


