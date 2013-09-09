library ieee;
use ieee.std_logic_1164.all;
use work.npc_pkg.all;
use work.graphics_types_pkg.all;

entity npcs_engine is
    generic (
        NPC_DEFINITIONS: npc_array_type
    );
    port (
        clock: in std_logic;
        reset: in std_logic;
        time_base: in std_logic;
        target_positions: in point_array_type;
        npc_positions: out point_array_type
    );
end;

architecture rtl of npcs_engine is
    alias npcs: npc_array_type is NPC_DEFINITIONS;
begin

    create_npcs: for i in npcs'range generate

        npc_is_follower: if npcs(i).ai_type = AI_FOLLOWER generate
            follower_npc: entity work.npc_ai_follower port map (
                reset => reset, clock => clock, time_base => time_base,
                allowed_region => npcs(i).allowed_region,
                initial_position => npcs(i).initial_position,
                absolute_speed => npcs(i).absolute_speed,
                slowdown_factor => npcs(i).slowdown_factor,
                target_position => target_positions(i),
                npc_position => npc_positions(i)
            );
        end generate;

        npc_is_bouncer: if npcs(i).ai_type = AI_BOUNCER generate
            bouncer_npc: entity work.npc_ai_bouncer port map(
                reset => reset, clock => clock, time_base => time_base,
                initial_position => npcs(i).initial_position,
                initial_speed => npcs(i).initial_speed,
                allowed_region => npcs(i).allowed_region,
                npc_position => npc_positions(i)
            );
        end generate;

    end generate;

end;
