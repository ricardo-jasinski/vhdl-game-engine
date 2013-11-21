library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Data types and conversion functions for handling colors in paletted and true
-- color modes. There are 3 distinct color representations:
--   #1. A 5-bit palette index. This is the least expensive memorywise.
--   #2. A 24-bit RGB truecolor value. Each palette color maps to one truecolor value.
--   #3. A 30-bit RGB value in the format expected by some video chips.
-- All bitmaps are stored in paletted mode. Convenience functions are
-- provided to convert between the color types as necessary.
package colors_pkg is

    -- Internally, each color channel (red, green, blue) is encoded
    -- with 8 bits (256 levels)
    subtype color_channel_type is integer range 0 to 255;

    -- Data type for a RGB pixel encoded with 24bpp
    type rgb_color_type is record
        r, g, b: color_channel_type;
    end record;

    -- At the output interface, each color is encoded with 10 bits
    subtype output_pixel_channel_type is std_logic_vector(9 downto 0);

    -- Data types for a RGB pixel encoded with 30bpp and that can be
    -- output to the video display device
    type output_pixel_type is record
        r, g, b: output_pixel_channel_type;
    end record;

    -- Our color palette is an array of 24bpp RGB values.
    -- Color names come mostly from http://goo.gl/UxWjIU.
    -- Note: a pixel with a color value of #0 is transparent, and is not
    -- shown on the screen (the background pixel will be shown instead)
    type palette_type is array (natural range <>) of rgb_color_type;
    constant PALETTE: palette_type := (
        (  0,   0,   0),    --  0: TRANSPARENT (Note: for black, use color #34)
        ( 47,  42,  33),    --  1: BISTRE ......... dark grayish brown, with a yellowish cast
        ( 77,  70,  44),    --  2: DARK_LAVA ...... grayish brown, with a yellowish cast
        (163, 153,  96),    --  3: LIGHT_TAUPE .... light grayish brown
        (168, 236, 182),    --  4: CELADON ........ pale greyish shade of green
        (  6,  13,  69),    --  5: OXFORD_BLUE .... very dark azure
        ( 13,  33, 133),    --  6: PHTHALO BLUE ... bright, greenish-blue
        ( 16,  60, 255),    --  7: BLUE_RYB
        ( 18, 141, 254),    --  8: DODGER_BLUE
        ( 18, 187, 255),    --  9: SPIRO_DISCO_BALL
        ( 16, 237, 254),    -- 10: AQUA
        ( 18,  33,  18),    -- 11: DARK_JUNGLE_GREEN
        ( 17,  68,  25),    -- 12: MYRTLE
        ( 11, 166,   6),    -- 13: ISLAMIC_GREEN
        ( 96, 248,  17),    -- 14: BRIGHT_GREEN
        ( 41,  17,  47),    -- 15: ST_PATRICKS_BLUE
        ( 85,  54, 104),    -- 16: DARK_BYZANTIUM
        ( 54,  54,  54),    -- 17: GRAY_21
        ( 98,  98,  98),    -- 18: GRAY_38
        (149, 149, 149),    -- 19: GRAY_58
        (193, 193, 193),    -- 20: GRAY_76
        ( 36,  15,   9),    -- 21: ZINNWALDITE_BROWN
        ( 74,  17,  12),    -- 22: BULGARIAN_ROSE
        (165,  26,  20),    -- 23: RUFOUS
        (228,  32,  21),    -- 24: LUST
        (236,  92,  24),    -- 25: FLAME
        (255, 158,  19),    -- 26: DARK_TANGERINE
        (171, 222,  98),    -- 27: INCHWORM
        ( 50, 106,  37),    -- 28: HUNTER_GREEN
        ( 97, 160,  30),    -- 29: OLIVE_DRAB_3
        (182, 209,  35),    -- 30: ANDROID_GREEN
        ( 88,   7, 128),    -- 31: INDIGO
        (213,  43, 255),    -- 32: PHLOX
        ( 29,  29,  29),    -- 33: GRAY_11
        (  0,   0,   0),    -- 34: BLACK
        (105, 145, 175),    -- 35: AIR_FORCE_BLUE_RAF
        (183, 228, 236),    -- 36: POWDER_BLUE
        (119,  46,  36),    -- 37: BURNT_UMBER
        (157,  90,  32),    -- 38: GOLDEN_BROWN
        (255, 223,  23),    -- 39: GOLDEN_YELLOW
        (255, 255,  35),    -- 40: LASER_LEMON
        (226, 101,  83),    -- 41: TERRA_COTTA
        (234, 163,  95),    -- 42: SANDY_BROWN
        ( 30, 176, 158),    -- 43: LIGHT_SEA GREEN
        ( 95,  97,  20),    -- 44: FIELD_DRAB
        (161, 153,  21),    -- 45: DARK_GOLDENROD
        (238, 229,  87),    -- 46: CORN
        (206,  93, 169),    -- 47: SKY_MAGENTA
        (242, 169, 224),    -- 48: LAVENDER_ROSE
        ( 24,  33,  52),    -- 49: DARK_MIDNIGHT_BLUE
        ( 35,  83, 115),    -- 50: DARK_CERULEAN
        ( 63, 137, 178),    -- 51: STEEL_BLUE
        (112, 231, 241),    -- 52: ELECTRIC_BLUE
        (255, 255, 255),    -- 53: WHITE
        (117, 119, 220),    -- 54: MEDIUM_SLATE_BLUE
        (169,  94,  86),    -- 55: REDWOOD
        (226, 166, 155),    -- 56: TUMBLEWEED .......... skin pink
        (244, 229, 160),    -- 57: MEDIUM_CHAMPAGNE .... skin beige
        ( 20,  88,  92),    -- 58: MIDNIGHT_GREEN
        (  0, 146, 103),    -- 59: GREEN_NCS
        (  8, 214, 109),    -- 60: MALACHITE
        ( 97, 232, 164),    -- 61: MEDIUM_AQUAMARINE
        (167,  22, 121),    -- 62: JAZZBERRY_JAM
        (255,   0, 128)     -- 63: BRIGHT_PINK
    );

    -- Total number of colors in the system palette (including #0 = TRANSPARENT)
    constant PALETTE_COLORS_COUNT: integer := PALETTE'length;

    -- Index of a color entry in the system fixed palette
    subtype palette_color_type is integer range PALETTE'range;

--    -- A bitmap is a 2D array in which each element is a value from the palette
--    type paletted_bitmap_type is array (natural range <>, natural range <>) of palette_color_type;


    -- Convert a palette color to an RGB value; performs a color lookup
    function palette_to_rgb(palette_color: palette_color_type) return rgb_color_type;

    -- Convenience constants for referring to specific colors by name
    constant PC_TRANSPARENT: palette_color_type := 0;
    constant PC_DARK_JUNGLE_GREEN: palette_color_type := 11;
    constant PC_BLACK: palette_color_type := 34;
    constant PC_WHITE: palette_color_type := 53;
    constant RGB_BLACK: rgb_color_type := (0, 0, 0);

    function output_pixel_from_rgb_color(rgb_pixel: rgb_color_type) return output_pixel_type;
    function output_pixel_from_palette_color(palette_color: palette_color_type) return output_pixel_type;
    function color_channel_to_10_bits(channel_value: color_channel_type) return std_logic_vector;

end;

package body colors_pkg is

    -- Convert a color channel value from a short integer (0..255) to a
    -- 10-bit std_logic_vector, which can be output to the video DAC
    function color_channel_to_10_bits(channel_value: color_channel_type) return std_logic_vector is
        variable channel_value_slv: std_logic_vector(7 downto 0);
    begin
        channel_value_slv := std_logic_vector(to_unsigned(channel_value, 8));
        return channel_value_slv & channel_value_slv(7 downto 6);
    end;

    -- Perform a color lookup in the system palette, returning an RGB value from
    -- a palette index.
    function palette_to_rgb(palette_color: palette_color_type) return rgb_color_type is
    begin
        return PALETTE(palette_color);
    end;

    -- Convert a pixel from the 24-bit RGB representation used internally in the system
    -- to the 30-bit RGB used by the video DAC.
    function output_pixel_from_rgb_color(rgb_pixel: rgb_color_type) return output_pixel_type is
    begin
        return (
            color_channel_to_10_bits(rgb_pixel.r),
            color_channel_to_10_bits(rgb_pixel.g),
            color_channel_to_10_bits(rgb_pixel.b)
        );
    end;

    -- Convert a pixel from the paletted 5-bit representation used internally in the system
    -- to the 30-bit RGB used by the video DAC.
    function output_pixel_from_palette_color(palette_color: palette_color_type) return output_pixel_type is
        variable rgb_color: rgb_color_type;
    begin
        rgb_color := palette_to_rgb(palette_color);
        return output_pixel_from_rgb_color(rgb_color);
    end;

end;
