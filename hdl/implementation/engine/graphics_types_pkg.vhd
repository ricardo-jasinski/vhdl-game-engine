use work.colors_pkg.all;

-- Data types and functions for graphics operations.
package graphics_types_pkg is

    subtype zoom_factor_type is integer range 1 to 2;
    constant ZOOM_FACTOR: zoom_factor_type := 2;

    constant SCREEN_WIDTH: integer := 640;
    constant SCREEN_HEIGHT: integer := 480;

    constant GAME_VIEWPORT_WIDTH: integer := SCREEN_WIDTH / ZOOM_FACTOR;
    constant GAME_VIEWPORT_HEIGHT: integer := SCREEN_HEIGHT / ZOOM_FACTOR;

    -- Maximum value for any screen coordinate
    constant COORDINATE_VALUE_MAX: integer := 2047;

    subtype coordinate_type is integer range -COORDINATE_VALUE_MAX to COORDINATE_VALUE_MAX;

    -- Data type representing a point on the screen or in a graphics data
    -- structure (e.g., bitmap)
    type point_type is record
        x, y: coordinate_type;
    end record;

    -- Data type for an array of pixel coordinates
    type point_array_type is array (natural range <>) of point_type;

    type rectangle_type is record
        left, top, right, bottom: coordinate_type;
    end record;

    -- A bitmap is a 2D array in which each element is a value from the palette
    type paletted_bitmap_type is array (natural range <>, natural range <>) of palette_color_type;

    function "+" (lhs, rhs: point_type) return point_type;
    function "/" (lhs: point_type; rhs: integer) return point_type;
    function is_in_view(position: point_type) return boolean;
end;

package body graphics_types_pkg is

    -- Add two points by summing each axis' coordinates
    function "+" (lhs, rhs: point_type) return point_type is begin
        return (lhs.x + rhs.x, lhs.y + rhs.y);
    end;

    -- Divide a point by a scalar by dividing each coordinate by the scalar value
    function "/" (lhs: point_type; rhs: integer) return point_type is begin
        return (lhs.x / rhs, lhs.y / rhs);
    end;

    function is_in_view(position: point_type) return boolean is begin
        return
            position.x > 0 and position.x < GAME_VIEWPORT_WIDTH and
            position.y > 0 and position.y < GAME_VIEWPORT_HEIGHT;
    end;
end;
