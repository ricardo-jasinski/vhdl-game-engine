library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.colors_pkg.all;
use work.graphics_types_pkg.all;
use work.font_pkg.all;


package text_mode_graphics_pkg is

    subtype text_coordinate_type is natural range 0 to 127;

    constant TEXT_ROWS_COUNT: text_coordinate_type := 25;
    constant TEXT_COLUMNS_COUNT: text_coordinate_type := 80;
    constant TEXT_COLOR: palette_color_type := PC_WHITE;

    type graphics_string_type is record
        x: text_coordinate_type;
        y: text_coordinate_type;
        text: string(1 to 16);
        visible: boolean;
    end record;
    
    constant HELLO_WORLD_STRING: graphics_string_type := (
        x => 0,
        y => 0,
        text => "Hello world!!!  ",
        visible => true
    );
    
    constant SCORE_STRING: graphics_string_type := (
        x => 0,
        y => 10,
        text => "SCORE:     0    ",
        visible => true
    );
    
    type graphics_strings_type is array (natural range <>) of graphics_string_type;
    
    constant STRINGS: graphics_strings_type := (
        HELLO_WORLD_STRING,
        SCORE_STRING
    );

    function character_at_x_y(x, y: text_coordinate_type) return character;
    function text_pixel_at_x_y(x, y: coordinate_type) return boolean;
end;

package body text_mode_graphics_pkg is

    function character_at_x_y(x, y: text_coordinate_type) return character is
    begin
        for i in STRINGS'range loop
            if y = STRINGS(i).y and x >= STRINGS(i).x and x < STRINGS(i).x + STRINGS(i).text'length then
                return STRINGS(i).text(x - STRINGS(i).x + 1);
            end if;
        end loop;
        
        return ' ';
    end;

    function text_pixel_at_x_y(x, y: coordinate_type) return boolean is
        variable char: character;
        variable ascii_code: natural range 0 to 127;
        variable glyph: glyph_type;

        variable x_unsigned: unsigned(10 downto 0);
        variable y_unsigned: unsigned(10 downto 0);

        variable glyph_x: unsigned(2 downto 0);
        variable glyph_y: unsigned(3 downto 0);

    begin
        char := character_at_x_y(x / FONT_WIDTH, y / FONT_HEIGHT);
        ascii_code := character'pos(char);
        glyph := FONT_ROM(ascii_code);
        x_unsigned := to_unsigned(x, x_unsigned'length);
        y_unsigned := to_unsigned(y, y_unsigned'length);
        glyph_x := x_unsigned(glyph_x'range);
        glyph_y := y_unsigned(glyph_y'range);
        
        return glyph(to_integer(glyph_y))(to_integer(glyph_x)) = '1';
    end;
    
end;