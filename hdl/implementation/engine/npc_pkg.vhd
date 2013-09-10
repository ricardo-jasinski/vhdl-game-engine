use work.graphics_types_pkg.all;

package npc_pkg is

    constant NPC_SPEED_MAX: integer := 12;

    type npc_ai_type is (AI_BOUNCER, AI_FOLLOWER, AI_PROJECTILE);

    type npc_type is record
        -- start position for the NPC
        initial_position: point_type;
        -- start velocity for the NPC
        initial_speed: point_type;

        absolute_speed: integer range 0 to NPC_SPEED_MAX;
        slowdown_factor: integer range 0 to NPC_SPEED_MAX;
        -- boundaries for NPC movement
        allowed_region: rectangle_type;
        -- type of artificial intelligence for NPC movement
        ai_type: npc_ai_type;
    end record;

    type npc_array_type is array (natural range <>) of npc_type;

    function make_npc_bouncer(
        initial_position: point_type := (0, 0);
        initial_speed: point_type := (1, 0);
        allowed_region: rectangle_type := (0, 0, GAME_VIEWPORT_WIDTH-1, GAME_VIEWPORT_HEIGHT-1)
    ) return npc_type;

    function make_npc_projectile(
        initial_position: point_type := (0, 0);
        initial_speed: point_type := (1, 0);
        allowed_region: rectangle_type := (0, 0, GAME_VIEWPORT_WIDTH-1, GAME_VIEWPORT_HEIGHT-1)
    ) return npc_type;

    function make_npc_follower(
        initial_position: point_type := (0, 0);
        allowed_region: rectangle_type := (0, 0, GAME_VIEWPORT_WIDTH-1, GAME_VIEWPORT_HEIGHT-1);
        absolute_speed: integer range 0 to NPC_SPEED_MAX := 1;
        slowdown_factor: integer range 0 to NPC_SPEED_MAX := 0
    ) return npc_type;

end;

package body npc_pkg is

    function make_npc_bouncer(
        initial_position: point_type := (0, 0);
        initial_speed: point_type := (1, 0);
        allowed_region: rectangle_type := (0, 0, GAME_VIEWPORT_WIDTH-1, GAME_VIEWPORT_HEIGHT-1)
    ) return npc_type is
    begin
        return (
            -- some parameters are copied from the input
            initial_position => initial_position,
            initial_speed => initial_speed,
            allowed_region => allowed_region,
            -- some parameters are constant
            ai_type => AI_BOUNCER,
            -- remaining parameters are unsused, but must have any arbitrary value
            absolute_speed => 0,
            slowdown_factor => 0
        );
    end;

    function make_npc_projectile(
        initial_position: point_type := (0, 0);
        initial_speed: point_type := (1, 0);
        allowed_region: rectangle_type := (0, 0, GAME_VIEWPORT_WIDTH-1, GAME_VIEWPORT_HEIGHT-1)
    ) return npc_type is
    begin
        return (
            -- some parameters are copied from the input
            initial_position => initial_position,
            initial_speed => initial_speed,
            allowed_region => allowed_region,
            -- some parameters are constant
            ai_type => AI_PROJECTILE,
            -- remaining parameters are unsused, but must have any arbitrary value
            absolute_speed => 0,
            slowdown_factor => 0
        );
    end;

    function make_npc_follower(
        initial_position: point_type := (0, 0);
        allowed_region: rectangle_type := (0, 0, GAME_VIEWPORT_WIDTH-1, GAME_VIEWPORT_HEIGHT-1);
        absolute_speed: integer range 0 to NPC_SPEED_MAX := 1;
        slowdown_factor: integer range 0 to NPC_SPEED_MAX := 0
    ) return npc_type is
    begin
        return (
            -- some parameters are copied from the input
            initial_position => initial_position,
            absolute_speed => absolute_speed,
            slowdown_factor => slowdown_factor,
            allowed_region => allowed_region,
            -- some parameters are constant
            ai_type => AI_FOLLOWER,
            -- remaining parameters are unsused, but must have any arbitrary value
            initial_speed => (0, 0)
        );
    end;

end;
